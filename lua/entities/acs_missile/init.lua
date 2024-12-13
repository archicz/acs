AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

game.AddParticles("particles/acs_particles.pcf")
PrecacheParticleSystem("Rocket_Propeller")
PrecacheParticleSystem("Rocket_SmokeTrail")
PrecacheParticleSystem("Rocket_Start_Flash")

ENT.FuseTriggered = false
ENT.LaunchTime = 0
ENT.PropellerThrust = 0

function ENT:Initialize()
	self:SetModel(self:MissileData("mdl"))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

    local noCollideList = EntityList(self:GetRealOwner(), self:GetLauncher(), self:GetLauncher():GetParent())
    for i = 1, #noCollideList do
        constraint.NoCollide(self, noCollideList[i], 0, 0)
    end

    self:SetLaunched(false)
end

function ENT:MissileSetup(name)
    self:SetMissileName(name)
end

function ENT:MissileLaunch()
    if self:GetLaunched() then return end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
    
    self:SetLaunched(true)
    self.LaunchTime = CurTime()
end

function ENT:MissilePropellant()
    local speedDuration = self:MissileData("speedDuration")
    local speedMax = self:MissileData("speedMax")

    local durationStart = CurTime()
    local durationEnd = self.LaunchTime + speedDuration
    local durationDelta = durationEnd - durationStart

    local progress = 1 - math.Clamp(durationDelta / speedDuration, 0, 1)
    local easedProgress = math.ease.OutElastic((progress > 0) and progress or 1)
    local newSpeed = speedMax * easedProgress

    self.PropellerThrust = newSpeed
end

function ENT:MissileTrigger()
    dmgsystem.ExplosionBlast(
        self, 
        self:GetRealOwner(), 
        self:GetPos(), 
        self:MissileData("blastDistance"), 
        self:MissileData("blastDamage")
    )

    self.FuseTriggered = true
    SafeRemoveEntity(self)
end

function ENT:SimulateForwardThrust(phys)
    local forwardVec = self:GetForward()
    local curSpeed = self.PropellerThrust
    local acceleration = (forwardVec * curSpeed) - self:GetVelocity()
    
    phys:ApplyForceCenter(acceleration * phys:GetMass())
end

function ENT:SimulateSteering(phys)
    -- if guided then
    --     local startPos = phys:GetPos()
    --     local targetPos = guidanceTarget:GetPos()
    --     local canPredict = self:MissileData("predicts")

    --     if canPredict then
    --         local targetPhys = guidanceTarget:GetPhysicsObject()

    --         if IsValid(targetPhys) then
    --             local dist = self:GetPos():Distance(guidanceTarget:GetPos())
    --             local missileVel = phys:GetVelocity()
    --             local targetVel = targetPhys:GetVelocity()
    --             local tickInterval = engine.TickInterval()

    --             local predictTime = dist / missileVel:Length()
    --             local predictTicks = math.floor(predictTime / tickInterval)

    --             targetPos = targetPos + (targetVel * tickInterval * predictTicks)
    --         end
    --     end

    --     desiredDir = (targetPos - startPos):GetNormalized()
    -- end

    local desiredDir = self:GetForward()
    local desiredAngle = desiredDir:Angle()

    local angVel = phys:GetAngleVelocity()
    local angVelReal = Angle(angVel.y, angVel.z, angVel.x)
    local angForce = self:WorldToLocalAngles(desiredAngle)
    local inertia = phys:GetInertia()

    local angDif = self:MissileData("angDiff")
    local angMul = self:MissileData("angMul")
    local angDir = (angForce * angDif - angVelReal * angMul)

    phys:ApplyAngForce(Angle(angDir.p * inertia.y, angDir.y * inertia.z, angDir.r * inertia.x))
end

function ENT:PhysicsCollide(data, phys)
    if not self:GetLaunched() then return end

    self:MissileTrigger()
end

function ENT:PhysicsUpdate(phys)
    if not self:GetLaunched() then return end

    self:SimulateForwardThrust(phys)
    self:SimulateSteering(phys)
end

function ENT:Think()
    self:MissilePropellant()
    self:NextThink(CurTime())
    
    return true
end

function ENT:OnRemove()
end
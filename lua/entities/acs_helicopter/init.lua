AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- DEBUG ONLY, REMOVE THIS
function ENT:SpawnFunction(ply, tr, className)
	if not tr.Hit then return end

	local ent = helisystem.CreateHeli(
        ply,
        tr.HitPos + tr.HitNormal * 16,
        Angle(0, 0, 0),
        "combine_heli"
    )

	return ent
end
-- DEBUG ONLY, REMOVE THIS

function ENT:Initialize()
    self:SetUseType(SIMPLE_USE)

    vehicleseat.SetupVehicle(self)
    self:VehicleCreateSeats(self:HeliData("seats"))

    dmgsystem.SetupEntity(self)
    self:DamageInit(self:HeliData("dmg"))
    
    self:HeliCall("Initialize")
end

function ENT:HeliSetup(heliName)
    self:SetHeliName(heliName)
    self:HeliSetupControls()
end

function ENT:HeliSetupControls()
    local altitudeStrength = self:HeliData("altitudeStrength")
    local throttleStrength = self:HeliData("throttleStrength")
    local collectiveStrenght = self:HeliData("collectiveStrength")
    local cyclicStrength = self:HeliData("cyclicStrength")

    self.AltitudeAnalog = AnalogMapper(altitudeStrength)
    self.ThrottleAnalog = AnalogMapper(throttleStrength)
    self.CollectiveAnalog = AnalogMapper(collectiveStrenght)
    self.CyclicPitchAnalog = AnalogMapper(cyclicStrength)
    self.CyclicYawAnalog = AnalogMapper(cyclicStrength)
    self.CyclicRollAnalog = AnalogMapper(cyclicStrength)

    self:HeliResetControls()
end

function ENT:HeliResetControls()
    self.AltitudeAnalog:Input(0)
    self.ThrottleAnalog:Input(0)
    self.CollectiveAnalog:Input(0)
    self.CyclicPitchAnalog:Input(0)
    self.CyclicYawAnalog:Input(0)
    self.CyclicRollAnalog:Input(0)
end

function ENT:HeliStart()
    self.ThrottleAnalog:Input(1)
end

function ENT:HeliStop()
    self:HeliResetControls()
end

function ENT:HeliApplyCollective(newCollective)
    if not self:HeliActive() then return end

    self.CollectiveAnalog:Input(newCollective)

    local altitude = (newCollective > 0) and 0 or 1
    self.AltitudeAnalog:Input(altitude)
end

function ENT:HeliApplyCyclic(newCyclic)
    self.CyclicPitchAnalog:Input(newCyclic.p)
    self.CyclicYawAnalog:Input(newCyclic.y)
    self.CyclicRollAnalog:Input(newCyclic.r)
end

function ENT:HeliUpdateControls()
    local throttle = self.ThrottleAnalog:Output()
    local collective = self.CollectiveAnalog:Output()
    local cyclicPitch = self.CyclicPitchAnalog:Output()
    local cyclicYaw = self.CyclicYawAnalog:Output()
    local cyclicRoll = self.CyclicRollAnalog:Output()

    self:SetThrottle(throttle)
    self:SetCollective(collective)
    self:SetCyclic(Angle(cyclicPitch, cyclicYaw, cyclicRoll))
end

function ENT:HeliUpdateRotorWash()
    local throttle = self:GetThrottle()

    if (throttle > 0.5) and not IsValid(self.RotorWash) then
        self.RotorWash = ents.Create("env_rotorwash_emitter")
        self.RotorWash:SetPos(self:GetPos())
        self.RotorWash:SetParent(self)
        self.RotorWash:Spawn()
        self.RotorWash:Activate()
    elseif (throttle < 0.5) and IsValid(self.RotorWash) then
        SafeRemoveEntity(self.RotorWash)
        self.RotorWash = nil
    end
end

function ENT:SimulateHeliCollective(phys)
    local collective = self:GetCollective()
    local altitude = self.AltitudeAnalog:Output()

    local upVec = self:GetUp()
    local forwardVec = self:GetForward()
    local vel = phys:GetVelocity()
    local mass = phys:GetMass()
    local gravity = physenv.GetGravity()
    local tickInterval = engine.TickInterval()
    local antiGravity = mass * tickInterval * gravity.z * -1

    local collectiveForce = self:HeliData("collectiveForce")
	local altitudeForce = self:HeliData("altitudeForce")
	local altitudeFactor = self:HeliData("altitudeFactor")
    local normalizerFactor = self:HeliData("normalizerFactor")

	local altitudeThrust = math.Clamp(1 + (-vel.z * altitudeFactor) * (altitudeForce - 1), 0, altitudeForce)
	phys:ApplyForceCenter(upVec * altitude * altitudeThrust * antiGravity)

    local normalizerVec = Vector(vel.x, vel.y, 0) * (1 / normalizerFactor) * -1
    phys:ApplyForceCenter(normalizerVec * altitude * antiGravity) 

    phys:ApplyForceCenter(upVec * collective * collectiveForce * antiGravity)
end

function ENT:SimulateHeliCyclic(phys)
    local throttle = self:GetThrottle()
    if (throttle < 1) then return end 
    
    local cyclic = self:GetCyclic()
    local angVel = phys:GetAngleVelocity()
    local angVelReal = Angle(angVel.y, angVel.z, angVel.x)
    local angForce = Angle(cyclic.p, cyclic.y, cyclic.r)
    local inertia = phys:GetInertia()
    local angDir = (angForce * 90 - angVelReal)

    phys:ApplyAngForce(Angle(angDir.p * inertia.y, angDir.y * inertia.z, angDir.r * inertia.x))
end

function ENT:OnDamagePhysicsCollide(colData)
    self:HeliCall("OnDamagePhysicsCollide", colData)
end

function ENT:OnDamagePhysicsDamage(colData)
    self:HeliCall("OnDamagePhysicsDamage", colData)
end

function ENT:Use(activator, caller)
    self:HeliCall("Use", activator, caller)
end

function ENT:PhysicsUpdate(phys)
    self:SimulateHeliCollective(phys)
    self:SimulateHeliCyclic(phys)
end

function ENT:Think()
    self:HeliUpdateControls()
    self:HeliUpdateRotorWash()
	self:NextThink(CurTime())

	return true
end

function ENT:OnRemove()
    self:VehicleRemoveSeats()
    self:HeliCall("OnRemove")
end
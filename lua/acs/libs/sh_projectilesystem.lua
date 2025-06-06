local ActiveProjectiles = {}
local BaseProjectile =
{
    dragCoef = 0.04
}

projectilesystem = baseregistry.Create(BaseProjectile, "Projectile", "projectiles")
projectilesystem.NetworkString = "ProjectileSystem"

PROJECTILESYSTEM_NET_CREATE = 0

local Projectile = {}
Projectile.DragDiv = 80
Projectile.Gravity = Vector(0, 0, -GetConVar("sv_gravity"):GetInt())
Projectile.__index = Projectile

function Projectile:New(launcher, localPos, vel, projName)
    self.Launcher = launcher
    self.Pos = launcher:LocalToWorld(localPos)
    self.LastPos = self.Pos
    self.Velocity = vel
    self.Name = projName
    self.Filter = EntityList(launcher, launcher:GetParent())

    self:ProjectileCall("OnCreated")
end

function Projectile:ProjectileData(key)
    local projTbl = projectilesystem.Get(self.Name)
    return projTbl[key] or nil
end

function Projectile:ProjectileCall(fn, ...)
    projectilesystem.Call(self.Name, fn, self, ...)
end

function Projectile:GetLauncher()
    return self.Launcher
end

function Projectile:GetPos()
    return self.Pos
end

function Projectile:GetVelocity()
    return self.Velocity
end

function Projectile:GetDeltaPos()
    return (self.Pos - self.LastPos)
end

function Projectile:Remove()
    self.MarkedForRemoval = true
    self:ProjectileCall("OnRemove")
end

function Projectile:IsRemoved()
    return self.MarkedForRemoval or false
end

function Projectile:ImpactCheck()
    local trace = util.TraceLine({
        start = self.Pos,
        endpos = self.NextPos,
        filter = self.Filter
    })

    if trace.Hit then
        if trace.HitWorld then
            self:ProjectileCall("OnImpactWorld", trace)
            -- print("hit world")
        elseif IsValid(trace.Entity) then
            self:ProjectileCall("OnImpactEntity", trace)
            -- print("hit entity")
        end

        self:Remove()
    end
end

function Projectile:Simulate()
    local dragCoef = self:ProjectileData("dragCoef")
    local gravity = self.Gravity
    local curTime = CurTime()
    local deltaTime = self.LastSimulation and (curTime - self.LastSimulation) or 0
    local drag = self.Velocity:GetNormalized() * (dragCoef * self.Velocity:LengthSqr()) / self.DragDiv
    local correction = 0.5 * (gravity - drag) * deltaTime

    self.LastPos = self.Pos
    self.NextPos = self.Pos + (self.Velocity + correction) * deltaTime
    self.NextVelocity = self.Velocity + (gravity - drag) * deltaTime

    self:ImpactCheck()

    self.Pos = self.NextPos
    self.Velocity = self.NextVelocity
    self.LastSimulation = curTime
end



function projectilesystem.GetProjectileMeta()
    return Projectile
end

function projectilesystem.CreateProjectile(launcher, localPos, vel, projName)
    if not projectilesystem.Get(projName) then return nil end

    if SERVER then
        net.Start(projectilesystem.NetworkString)
        net.WriteUInt(PROJECTILESYSTEM_NET_CREATE, 4)
        net.WriteEntity(launcher)
        net.WritePreciseVector(localPos)
        net.WritePreciseVector(vel)
        net.WriteString(projName)
        net.Broadcast()
    end

    local activeProjectile = {}
    setmetatable(activeProjectile, Projectile)
    activeProjectile:New(launcher, localPos, vel, projName)
    table.insert(ActiveProjectiles, activeProjectile)

    return activeProjectile
end

function projectilesystem.GetActive()
    return ActiveProjectiles
end

function projectilesystem.Think()
    for index, projectile in pairs(ActiveProjectiles) do
        if not projectile then continue end

        if projectile:IsRemoved() then
            ActiveProjectiles[index] = nil
            continue
        end

        projectile:Simulate()
    end
end

hook.Add("Think", "ProjectileSystemThink", projectilesystem.Think)
local Projectile = {}
Projectile.DragDiv = 80
Projectile.Gravity = Vector(0, 0, -GetConVar("sv_gravity"):GetInt())
Projectile.__index = Projectile

function Projectile:New(launcher, pos, vel, projName)
    self.Launcher = launcher
    self.Pos = pos
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

function Projectile:Remove()
    self.MarkedForRemoval = true
end

function Projectile:ImpactCheck()
    local trace = util.TraceLine({
        start = self.Pos,
        endpos = self.NextPos,
        filter = self.Filter
    })

    if trace.Hit then
        if trace.Entity then
            self:ProjectileCall("OnImpactEntity", trace)
        else
            self:ProjectileCall("OnImpactWorld", trace)
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

	self.NextPos = self.Pos + (self.Velocity + correction) * deltaTime
    self.NextVelocity = self.Velocity + (gravity - drag) * deltaTime

    self:ImpactCheck()

    self.Pos = self.NextPos
    self.Velocity = self.NextVelocity
    self.LastSimulation = curTime
end



local ProjectileList = {}
local ActiveProjectiles = {}
local ProjectileSeed = 0
local BaseProjectile =
{
}

projectilesystem = {}
projectilesystem.NetworkString = "ProjectileSystem"

PROJECTILESYSTEM_NET_CREATE = 0
PROJECTILESYSTEM_NET_SEED = 1

function projectilesystem.GetProjectileMeta()
    return Projectile
end

function projectilesystem.GetList()
    return ProjectileList
end

function projectilesystem.Get(name)
    return ProjectileList[name] or nil
end

function projectilesystem.Call(name, fn, ...)
    local projTbl = projectilesystem.Get(name)
    if not projTbl then return end

    local tblFn = projTbl[fn]
    if not tblFn then return end

    return tblFn(...)
end

function projectilesystem.Register(name, projTbl)
    setmetatable(projTbl, {__index = BaseProjectile})
    ProjectileList[name] = projTbl
end

function projectilesystem.CreateProjectile(launcher, pos, vel, projName)
    if not projectilesystem.Get(projName) then return nil end

    if SERVER then
        local uniqueNumber = SysTime() + engine.TickInterval()
        local sharedSeed = util.CRC(tostring(uniqueNumber))
        projectilesystem.SetSharedSeed(sharedSeed)

        net.Start(projectilesystem.NetworkString)
        net.WriteUInt(PROJECTILESYSTEM_NET_CREATE, 4)
        net.WriteUInt(projectilesystem.GetSharedSeed(), 32)
        net.WriteEntity(launcher)
        net.WriteVector(pos)
        net.WriteVector(vel)
        net.WriteString(projName)
        net.Broadcast()
    end

    local activeProjectile = {}
    setmetatable(activeProjectile, Projectile)
    activeProjectile:New(launcher, pos, vel, projName)
    table.insert(ActiveProjectiles, activeProjectile)

    return activeProjectile
end

function projectilesystem.SetSharedSeed(seed)
    ProjectileSeed = seed
end

function projectilesystem.GetSharedSeed()
    return ProjectileSeed
end

function projectilesystem.GetActive()
    return ActiveProjectiles
end

function projectilesystem.Think()
    for index, projectile in pairs(ActiveProjectiles) do
        if not projectile then continue end

        if projectile.MarkedForRemoval then
            ActiveProjectiles[index] = nil
        else
            projectile:Simulate()
        end
    end
end

hook.Add("Think", "ProjectileSystemThink", projectilesystem.Think)
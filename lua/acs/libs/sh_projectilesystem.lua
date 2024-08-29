local Projectile = {}
Projectile.DragDiv = 80
Projectile.Gravity = Vector(0, 0, -GetConVar("sv_gravity"):GetInt())
Projectile.__index = Projectile

function Projectile:New(launcher, pos, dir, projName)
    self.Launcher = launcher
    self.Pos = pos
    self.Dir = dir
    self.Name = projName
    self.Filter = EntityList(launcher, launcher:GetParent())
    -- self.SharedRandom = pos.x + pos.y + pos.z + dir.x + dir.y + dir.z

    self:ProjectileCall("OnCreated")
end

function Projectile:ProjectileData(key)
    local projTbl = projectilesystem.Get(self.Name)
    return projTbl[key] or nil
end

function Projectile:ProjectileCall(fn, ...)
    projectilesystem.Call(self.Name, fn, self, ...)
end

function Projectile:Remove()
end

function Projectile:Simulate()
    local dragCoef = self:ProjectileData("dragCoef")
    local gravity = self.Gravity
    local curTime = CurTime()
    local deltaTime = self.LastSimulation and (curTime - self.LastSimulation) or 0
    local drag = self.Dir:GetNormalized() * (dragCoef * self.Dir:LengthSqr()) / self.DragDiv
    local correction = (gravity - drag) * deltaTime

	self.NextPos = self.Pos + self.Dir * deltaTime + 0.5 * correction * math.sqrt(deltaTime)
    self.NextDir = self.Dir + correction * deltaTime

    local trace = util.TraceLine({
        start = self.Pos,
        endpos = self.NextPos,
        filter = self.Filter
    })

    self.Pos = self.NextPos
    self.Dir = self.NextDir
    self.LastSimulation = curTime
end



local ProjectileList = {}
local ActiveProjectiles = {}
local BaseProjectile =
{
}

projectilesystem = {}
projectilesystem.NetworkString = "ProjectileSystem"

PROJECTILESYSTEM_NET_CREATE = 0

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

function projectilesystem.CreateProjectile(launcher, pos, dir, projName)
    if not projectilesystem.Get(projName) then return nil end

    if SERVER then
        net.Start(projectilesystem.NetworkString)
        net.WriteUInt(PROJECTILESYSTEM_NET_CREATE, 4)
        net.WriteEntity(launcher)
        net.WriteVector(pos)
        net.WriteVector(dir)
        net.WriteString(projName)
        net.Broadcast()
    end

    local activeProjectile = {}

    setmetatable(activeProjectile, Projectile)
    activeProjectile:New(launcher, pos, dir, projName)
    table.insert(ActiveProjectiles, activeProjectile)

    return activeProjectile
end

function projectilesystem.GetActive()
    return ActiveProjectiles
end

function projectilesystem.Think()
    for Index = 1, #ActiveProjectiles do
        local projectile = ActiveProjectiles[Index]
        projectile:Simulate()
    end
end

hook.Add("Think", "ProjectileSystemThink", projectilesystem.Think)
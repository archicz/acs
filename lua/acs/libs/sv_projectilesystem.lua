if not projectilesystem then return end
util.AddNetworkString(projectilesystem.NetworkString)

local Projectile = {}
Projectile.__index = Projectile

function Projectile:ProjectileData(key)
    local projTbl = projectilesystem.Get(self.Name)
    return projTbl[key] or nil
end

function Projectile:ProjectileCall(fn, ...)
    projectilesystem.Call(self.Name, fn, self, ...)
end



local ActiveProjectiles = {}

function projectilesystem.CreateProjectile(launcher, pos, dir, projName)
    if not projectilesystem.Get(projName) then return nil end

    net.Start(projectilesystem.NetworkString)
    net.WriteUInt(PROJECTILESYSTEM_NET_CREATE, 4)
    net.WriteEntity(launcher)
    net.WriteVector(pos)
    net.WriteVector(dir)
    net.WriteString(projName)
    net.Broadcast()

    local activeProjectile = {}
    activeProjectile.Launcher = launcher
    activeProjectile.StartPos = pos
    activeProjectile.StartDir = dir
    activeProjectile.Name = projName

    setmetatable(activeProjectile, Projectile)
    table.insert(ActiveProjectiles, activeProjectile)

    activeProjectile:OnCreated()

    return activeProjectile
end
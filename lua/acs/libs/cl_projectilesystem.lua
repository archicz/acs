if not projectilesystem then return end

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

function projectilesystem.ServerNetwork()
    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [PROJECTILESYSTEM_NET_CREATE] = function()
            local launcher = net.ReadEntity()
            local pos = net.ReadVector()
            local dir = net.ReadVector()
            local projName = net.ReadString()

            projectilesystem.CreateProjectile(launcher, pos, dir, projName)
        end
    }

    local stateFn = stateHandlers[state]
    if stateFn then
        pcall(stateFn)
    end
end

net.Receive(projectilesystem.NetworkString, projectilesystem.ServerNetwork)
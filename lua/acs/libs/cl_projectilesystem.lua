if not projectilesystem then return end

local ActiveProjectiles = projectilesystem.GetActive()
local Projectile = projectilesystem.GetProjectileMeta()

function Projectile:Draw()
    self:ProjectileCall("Draw")
end



function projectilesystem.ServerNetwork()
    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [PROJECTILESYSTEM_NET_CREATE] = function()
            local launcher = net.ReadEntity()
            local localPos = net.ReadPreciseVector()
            local dir = net.ReadPreciseVector()
            local projName = net.ReadString()
            
            projectilesystem.CreateProjectile(launcher, localPos, dir, projName)
        end
    }

    local stateFn = stateHandlers[state]
    if stateFn then
        pcall(stateFn)
    end
end

function projectilesystem.Draw()
    for index, projectile in pairs(ActiveProjectiles) do
        if not projectile then continue end
        if projectile:IsRemoved() then continue end

        projectile:Draw()
    end
end

hook.Add("PostDrawEffects", "ProjectileSystemDraw", projectilesystem.Draw)
net.Receive(projectilesystem.NetworkString, projectilesystem.ServerNetwork)
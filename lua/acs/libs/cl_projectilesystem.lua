if not projectilesystem then return end

local ActiveProjectiles = projectilesystem.GetActive()
local Projectile = projectilesystem.GetProjectileMeta()

function projectilesystem.ServerNetwork()
    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [PROJECTILESYSTEM_NET_CREATE] = function()
            local sharedSeed = net.ReadUInt(32)
            local launcher = net.ReadEntity()
            local pos = net.ReadVector()
            local dir = net.ReadVector()
            local projName = net.ReadString()
            
            projectilesystem.SetSharedSeed(sharedSeed)
            projectilesystem.CreateProjectile(launcher, pos, dir, projName)
        end
    }

    local stateFn = stateHandlers[state]
    if stateFn then
        pcall(stateFn)
    end
end

local sprMat = Material("sprites/light_ignorez")

function projectilesystem.Draw3D()
    for index, projectile in pairs(ActiveProjectiles) do
        if not projectile then continue end

        cam.Start3D()
		    render.SetMaterial(sprMat)
		    render.DrawSprite(projectile.Pos, 32, 32, Color(255, 255, 255, 255))
	    cam.End3D()
    end
end

hook.Add("HUDPaint", "ProjectileSystemDraw3D", projectilesystem.Draw3D)
net.Receive(projectilesystem.NetworkString, projectilesystem.ServerNetwork)
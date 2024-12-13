if not projectilesystem then return end
util.AddNetworkString(projectilesystem.NetworkString)

local ActiveProjectiles = projectilesystem.GetActive()
local Projectile = projectilesystem.GetProjectileMeta()

function projectilesystem.MakeVelocity(dir, velScalar, spreadAmount)
   local spreadAng = Angle(
        math.Rand(-spreadAmount.p, spreadAmount.p),
        math.Rand(-spreadAmount.y, spreadAmount.y),
        math.Rand(-spreadAmount.r, spreadAmount.r)
    )

    local dirAng = dir:Angle()
    local finalDir = (dirAng + spreadAng):Forward()
    local velocity = finalDir * velScalar

    return velocity
end
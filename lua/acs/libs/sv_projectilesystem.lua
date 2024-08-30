if not projectilesystem then return end
util.AddNetworkString(projectilesystem.NetworkString)

local ActiveProjectiles = projectilesystem.GetActive()
local Projectile = projectilesystem.GetProjectileMeta()

function projectilesystem.MakeVelocity(dir, velScalar, spreadAmount)
    local uniqueNumber = SysTime() + engine.TickInterval()
    local randomSeed = util.CRC(tostring(uniqueNumber))
    math.randomseed(randomSeed)

    local spreadAng = Angle(
        math.random(-spreadAmount.p, spreadAmount.p),
        math.random(-spreadAmount.y, spreadAmount.y),
        math.random(-spreadAmount.r, spreadAmount.r)
    )

    local dirAng = dir:Angle()
    local finalDir = (dirAng + spreadAng):Forward()
    local velocity = finalDir * velScalar
    
    return velocity
end
local MissileList = {}
local BaseMissile =
{
    speedDuration = 2,
    speedMax = 2400,

    blastDamage = 240,
    blastDistance = 320,
    fuseHull = Vector(10, 10, 10),
    fuseDist = 30,

    guided = false,
    predicts = false,
    angDiff = 75,
    angMul = 40,

    mdl = "models/weapons/w_missile_closed.mdl"
}

missilesystem = {}
missilesystem.ClassName = "acs_missile"

function missilesystem.GetList()
    return MissileList
end

function missilesystem.Get(name)
    return MissileList[name] or nil
end

function missilesystem.Register(name, missileTbl)
    setmetatable(missileTbl, {__index = BaseMissile})
    MissileList[name] = missileTbl
end
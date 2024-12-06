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

missilesystem = baseregistry.Create(BaseMissile, "Missile", "missiles")
missilesystem.ClassName = "acs_missile"
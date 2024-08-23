local StingerMissile =
{
    speedDuration = 2,
    speedMax = 2400,

    blastDamage = 140,
    blastDistance = 400,
    fuseHull = Vector(10, 10, 10),
    fuseDist = 30,
    
    guided = true,
    predicts = true,
    angDiff = 75,
    angMul = 40,

    mdl = "models/acs/missiles/default.mdl"
}

missilesystem.Register("stinger", StingerMissile)
local Heli =
{
    pacMdl = pacmodel.Parse(pacmodel.DecodePACFile("pac3/acs_heli/basicheli.txt", "DATA")),

    dmg =
    {
        maxHealth = 2000,
        defaultHealth = 2000,

        types =
        {
            [DMGSYS_TYPE_EXPLOSIVE] = 1,
            [DMGSYS_TYPE_AP] = 0.5
        },

        physics = 
        {
            collideThreshold = 75,
            damageThreshold = 500,
            damageCoeff = 0.05,
            damageMax = 200
        }
    },
    
    mass = 2400,
    throttleStrength = 0.25,

    altitudeStrength = 1,
    altitudeForce = 1.75,
    altitudeFactor = 400,
    normalizerFactor = 1000,
    
    collectiveStrength = 2,
    collectiveForce = 1.75,

    cyclicStrength = 10
}

return Heli
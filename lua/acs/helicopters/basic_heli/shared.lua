local Heli =
{
    seats =
    {
        {
            name = "combine_heli_pilot",
            pos = Vector(142, 0, -50),
            ang = Angle(0, -90, 0),
            weapons =
            {
                "autocannon",
                "missile_launcher"
            }
        }
    },

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
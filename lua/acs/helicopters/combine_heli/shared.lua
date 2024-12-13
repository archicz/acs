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

    damage =
    {
        maxHealth = 2000,
        defaultHealth = 2000
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
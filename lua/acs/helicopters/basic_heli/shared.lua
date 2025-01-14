if SERVER then
    AddCSLuaFile("outfit.lua")
end

local Heli =
{
    pacMdl = pacmodel.Parse(include("outfit.lua")),
    
    dmg =
    {
        maxHealth = 2000,
        defaultHealth = 2000,

        types =
        {
            {
                type = DMGSYS_TYPE_EXPLOSIVE,
                coeff = 1
            },
            {
                type = DMGSYS_TYPE_AP,
                coeff = 0.5
            },
            {
                type = bit.bor(DMGSYS_TYPE_EXPLOSIVE, DMGSYS_TYPE_AP),
                coeff = 0.75
            }
        },

        physics = 
        {
            collideThreshold = 200,
            damageThreshold = 575,
            damageCoeff = 0.05,
            damageMax = 200
        }
    },
    
    mass = 2400,
    throttleStrength = 0.25,

    maxMainRotorHits = 4,
    maxTailRotorHits = 3,

    altitudeStrength = 1,
    altitudeForce = 1.75,
    altitudeFactor = 400,
    normalizerFactor = 1000,
    
    collectiveStrength = 2,
    collectiveForce = 1.75,

    cyclicStrength = 10
}

return Heli
local Weapon =
{
    printName = "Missile Launcher",

    origins =
    {
        {
            pos = Vector(21, -64, -71),
            ang = Angle(0, 0, 0)
        },
        {
            pos = Vector(21, 64, -71),
            ang = Angle(0, 0, 0)
        }
    },

    missileName = "stinger",

    maxAmmo = 16,
    defaultAmmo = 16,
    clipSize = 2,

    primaryFireRate = 0.5,
    secondaryFireRate = 0.1,

    reloadDelay = 5,
    reloadAuto = true
}

return Weapon
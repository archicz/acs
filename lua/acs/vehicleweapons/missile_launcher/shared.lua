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

    fireRate = 0.5,

    reloadDelay = 5,
    reloadAuto = true
}

return Weapon
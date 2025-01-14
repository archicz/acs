local Weapon =
{
    pacMdl = pacMdl = pacmodel.Parse(include("outfit.lua")),

    printName = "Missile Launcher",

    missileName = "stinger",

    maxAmmo = 16,
    defaultAmmo = 16,
    clipSize = 2,

    fireRate = 0.5,

    reloadDelay = 5,
    reloadAuto = true
}

return Weapon
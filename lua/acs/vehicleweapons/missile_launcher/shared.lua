local Weapon =
{
    pacMdl = pacmodel.Parse(pacmodel.DecodePACFile("pac3/acs_weapons/missile_launcher.txt", "DATA")),

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
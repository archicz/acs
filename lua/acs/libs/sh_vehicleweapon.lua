local BaseWeapon =
{
    printName = "Vehicle Weapon"
}

vehicleweapon = baseregistry.Create(BaseWeapon, "Vehicleweapon", "vehicleweapos")
vehicleweapon.ClassName = "acs_vehicleweapon"
vehicleweapon.NetworkString = "VehicleWeapon"

VEHICLEWEAPON_NET_WEAPONLIST = 0
VEHICLEWEAPON_NET_SELECT = 1
VEHICLEWEAPON_NET_ACTION = 2

VEHICLEWEAPON_ACTION_PRIMARY = 0
VEHICLEWEAPON_ACTION_SECONDARY = 1
VEHICLEWEAPON_ACTION_RELOAD = 2
VEHICLEWEAPON_ACTION_RELOADING = 3
VEHICLEWEAPON_ACTION_RELOADED = 4
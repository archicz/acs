local BaseWeapon =
{
    printName = "Vehicle Weapon"
}

vehicleweapon = baseregistry.Create(BaseWeapon, "Vehicleweapon", "vehicleweapons")
vehicleweapon.ClassName = "acs_vehicleweapon"
vehicleweapon.NetworkString = "VehicleWeapon"

VEHICLEWEAPON_NET_WEAPONLIST = 0
VEHICLEWEAPON_NET_SELECT = 1
VEHICLEWEAPON_NET_ACTION = 2

VEHICLEWEAPON_ACTION_FIRE = 0
VEHICLEWEAPON_ACTION_RELOAD = 1
VEHICLEWEAPON_ACTION_RELOADING = 2
VEHICLEWEAPON_ACTION_RELOADED = 3
VEHICLEWEAPON_ACTION_MAX = VEHICLEWEAPON_ACTION_RELOADED
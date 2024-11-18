local WeaponList = {}
local BaseWeapon =
{
    printName = "Vehicle Weapon"
}

vehicleweapon = {}
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

function vehicleweapon.GetList()
    return WeaponList
end

function vehicleweapon.Get(name)
    return WeaponList[name] or nil
end

function vehicleweapon.Call(name, fn, ...)
    local wpnTbl = vehicleweapon.Get(name)
    if not wpnTbl then return end

    local tblFn = wpnTbl[fn]
    if not tblFn then return end

    local succ, data = pcall(tblFn, ...)
    if not succ then
        print(string.format("Vehicle Weapon [%s:%s] Error: %s", name, fn, data))
        return 
    end

    return data
end

function vehicleweapon.Register(name, wpnTbl)
    setmetatable(wpnTbl, {__index = BaseWeapon})
    WeaponList[name] = wpnTbl
end
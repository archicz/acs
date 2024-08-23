if not vehicleweapon then return end

local Weapons = {}
local SelectedWeapon = 1

function vehicleseat.GetWeapons()
    if not vehicleseat.ValidSeat() then return nil end

    return Weapons
end

function vehicleseat.GetSelectedWeapon()
    if not vehicleseat.HasWeapons() then return nil end
    
    local index = vehicleseat.GetSelectedWeaponIndex()
    return Weapons[index]
end

function vehicleseat.GetSelectedWeaponIndex()
    if not vehicleseat.HasWeapons() then return nil end
    return SelectedWeapon
end

function vehicleseat.SelectWeapon(index)
    if not vehicleseat.HasWeapons() then return end

    local clampedIndex = math.Clamp(index, 1, #vehicleseat.GetWeapons())
    net.Start(vehicleweapon.NetworkString)
    net.WriteUInt(VEHICLEWEAPON_NET_SELECT, 4)
    net.WriteUInt(clampedIndex, 32)
    net.SendToServer()
end

function vehicleseat.HasWeapons()
    local wps = vehicleseat.GetWeapons()
    if not wps then return false end
    if #wps < 1 then return false end

    return true
end



function vehicleweapon.DoAction(wpnEnt, action)
    if not IsValid(wpnEnt) then return end

    local actionHandlers =
    {
        [VEHICLEWEAPON_ACTION_PRIMARY] = function()
            wpnEnt:WeaponPrimaryFire()
        end,

        [VEHICLEWEAPON_ACTION_SECONDARY] = function()
            wpnEnt:WeaponSecondaryFire()
        end,

        [VEHICLEWEAPON_ACTION_RELOADING] = function()
            wpnEnt:WeaponReloading()
        end,

        [VEHICLEWEAPON_ACTION_RELOADED] = function()
            wpnEnt:WeaponReloaded()
        end
    }

    local actionFn = actionHandlers[action]
    if actionFn then
        pcall(actionFn)
    end
end

function vehicleweapon.ServerNetwork()
    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [VEHICLEWEAPON_NET_WEAPONLIST] = function()
            Weapons = net.ReadTable()
        end,

        [VEHICLEWEAPON_NET_SELECT] = function()
            SelectedWeapon = net.ReadUInt(32)
        end,

        [VEHICLEWEAPON_NET_ACTION] = function()
            local wpnEnt = net.ReadEntity()
            local action = net.ReadUInt(32)

            vehicleweapon.DoAction(wpnEnt, action)
        end
    }

    local stateFn = stateHandlers[state]
    if stateFn then
        pcall(stateFn)
    end
end

net.Receive(vehicleweapon.NetworkString, vehicleweapon.ServerNetwork)
if not vehicleweapon then return end
util.AddNetworkString(vehicleweapon.NetworkString)

function vehicleseat.AddWeapon(seatEnt, wpnEnt)
    if not seatEnt.SeatWeapons then 
        seatEnt.SeatWeapons = {}
        seatEnt.SeatWeaponSelected = 1 
    end

    table.insert(seatEnt.SeatWeapons, wpnEnt)
end

function vehicleseat.GetWeapons(seatEnt)
    return seatEnt.SeatWeapons
end

function vehicleseat.GetSelectedWeapon(seatEnt)
    if not vehicleseat.HasWeapons(seatEnt) then return nil end
    
    local index = vehicleseat.GetSelectedWeaponIndex(seatEnt)
    return seatEnt.SeatWeapons[index]
end

function vehicleseat.GetSelectedWeaponIndex(seatEnt)
    if not vehicleseat.HasWeapons(seatEnt) then return nil end
    return seatEnt.SeatWeaponSelected
end

function vehicleseat.SelectWeapon(seatEnt, index)
    local seatOwner = seatEnt:GetRealOwner()
    if not IsValid(seatOwner) then return end

    if not vehicleseat.HasWeapons(seatEnt) then return end
    seatEnt.SeatWeaponSelected = math.Clamp(index, 1, #vehicleseat.GetWeapons(seatEnt))

    net.Start(vehicleweapon.NetworkString)
    net.WriteUInt(VEHICLEWEAPON_NET_SELECT, 4)
    net.WriteUInt(vehicleseat.GetSelectedWeaponIndex(seatEnt), 32)
    net.Send(seatOwner)
end

function vehicleseat.HasWeapons(seatEnt)
    local wps = vehicleseat.GetWeapons(seatEnt)
    if not wps then return false end
    if #wps < 1 then return false end

    return true
end



function vehicleweapon.CreateWeapon(baseEnt, seatEnt, wpnName)
    local wpnTbl = vehicleweapon.Get(wpnName)
    if not wpnTbl then return nil end
    local wpnEnt = ents.Create(vehicleweapon.ClassName)
    local wpnOwner = baseEnt:GetRealOwner()

    if IsValid(baseEnt) and not IsValid(wpnOwner) then
        wpnOwner = Entity(1)
    end

    if IsValid(wpnEnt) and IsValid(wpnOwner) then
        wpnEnt:SetPos(baseEnt:GetPos())
        wpnEnt:SetAngles(baseEnt:GetAngles())
        wpnEnt:SetParent(baseEnt)
        wpnEnt:SetRealOwner(wpnOwner)
        wpnEnt:WeaponSetup(wpnName)
        wpnEnt:Spawn()
    end

    vehicleseat.AddWeapon(seatEnt, wpnEnt)

    return wpnEnt
end

function vehicleweapon.DoAction(wpnEnt, action)
    if not IsValid(wpnEnt) then return end

    local valid = false

    local actionHandlers =
    {
        [VEHICLEWEAPON_ACTION_PRIMARY] = function()
            valid = wpnEnt:WeaponPrimaryFire()
        end,

        [VEHICLEWEAPON_ACTION_SECONDARY] = function()
            valid = wpnEnt:WeaponSecondaryFire()
        end,

        [VEHICLEWEAPON_ACTION_RELOAD] = function()
            valid = wpnEnt:WeaponReload()
        end,

        [VEHICLEWEAPON_ACTION_RELOADING] = function()
            valid = wpnEnt:WeaponReloading()
        end,

        [VEHICLEWEAPON_ACTION_RELOADED] = function()
            valid = wpnEnt:WeaponReloaded()
        end
    }

    local actionFn = actionHandlers[action]
    if actionFn then
        pcall(actionFn)
    end

    if valid then
        net.Start(vehicleweapon.NetworkString)
        net.WriteUInt(VEHICLEWEAPON_NET_ACTION, 4)
        net.WriteEntity(wpnEnt)
        net.WriteUInt(action, 32)
        net.Broadcast()
    end
end

function vehicleweapon.ControlWeapon(seatEnt, ply, cmd)
    if not IsValid(seatEnt) then return end
    if not IsValid(ply) then return end

    local wpnEnt = vehicleseat.GetSelectedWeapon(seatEnt)
    if not IsValid(wpnEnt) then return end

    if cmd:KeyDown(IN_ATTACK) then
        vehicleweapon.DoAction(wpnEnt, VEHICLEWEAPON_ACTION_PRIMARY)
    elseif cmd:KeyDown(IN_ATTACK2) then
        vehicleweapon.DoAction(wpnEnt, VEHICLEWEAPON_ACTION_SECONDARY)
    end
end

function vehicleweapon.ClientNetwork(_, ply)
    local seatEnt = ply:GetVehicleSeat()
    if not IsValid(seatEnt) then return end

    local state = net.ReadUInt(4)
    local stateHandlers =
    {
        [VEHICLEWEAPON_NET_SELECT] = function()
            local index = net.ReadUInt(32)
            if not vehicleseat.HasWeapons(seatEnt) then return end

            vehicleseat.SelectWeapon(seatEnt, index)
        end,

        [VEHICLEWEAPON_NET_ACTION] = function()
            local action = net.ReadUInt(32)
            if not vehicleseat.HasWeapons(seatEnt) then return end

            local wpnEnt = vehicleseat.GetSelectedWeapon(seatEnt)
            if not IsValid(wpnEnt) then return end

            vehicleweapon.DoAction(wpnEnt, action)
        end
    }

    local stateFn = stateHandlers[state]
    if stateFn then
        pcall(stateFn)
    end
end

function vehicleweapon.SeatEnter(seatEnt, ply)
    if not IsValid(seatEnt) then return end
    if not IsValid(ply) then return end

    if not vehicleseat.HasWeapons(seatEnt) then return end
    local wps = vehicleseat.GetWeapons(seatEnt)

    net.Start(vehicleweapon.NetworkString)
    net.WriteUInt(VEHICLEWEAPON_NET_WEAPONLIST, 4)
    net.WriteTable(wps, true)
    net.Send(ply)
end

function vehicleweapon.SeatExit(seatEnt, ply)
end

net.Receive(vehicleweapon.NetworkString, vehicleweapon.ClientNetwork)
hook.Add("OnVehicleSeatEnter", "VehicleWeaponEnter", vehicleweapon.SeatEnter)
hook.Add("OnVehicleSeatExit", "VehicleWeaponExit", vehicleweapon.SeatExit)
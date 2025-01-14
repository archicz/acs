if not vehicleweapon then return end

local Weapons = {}
local SelectedWeapon = 1

function vehicleseat.GetWeapons()
    if not vehicleseat.IsValid() then return nil end

    return Weapons
end

function vehicleseat.GetSelectedWeapon()
    if not vehicleseat.HasWeapons() then return nil end
    
    return Weapons[SelectedWeapon]
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

function vehicleseat.ControlWeaponSelection(button)
    if not vehicleseat.HasWeapons() then return end

    local seatEnt = vehicleseat.GetSeat()
    if not IsValid(seatEnt) then return end

    local wps = vehicleseat.GetWeapons()
    local selectedIndex = vehicleseat.GetSelectedWeaponIndex()

    for key = KEY_1, (KEY_9 - KEY_1) do
        local index = key - 1

        if button == key and index != selectedIndex and index <= #wps and universaltimeout.Check(seatEnt, "weaponSelect") then
            vehicleseat.SelectWeapon(index)
            universaltimeout.Attach(seatEnt, "weaponSelect", 0.5)
            surface.PlaySound("buttons/combine_button7.wav")
        end
    end
end

function vehicleseat.HasWeapons()
    local wps = vehicleseat.GetWeapons()
    if not wps then return false end
    if #wps < 1 then return false end

    return true
end



function vehicleweapon.DrawHUD()
    local wps = vehicleseat.GetWeapons()
    local numWps = #wps
    local activeWpnID = vehicleseat.GetSelectedWeaponIndex()

    local wpnBoxSize = surface.ScaleDPI(96)
    local wpnBoxPadding = surface.ScaleDPI(4)

    local wpnBoxCaptionHeight = surface.ScaleHeightDPI(16)
    local wpnBoxOutlineSize = surface.ScaleDPI(1)

    local wpnBoxesWidth = numWps * wpnBoxSize + (numWps - 1) * wpnBoxPadding
    local wpnBoxesHeight = wpnBoxSize

    local wpnBoxesX = (ScrW() / 2) - (wpnBoxesWidth / 2)
    local wpnBoxesY = ScrH() - wpnBoxesHeight - wpnBoxPadding

    local curX = wpnBoxesX
    local curY = wpnBoxesY

    for i = 1, numWps do
        surface.SetDrawColor(32, 32, 32, 225)
        surface.DrawRect(curX, curY, wpnBoxSize, wpnBoxSize)

        local wpn = wps[i]
        local wpnName = wpn:WeaponData("printName")
        local isReloading = wpn:GetIsReloading()
        
        if isReloading then
            local fracRound = wpn:WeaponReloadFraction()

            surface.SetDrawColor(140, 140, 140, 80)
            surface.DrawRect(curX, curY + wpnBoxSize - wpnBoxSize * fracRound, wpnBoxSize, 500)
        end

        if i == activeWpnID then
            surface.SetDrawColor(255, 255, 255)
        else
            surface.SetDrawColor(128, 128, 128)
        end

        surface.DrawOutlinedRect(curX, curY, wpnBoxSize, wpnBoxSize)

        local usesAmmo = wpn:WeaponUsesAmmo()
        local usesClips = wpn:WeaponUsesClips()

        if usesAmmo then
            local ammoText = ""

            if usesClips then
                ammoText = ammoText .. wpn:GetClip() .. " / "
            end

            ammoText = ammoText .. wpn:GetAmmo()

            surface.SetFont("DermaDefault")
            local tw, th = surface.GetTextSize(ammoText)

            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(
                curX + wpnBoxSize / 2 - tw / 2, 
                curY + wpnBoxSize / 2 - th / 2
            )
            surface.DrawText(ammoText)
        end
        
        surface.SetDrawColor(32, 32, 32, 175)
        surface.DrawRect(
            curX + wpnBoxOutlineSize, 
            curY + wpnBoxOutlineSize + wpnBoxSize - wpnBoxCaptionHeight, 
            wpnBoxSize - wpnBoxOutlineSize * 2, 
            wpnBoxCaptionHeight - wpnBoxOutlineSize * 2
        )

        surface.SetFont("DermaDefault")
        local tw, th = surface.GetTextSize(wpnName)

        surface.SetTextColor(255, 255, 255)
        surface.SetTextPos(
            curX + wpnBoxOutlineSize + wpnBoxSize / 2 - tw / 2, 
            curY + wpnBoxOutlineSize + wpnBoxSize - wpnBoxCaptionHeight / 2 - th / 2
        )
        surface.DrawText(wpnName)

        curX = curX + wpnBoxSize + ((i != numWps) and wpnBoxPadding or 0)
    end
end

function vehicleweapon.DoAction(wpnEnt, action)
    if not IsValid(wpnEnt) then return end

    local actionHandlers =
    {
        [VEHICLEWEAPON_ACTION_FIRE] = function()
            wpnEnt:WeaponFire()
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
            Weapons = net.ReadEntityList()
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
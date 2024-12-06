local Seat = {}

function Seat:ButtonPressed(button)
    vehicleseat.ControlWeaponSelection(button)
end

local ctx = {}

function Seat:DrawHUD()
    local heliEnt = self:GetVehicle()
    local throttle = heliEnt:GetThrottle()
    -- vehicleseat.GetEntraceAnimFraction()

    cam.Start2D()
    imgui.Context2D(ctx)
    
    imgui.ContextEnd()

        local wps = vehicleseat.GetWeapons()
        local numWps = #wps
        local activeWpnID = vehicleseat.GetSelectedWeaponIndex()

        local wpnBoxSize = 96
        local wpnBoxPadding = 4

        local wpnBoxCaptionHeight = 16
        local wpnBoxOutlineSize = 1

        local wpnBoxesWidth = numWps * wpnBoxSize + (numWps - 1) * wpnBoxPadding
        local wpnBoxesHeight = wpnBoxSize

        local wpnBoxesX = (ScrW() / 2) - (wpnBoxesWidth / 2)
        local wpnBoxesY = ScrH() - wpnBoxesHeight - wpnBoxPadding

        --surface.SetDrawColor(255, 0, 0)
        --surface.DrawRect(wpnBoxesX, wpnBoxesY, wpnBoxesWidth, wpnBoxesHeight)

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
                surface.SetTextPos(curX + wpnBoxSize / 2 - tw / 2, curY + wpnBoxSize / 2 - th / 2)
                surface.DrawText(ammoText)
            end
            
            surface.SetDrawColor(32, 32, 32, 175)
            surface.DrawRect(curX + wpnBoxOutlineSize, curY + wpnBoxOutlineSize + wpnBoxSize - wpnBoxCaptionHeight, wpnBoxSize - wpnBoxOutlineSize * 2, wpnBoxCaptionHeight - wpnBoxOutlineSize * 2)

            surface.SetFont("DermaDefault")
            local tw, th = surface.GetTextSize(wpnName)

            surface.SetTextColor(255, 255, 255)
            surface.SetTextPos(curX + wpnBoxOutlineSize + wpnBoxSize / 2 - tw / 2, curY + wpnBoxOutlineSize + wpnBoxSize - wpnBoxCaptionHeight / 2 - th / 2)
            surface.DrawText(wpnName)

            curX = curX + wpnBoxSize + ((i != numWps) and wpnBoxPadding or 0)
        end
    cam.End2D()
end

function Seat:CreateMove(cmd)
end

return Seat
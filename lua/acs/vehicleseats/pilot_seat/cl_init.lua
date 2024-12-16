local Seat = {}

function Seat:ButtonPressed(button)
    vehicleseat.ControlWeaponSelection(button)
end

function Seat:DrawHUD()
    local heliEnt = self:GetVehicle()
    local throttle = heliEnt:GetThrottle()
    -- vehicleseat.GetEntraceAnimFraction()

    cam.Start2D()
    vehicleweapon.DrawHUD()
    cam.End2D()
end

function Seat:CreateMove(cmd)
end

return Seat
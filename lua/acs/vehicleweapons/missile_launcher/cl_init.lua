local Weapon = {}

function Weapon:Reloaded()
    self:EmitSound("acs/vehicle_weapons/missile_launcher/reload.wav")
end

function Weapon:Fire()
    self:EmitSound("acs/vehicle_weapons/missile_launcher/fire" .. math.random(1, 3) .. ".wav")
end

return Weapon
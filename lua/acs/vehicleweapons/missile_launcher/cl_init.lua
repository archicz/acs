local Weapon = {}

function Weapon:Initialize()
end

function Weapon:Think()
end

function Weapon:Reloaded()
    self:EmitSound("acs/vehicle_weapons/missile_launcher/reload.wav")
end

function Weapon:PrimaryFire()
    self:EmitSound("acs/vehicle_weapons/missile_launcher/fire" .. math.random(1, 3) .. ".wav")
end

function Weapon:SecondaryFire()
end

return Weapon
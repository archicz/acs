local Weapon = {}

function Weapon:Initialize()
    self.ParticleEmitter = ParticleEmitter(self:GetPos())
end

function Weapon:Think()
end

function Weapon:Reloaded()
    self:EmitSound("acs/vehicle_weapons/autocannon/reload.wav")
end

function Weapon:Fire()
    self:EmitSound("acs/vehicle_weapons/autocannon/fire" .. math.random(1, 4) .. ".wav")
end

function Weapon:OnRemove()
    if self.ParticleEmitter then
        self.ParticleEmitter:Finish()
    end
end

return Weapon
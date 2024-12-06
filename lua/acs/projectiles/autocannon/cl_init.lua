local Projectile = {}

function Projectile:OnCreated()
    self.Emitter = ParticleEmitter(self:GetPos())

    local size = 30
    local len = 1

    self.Particle = self.Emitter:Add("acs/bullet_tracer", self:GetPos())
    self.Particle:SetDieTime(1)
    self.Particle:SetStartAlpha(255)
    self.Particle:SetEndAlpha(255)
    self.Particle:SetStartSize(size)
    self.Particle:SetEndSize(size)
    self.Particle:SetStartLength(len)
    self.Particle:SetEndLength(len)
    self.Particle:SetVelocity(self:GetVelocity())
    self.Particle:SetColor(0, 255, 0)
end

function Projectile:OnRemove()
end

function Projectile:Draw()
    local len = math.max(self:GetDeltaPos():Length() * 2, 1)

    self.Particle:SetDieTime(5)
    self.Particle:SetStartLength(len)
    self.Particle:SetEndLength(len)
    self.Particle:SetPos(self:GetPos())
    self.Particle:SetAngles(self:GetDeltaPos():Angle())
    self.Particle:SetVelocity(self:GetVelocity())
end

return Projectile
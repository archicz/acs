include("shared.lua")

function ENT:Initialize()
    self.Emitter = ParticleEmitter(self:GetPos())
end

function ENT:Draw()
    self:DrawModel()

    for i = 1, 2 do
        local part = self.Emitter:Add("effects/yellowflare", self:GetPos())
        part:SetDieTime(0.25)
        part:SetColor(255, 191, 0)
    
        part:SetStartAlpha(255)
        part:SetEndAlpha(0)

        part:SetStartSize(4)
        part:SetEndSize(0)

        part:SetGravity(Vector( 0, 0, -250 ))
        part:SetVelocity(VectorRand() * 50)
    end
end

function ENT:OnRemove()
    if self.Emitter then
        self.Emitter:Finish()
    end
end
include("shared.lua")

ENT.MissileSound = nil

function ENT:Initialize()
end

function ENT:Think()
    if self:GetLaunched() then
        if not self.MissileSound then 
            self.MissileSound = CreateSound(self, "Missile.Ignite")
            self.MissileSound:Play()

            local propellerFlashAttachment = self:LookupAttachment("propeller_flash")
            ParticleEffectAttach("Rocket_Start_Flash", PATTACH_POINT, self, propellerFlashAttachment)
        
            local propellerAttachment = self:LookupAttachment("propeller")
            ParticleEffectAttach("Rocket_Propeller", PATTACH_POINT_FOLLOW, self, propellerAttachment)
            ParticleEffectAttach("Rocket_SmokeTrail", PATTACH_POINT_FOLLOW, self, propellerAttachment)
        end
    end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
    if self.MissileSound then
        self.MissileSound:Stop()
    end
end
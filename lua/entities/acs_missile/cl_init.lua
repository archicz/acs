include("shared.lua")

ENT.MissileSound = nil
ENT.MissileTrailParticle = nil
ENT.MissilePropellerParticle = nil

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
            self.MissilePropellerParticle = CreateParticleSystem(self, "Rocket_Propeller", PATTACH_POINT_FOLLOW, propellerAttachment)
            self.MissileTrailParticle = CreateParticleSystem(self, "Rocket_SmokeTrail", PATTACH_POINT_FOLLOW, propellerAttachment)
        end
    end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
    if self.MissileSound then
        self.MissileSound:Stop()

        self.MissilePropellerParticle:StopEmission(false, true)
        self.MissileTrailParticle:StopEmission(false, false)
    end
end
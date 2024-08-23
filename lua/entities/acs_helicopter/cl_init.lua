include("shared.lua")

function ENT:Initialize()
    if not IsValid(self.EngineSound) then
        self.EngineSound = CreateSound(self, self:HeliData("rotorSound"))
    end

    self:HeliCall("Initialize")
end

function ENT:HeliUpdateSound()
    local throttle = self:GetThrottle() * 100
    local collective = self:GetCollective() * 10
    local enginePitch = math.floor(throttle + collective)

    if enginePitch > 0 then
        self.EngineSound:Play()
        self.EngineSound:ChangePitch(enginePitch, 0)
    else
        self.EngineSound:Stop()
    end
end

function ENT:Think()
    self:HeliUpdateSound()
    self:HeliCall("Think")
end

function ENT:Draw()
	self:DrawModel()
    self:HeliCall("Draw")
end

function ENT:OnRemove()
    if self.EngineSound then
        self.EngineSound:Stop()
        self.EngineSound = nil
    end
end
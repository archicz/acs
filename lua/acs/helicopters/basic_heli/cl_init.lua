local Heli = {}

function Heli:Initialize()
    self.MainRotor = self:FindPACPart(self:PACModelGetOutfit(), "main_rotor")
    self.TailRotor = self:FindPACPart(self:PACModelGetOutfit(), "tail_rotor")

    if not IsValid(self.EngineSound) then
        self.EngineSound = CreateSound(self, "NPC_AttackHelicopter.Rotors")
    end
end

function Heli:Think()
    local throttle = self:GetThrottle()
    local collective = self:GetCollective()
    local cyclic = self:GetCyclic()

    local enginePitch = math.floor(throttle * 100 + collective * 10)
    
    if enginePitch > 0 then
        self.EngineSound:Play()
        self.EngineSound:ChangePitch(enginePitch, 0)
    else
        self.EngineSound:Stop()
    end

    self.MainRotor:SetAngles(Angle(0, self:HeliMainRotorAng(), 0))
    self.TailRotor:SetAngles(Angle(self:HeliTailRotorAng(), 0, 90))
end

function Heli:Draw()

end

function Heli:OnRemove()
    if self.EngineSound then
        self.EngineSound:Stop()
        self.EngineSound = nil
    end
end

return Heli
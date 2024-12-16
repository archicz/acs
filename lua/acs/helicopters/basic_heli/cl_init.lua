local Heli = {}

function Heli:Initialize()
    self.RotorBone = self:LookupBone("Chopper.Rotor_Blur")
    self.TailBone = self:LookupBone("Chopper.Tail")
    self.RotorTailBone = self:LookupBone("Chopper.Blade_Tail")
    self.RotorHullBone = self:LookupBone("Chopper.Blade_Hull")
    self.RotorAng = 0
    self.TailAng = 0

    if not IsValid(self.EngineSound) then
        self.EngineSound = CreateSound(self, "NPC_AttackHelicopter.Rotors")
    end
end

function Heli:Think()
    if self:IsDormant() then return end

    local throttle = self:GetThrottle()
    local collective = self:GetCollective()
    local cyclic = self:GetCyclic()
    
    local rotorThrottle = throttle * 10
    local rotorCollective = (collective > 0) and collective * 2 or 0

    local rotorAng = self.RotorAng
    local newRotorAng = rotorAng + rotorThrottle + rotorCollective

    local enginePitch = math.floor(throttle * 100 + collective * 10)
    if enginePitch > 0 then
        self.EngineSound:Play()
        self.EngineSound:ChangePitch(enginePitch, 0)
    else
        self.EngineSound:Stop()
    end

    self.RotorAng = newRotorAng % 360
    self.TailAng = cyclic.y * 45
end

function Heli:Draw()
    self:DrawModel()

    self:ManipulateBoneAngles(self.RotorBone, Angle(self.RotorAng, 0, 0), true)
    self:ManipulateBoneAngles(self.RotorTailBone, Angle(0, 0, self.RotorAng), true)
    self:ManipulateBoneAngles(self.RotorHullBone, Angle(0, 0, self.RotorAng), true)
    self:ManipulateBoneAngles(self.TailBone, Angle(0, self.TailAng, 0), true)
end

function Heli:OnRemove()
    if self.EngineSound then
        self.EngineSound:Stop()
        self.EngineSound = nil
    end
end

return Heli
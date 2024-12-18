DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Helicopter"
ENT.Author = "archi"
ENT.Information = ""
ENT.Category = "ACS"

ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:HeliData(key)
    local name = self:GetHeliName()
    local heliTbl = helisystem.Get(name)
    return heliTbl[key] or nil
end

function ENT:HeliCall(fn, ...)
    local name = self:GetHeliName()
    helisystem.Call(name, fn, self, ...)
end

function ENT:HeliActive()
    return not (self:GetThrottle() < 1)
end

function ENT:HeliUpdateRotors()
    if not self.RotorAng then self.RotorAng = 0 end

    local throttle = self:GetThrottle()
    local collective = self:GetCollective()

    local rotorAng = self.RotorAng
    local rotorThrottle = throttle * 10
    local rotorCollective = (collective > 0) and collective * 2 or 0
    local newRotorAng = rotorAng + rotorThrottle + rotorCollective

    self.RotorAng = newRotorAng % 360
end

function ENT:HeliMainRotorAng()
    return self.RotorAng or 0
end

function ENT:HeliTailRotorAng()
    local cyclic = self:GetCyclic()
    return (self.RotorAng + cyclic.y * 45)
end

function ENT:SetupDataTables()
    self:NetworkVar("String", "HeliName")
    self:NetworkVar("Float", "Collective")
    self:NetworkVar("Float", "Throttle")
    self:NetworkVar("Angle", "Cyclic")
end
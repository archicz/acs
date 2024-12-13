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

function ENT:SetupDataTables()
    self:NetworkVar("String", "HeliName")
    self:NetworkVar("Float", "Collective")
    self:NetworkVar("Float", "Throttle")
    self:NetworkVar("Angle", "Cyclic")
end
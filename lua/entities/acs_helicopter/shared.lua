DEFINE_BASECLASS("acs_vehiclebase")

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
    self:NetworkVar("String", 0, "HeliName")

    self:NetworkVar("Float", 0, "Collective")
    self:NetworkVar("Float", 1, "Throttle")

    self:NetworkVar("Angle", 0, "Cyclic")
end
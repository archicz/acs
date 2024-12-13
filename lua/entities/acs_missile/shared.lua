DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Missile"
ENT.Author = "archi"
ENT.Information = ""
ENT.Category = "ACS"

ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:MissileData(key)
    local name = self:GetMissileName()
    local missileTbl = missilesystem.Get(name)
    return missileTbl[key] or nil
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", "Launched")
    self:NetworkVar("Entity", "Launcher")
    self:NetworkVar("String", "MissileName")
end
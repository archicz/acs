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
    self:NetworkVar("Bool", 0, "Launched")
    
    self:NetworkVar("Entity", 0, "Launcher")
    self:NetworkVar("Entity", 1, "GuidanceTarget")
    
    self:NetworkVar("String", 0, "MissileName")
end
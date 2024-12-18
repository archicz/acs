include("shared.lua")

function ENT:Initialize()
    pacmodel.SetupEntity(self)
    self:PACModelCreate(self:WeaponData("pacMdl"))
    
    self:WeaponCall("Initialize")
end

function ENT:WeaponReloading()
    self:WeaponCall("Reloading")
end

function ENT:WeaponReloaded()
    self:WeaponCall("Reloaded")
end

function ENT:WeaponFire()
    self:WeaponCall("Fire")
end

function ENT:Think()
    self:WeaponCall("Think")
end

function ENT:Draw()
    self:WeaponCall("Draw")
end

function ENT:OnRemove()
    self:PACModelRemoveOutfit()
    self:WeaponCall("OnRemove")
end
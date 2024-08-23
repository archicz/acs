include("shared.lua")

pac.SetupENT(ENT)

function ENT:Initialize()
    local pacOutfit = self:WeaponData("pacOutfit")
    if not pacOutfit then return end

    self:AttachPACPart(pacOutfit)
    self:WeaponCall("Initialize", self)
end

function ENT:WeaponReloading()
    self:WeaponCall("Reloading", self)
end

function ENT:WeaponReloaded()
    self:WeaponCall("Reloaded", self)
end

function ENT:WeaponPrimaryFire()
    self:WeaponCall("PrimaryFire", self)
end

function ENT:WeaponSecondaryFire()
    self:WeaponCall("SecondaryFire", self)
end

function ENT:Think()
    self:WeaponCall("Think", self)
end

function ENT:Draw()
    self:WeaponCall("Draw", self)
end

function ENT:OnRemove()
    local pacOutfit = self:WeaponData("pacOutfit")
    if not pacOutfit then return end

    self:RemovePACPart(pacOutfit)
    self:WeaponCall("OnRemove", self)
end
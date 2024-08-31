include("shared.lua")

pac.SetupENT(ENT)

function ENT:Initialize()
    local pacOutfit = self:WeaponData("pacOutfit")
    if not pacOutfit then return end

    self:AttachPACPart(pacOutfit)
    self:WeaponCall("Initialize")
end

function ENT:WeaponReloading()
    self:WeaponCall("Reloading")
end

function ENT:WeaponReloaded()
    self:WeaponCall("Reloaded")
end

function ENT:WeaponPrimaryFire()
    self:WeaponCall("PrimaryFire")
end

function ENT:WeaponSecondaryFire()
    self:WeaponCall("SecondaryFire")
end

function ENT:Think()
    self:WeaponCall("Think")
end

function ENT:Draw()
    self:WeaponCall("Draw")
end

function ENT:OnRemove()
    local pacOutfit = self:WeaponData("pacOutfit")
    if not pacOutfit then return end

    self:RemovePACPart(pacOutfit)
    self:WeaponCall("OnRemove")
end
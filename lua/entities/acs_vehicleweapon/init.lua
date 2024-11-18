AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
    self:WeaponCall("Initialize")
end

function ENT:WeaponSetup(wpnName)
    self:SetWeaponName(wpnName)

    local seatEnt = self:GetParent()
    if not IsValid(seatEnt) then
        SafeRemoveEntity(self)
    end

    self:WeaponAddAmmo(self:WeaponData("defaultAmmo"))
end

function ENT:WeaponClipReload()
    local clip = self:GetClip()
    local clipRemaining = self:WeaponData("clipSize") - clip
    local ammo = self:GetAmmo()
    local ammoToTake = math.Clamp(clipRemaining, 0, ammo)

    self:WeaponAddAmmo(-ammoToTake)
    self:WeaponAddClip(ammoToTake)
end

function ENT:WeaponTakeAmmo(amount)
    if not amount then amount = 1 end

    if self:WeaponUsesClips() then
        self:WeaponAddClip(-amount)
    else
        self:WeaponAddAmmo(-amount)
    end
end

function ENT:WeaponAddClip(amount)
    local desiredClip = self:GetClip() + amount
    local clipSize = self:WeaponData("clipSize")
    local newClip = math.Clamp(desiredClip, 0, clipSize)

    self:SetClip(newClip)
end

function ENT:WeaponAddAmmo(amount)
    local desiredAmmo = self:GetAmmo() + amount
    local maxAmmo = self:WeaponData("maxAmmo")
    local newAmmo = math.Clamp(desiredAmmo, 0, maxAmmo)

    self:SetAmmo(newAmmo)
end

function ENT:WeaponReload()
    if not self:GetIsReloading() then
        self:SetReloadTime(CurTime() + self:WeaponData("reloadDelay"))
        self:SetIsReloading(true)
        vehicleweapon.DoAction(self, VEHICLEWEAPON_ACTION_RELOADING)

        return true
    end

    return false
end

function ENT:WeaponReloading()
    self:WeaponCall("Reloading")
    return true
end

function ENT:WeaponReloaded()
    self:WeaponCall("Reloaded")
    return true
end

function ENT:WeaponPrimaryFire()
    local nextPrimary = self:GetNextPrimaryFire()
    local canPrimary = self:WeaponCanPrimary()

    if CurTime() >= nextPrimary and canPrimary then
        self:WeaponCall("PrimaryFire")
        self:SetNextPrimaryFire(CurTime() + self:WeaponData("primaryFireRate"))
        
        return true
    end

    return false
end

function ENT:WeaponSecondaryFire()
    local nextSecondary = self:GetNextSecondaryFire()
    if CurTime() >= nextSecondary then
        self:WeaponCall("SecondaryFire")

        self:SetNextSecondaryFire(CurTime() + self:WeaponData("secondaryFireRate"))
        return true
    end

    return false
end

function ENT:Think()
    self:WeaponCall("Think")

    if self:GetIsReloading() then
        local reloadTime = self:GetReloadTime()
        if CurTime() >= reloadTime then
            self:SetIsReloading(false)
            vehicleweapon.DoAction(self, VEHICLEWEAPON_ACTION_RELOADED)
        end
    end

    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    self:WeaponCall("OnRemove")
end
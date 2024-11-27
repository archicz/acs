DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Vehicle Weapon"
ENT.Author = "archi"
ENT.Information = ""
ENT.Category = "ACS"

ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:GetVehicle()
    local vehicleEnt = self:GetParent()
    if not IsValid(vehicleEnt) then return nil end

    return vehicleEnt
end

function ENT:WeaponData(key)
    local name = self:GetWeaponName()
    local wpnTbl = vehicleweapon.Get(name)
    return wpnTbl[key] or nil
end

function ENT:WeaponCall(fn, ...)
    local name = self:GetWeaponName()
    vehicleweapon.Call(name, fn, self, ...)
end

function ENT:WeaponUsesAmmo()
    local maxAmmo = self:WeaponData("maxAmmo") or 0
    return (maxAmmo > 0)
end

function ENT:WeaponUsesClips()
    local clipSize = self:WeaponData("clipSize") or 0
    return (clipSize > 0)
end

function ENT:WeaponCanPrimary()
    if self:WeaponUsesClips() then
        return (self:GetClip() > 0)
    else
        return (self:GetAmmo() > 0)
    end
end

function ENT:WeaponNeedsReload()
    if not self:WeaponUsesClips() then return false end
    return (self:GetClip() == 0) && self:WeaponCanReload()
end

function ENT:WeaponCanReload()
    if not self:WeaponUsesClips() then return false end
    return (self:GetAmmo() > 0)
end

function ENT:WeaponCanAutoReload()
    local reloadAuto = self:WeaponData("reloadAuto") or false
    return reloadAuto
end

function ENT:WeaponReloadFraction()
    local reloadTime = self:GetReloadTime()
    local reloadDelay = self:WeaponData("reloadDelay")
    local remainingReloadFrac = 1 - (reloadTime - CurTime()) / reloadDelay
    local fracRound = math.Round(remainingReloadFrac, 2)

    return fracRound
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "WeaponName")

    self:NetworkVar("Float", 0, "NextPrimaryFire")
    self:NetworkVar("Float", 1, "NextSecondaryFire")
    self:NetworkVar("Float", 2, "ReloadTime")

    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Int", 1, "Clip")

    self:NetworkVar("Bool", 0, "IsReloading")
end
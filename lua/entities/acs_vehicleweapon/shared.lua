DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Vehicle Weapon"
ENT.Author = "archi"
ENT.Information = ""
ENT.Category = "ACS"

ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:WeaponData(key)
    local name = self:GetWeaponName()
    local wpnTbl = vehicleweapon.Get(name)
    return wpnTbl[key]
end

function ENT:WeaponCall(fn, ...)
    local name = self:GetWeaponName()
    vehicleweapon.Call(name, fn, self, ...)
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "WeaponName")

    self:NetworkVar("Float", 0, "NextPrimaryFire")
    self:NetworkVar("Float", 1, "NextSecondaryFire")
    self:NetworkVar("Float", 2, "ReloadTime")

    self:NetworkVar("Int", 0, "Ammo")

    self:NetworkVar("Bool", 0, "IsReloading")
end
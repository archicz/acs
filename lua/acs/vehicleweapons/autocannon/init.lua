local Weapon = {}

function Weapon:Initialize()
end

function Weapon:Reloaded()
    self:WeaponClipReload()
end

function Weapon:PrimaryFire()
    local muzzlePos = self:WeaponData("muzzlePos")
    local projectileDir = self:GetForward()
    local projectileSpeed = 32000
    local projectileSpread = Angle(0.25, 0.25, 0)
    local projectileVelocity = projectilesystem.MakeVelocity(projectileDir, projectileSpeed, projectileSpread)

    local proj = projectilesystem.CreateProjectile(self, muzzlePos, projectileVelocity, "autocannon")
    self:WeaponTakeAmmo(1)
end

function Weapon:SecondaryFire()
end

return Weapon
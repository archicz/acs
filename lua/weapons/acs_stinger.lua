SWEP.Base 	= "weapon_base"
SWEP.PrintName = "Stinger"
SWEP.Author = "archi"
SWEP.Information = ""
SWEP.Category = "ACS"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_rpg.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.Ammo = "RPG_Round"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true

function SWEP:Initialize()
	self:SetHoldType("rpg")
end

function SWEP:PrimaryAttack()
    self:EmitSound("Weapon_RPG.Single")

    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:SetNextPrimaryFire(CurTime() + 0.1)

    if SERVER then
        local owner = self:GetOwner()
        local eyePos = owner:EyePos()
        local eyeAng = owner:EyeAngles()

        local missilePos = eyePos + eyeAng:Forward() * 12 + eyeAng:Right() * 6 + eyeAng:Up() * -3
        local missileAng = eyeAng

        local missile = missilesystem.SpawnMissileStandalone(self, missilePos, missileAng, "stinger")

        local phys = missile:GetPhysicsObject()
        local vel = owner:GetVelocity():Length()

        phys:ApplyForceCenter(eyeAng:Forward() * (300 + vel * 3) + Vector( 0,0, 128 ))

        timer.Simple(0.25, function()
            missilesystem.SetGuidanceTarget(missile, self.Target)
            missilesystem.LaunchMissile(missile)
        end)
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 1)

    if SERVER then
        local owner = self:GetOwner()
        local aimEntity = owner:GetEyeTrace().Entity

        if IsValid(aimEntity) then
            self.Target = aimEntity
            self:EmitSound("npc/roller/remote_yes.wav")
        end
    end
end
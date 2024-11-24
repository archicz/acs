local PilotSeat =
{
    mdl = "models/nova/jeep_seat.mdl",
    solid = false,
    visible = false,

    animatedEntrance = true,
    entranceDuration = 0.75,

    viewPos = Vector(-0.0002, 2.0001, 37.2230),
    viewAng = Angle(0, 90, 0),

    freelook = true,
    freelookKey = true,
    freelookYawMin = -40,
    freelookYawMax = 40,
    freelookPitchMix = -40,
    freelookPitchMax = 20,
}

if CLIENT then
    function PilotSeat:ButtonPressed(button)
        vehicleseat.ControlWeaponSelection(button)
    end

    local ctx = {}

    function PilotSeat:DrawHUD()
        local heliEnt = self:GetVehicle()
        local throttle = heliEnt:GetThrottle()
        -- vehicleseat.GetEntraceAnimFraction()

        cam.Start2D()
        imgui.Context2D(ctx)
        
        imgui.ContextEnd()

            local wps = vehicleseat.GetWeapons()
            local numWps = #wps
            local activeWpnID = vehicleseat.GetSelectedWeaponIndex()

            local wpnBoxSize = 96
            local wpnBoxPadding = 4

            local wpnBoxCaptionHeight = 16
            local wpnBoxOutlineSize = 1

            local wpnBoxesWidth = numWps * wpnBoxSize + (numWps - 1) * wpnBoxPadding
            local wpnBoxesHeight = wpnBoxSize

            local wpnBoxesX = (ScrW() / 2) - (wpnBoxesWidth / 2)
            local wpnBoxesY = ScrH() - wpnBoxesHeight - wpnBoxPadding

            --surface.SetDrawColor(255, 0, 0)
            --surface.DrawRect(wpnBoxesX, wpnBoxesY, wpnBoxesWidth, wpnBoxesHeight)

            local curX = wpnBoxesX
            local curY = wpnBoxesY

            for i = 1, numWps do
                surface.SetDrawColor(32, 32, 32, 225)
                surface.DrawRect(curX, curY, wpnBoxSize, wpnBoxSize)

                local wpn = wps[i]
                local wpnName = wpn:WeaponData("printName")
                local isReloading = wpn:GetIsReloading()
                
                if isReloading then
                    local fracRound = wpn:WeaponReloadFraction()

                    surface.SetDrawColor(140, 140, 140, 80)
                    surface.DrawRect(curX, curY + wpnBoxSize - wpnBoxSize * fracRound, wpnBoxSize, 500)
                end

                if i == activeWpnID then
                    surface.SetDrawColor(255, 255, 255)
                else
                    surface.SetDrawColor(128, 128, 128)
                end

                surface.DrawOutlinedRect(curX, curY, wpnBoxSize, wpnBoxSize)

                local usesAmmo = wpn:WeaponUsesAmmo()
                local usesClips = wpn:WeaponUsesClips()

                if usesAmmo then
                    local ammoText = ""

                    if usesClips then
                        ammoText = ammoText .. wpn:GetClip() .. " / "
                    end

                    ammoText = ammoText .. wpn:GetAmmo()

                    surface.SetFont("DermaDefault")
                    local tw, th = surface.GetTextSize(ammoText)
    
                    surface.SetTextColor(255, 255, 255)
                    surface.SetTextPos(curX + wpnBoxSize / 2 - tw / 2, curY + wpnBoxSize / 2 - th / 2)
                    surface.DrawText(ammoText)
                end
                
                surface.SetDrawColor(32, 32, 32, 175)
                surface.DrawRect(curX + wpnBoxOutlineSize, curY + wpnBoxOutlineSize + wpnBoxSize - wpnBoxCaptionHeight, wpnBoxSize - wpnBoxOutlineSize * 2, wpnBoxCaptionHeight - wpnBoxOutlineSize * 2)

                surface.SetFont("DermaDefault")
                local tw, th = surface.GetTextSize(wpnName)

                surface.SetTextColor(255, 255, 255)
                surface.SetTextPos(curX + wpnBoxOutlineSize + wpnBoxSize / 2 - tw / 2, curY + wpnBoxOutlineSize + wpnBoxSize - wpnBoxCaptionHeight / 2 - th / 2)
                surface.DrawText(wpnName)

                curX = curX + wpnBoxSize + ((i != numWps) and wpnBoxPadding or 0)
            end
        cam.End2D()
    end

    function PilotSeat:CreateMove(cmd)
    end
end

if SERVER then
    function PilotSeat:StartCommand(cmd)
        if vehicleseat.IsFreelooking(self) then return end

        local heliEnt = self:GetParent()
        if not IsValid(heliEnt) then return end

        helisystem.ControlHeli(heliEnt, cmd)
        vehicleseat.ControlWeapon(self, cmd)
    end

    function PilotSeat:OnEnter(ply)
        local heliEnt = self:GetParent()
        if not IsValid(heliEnt) then return end

        heliEnt:HeliStart()
    end
    
    function PilotSeat:OnExit(ply)
        local heliEnt = self:GetParent()
        if not IsValid(heliEnt) then return end

        heliEnt:HeliStop()
    end
end

local CombineHeli =
{
    mdl = "models/Combine_Helicopter.mdl",
    seats =
    {
        {
            name = "combine_heli_pilot",
            pos = Vector(142, 0, -50),
            ang = Angle(0, -90, 0),
            weapons =
            {
                "autocannon",
                "missile_launcher"
            }
        }
    },

    rotorSound = "NPC_AttackHelicopter.Rotors",
    
    throttleStrength = 0.25,

    altitudeStrength = 1,
    altitudeForce = 1.75,
    altitudeFactor = 400,
    normalizerFactor = 1000,
    
    collectiveStrength = 2,
    collectiveForce = 1.75,

    cyclicStrength = 10
}

if CLIENT then
    function CombineHeli:Initialize()
        self.RotorBone = self:LookupBone("Chopper.Rotor_Blur")
        self.TailBone = self:LookupBone("Chopper.Tail")
        self.RotorTailBone = self:LookupBone("Chopper.Blade_Tail")
        self.RotorHullBone = self:LookupBone("Chopper.Blade_Hull")
        self.RotorAng = 0
        self.TailAng = 0
    end

    function CombineHeli:Think()
        if self:IsDormant() then return end

        local throttle = self:GetThrottle()
        local collective = self:GetCollective()
        local cyclic = self:GetCyclic()
        
        local rotorThrottle = throttle * 10
        local rotorCollective = (collective > 0) and collective * 2 or 0

        local rotorAng = self.RotorAng
        local newRotorAng = rotorAng + rotorThrottle + rotorCollective

        self.RotorAng = newRotorAng % 360
        self.TailAng = cyclic.y * 45
    end

    function CombineHeli:Draw()    
        self:ManipulateBoneAngles(self.RotorBone, Angle(self.RotorAng, 0, 0), true)
        self:ManipulateBoneAngles(self.RotorTailBone, Angle(0, 0, self.RotorAng), true)
        self:ManipulateBoneAngles(self.RotorHullBone, Angle(0, 0, self.RotorAng), true)
        self:ManipulateBoneAngles(self.TailBone, Angle(0, self.TailAng, 0), true)
    end
end

if SERVER then
    function CombineHeli:Initialize()
        self:SetSubMaterial(1, "models/effects/vol_light001")
    end 
end

local MissileLauncher =
{
    printName = "Missile Launcher",

    origins =
    {
        {
            pos = Vector(21, -64, -71),
            ang = Angle(0, 0, 0)
        },
        {
            pos = Vector(21, 64, -71),
            ang = Angle(0, 0, 0)
        }
    },

    missileName = "stinger",

    maxAmmo = 16,
    defaultAmmo = 16,
    clipSize = 2,

    primaryFireRate = 0.5,
    secondaryFireRate = 0.1,

    reloadDelay = 5
}

if SERVER then
    function MissileLauncher:SpawnRockets()
        local clip = self:GetClip()
        local origins = self:WeaponData("origins")
        local missileName = self:WeaponData("missileName")
        
        for i = 1, clip do
            local origin = origins[i]

            self.Missiles[i] = missilesystem.SpawnMissile(
                self, 
                origin["pos"], 
                origin["ang"], 
                missileName
            )
        end
    end

    function MissileLauncher:Initialize()
        self.Missiles = {}
        self:WeaponReload()
    end

    function MissileLauncher:Reloaded()
        self:WeaponClipReload()
        self:WeaponCall("SpawnRockets")
    end
    
    function MissileLauncher:PrimaryFire()
        local clip = self:GetClip()

        missilesystem.LaunchMissile(self.Missiles[clip])
        self.Missiles[clip] = nil
        self:WeaponTakeAmmo(1)

        if self:WeaponNeedsReload() then
            self:WeaponReload()
        end
    end

    function MissileLauncher:SecondaryFire()
    end
end

if CLIENT then
    function MissileLauncher:Initialize()
    end

    function MissileLauncher:Think()
    end

    function MissileLauncher:Reload()
        self:EmitSound("acs/vehicle_weapons/missile_launcher/reload.wav")
    end

    function MissileLauncher:PrimaryFire()
        self:EmitSound("acs/vehicle_weapons/missile_launcher/fire" .. math.random(1, 3) .. ".wav")
    end

    function MissileLauncher:SecondaryFire()
    end
end

local AutocannonProjectile = 
{
    dragCoef = 0.005
}

if CLIENT then
    function AutocannonProjectile:OnCreated()
        self.Emitter = ParticleEmitter(self:GetPos())

        local Size = 30
        local Length = 1

        self.Particle = self.Emitter:Add("acs/bullet_tracer", self:GetPos())
		self.Particle:SetDieTime(1)
		self.Particle:SetStartAlpha(255)
		self.Particle:SetEndAlpha(255)
		self.Particle:SetStartSize(Size)
		self.Particle:SetEndSize(Size)
        self.Particle:SetStartLength(Length)
        self.Particle:SetEndLength(Length)
		self.Particle:SetVelocity(self:GetVelocity())
        self.Particle:SetColor(0, 255, 0)
    end

    function AutocannonProjectile:OnRemove()
    end

    function AutocannonProjectile:Draw()
        local Length = math.max(self:GetDeltaPos():Length() * 2, 1)

        self.Particle:SetDieTime(5)
        self.Particle:SetStartLength(Length)
        self.Particle:SetEndLength(Length)
        self.Particle:SetPos(self:GetPos())
        self.Particle:SetAngles(self:GetDeltaPos():Angle())
        self.Particle:SetVelocity(self:GetVelocity())
    end
end

if SERVER then
    function AutocannonProjectile:OnImpactWorld(trace)
        local effectdata = EffectData()
        effectdata:SetOrigin(trace.HitPos)
        effectdata:SetScale(100)
        effectdata:SetMagnitude(800)
        util.Effect("Explosion", effectdata)
    end
end

local Autocannon =
{
    printName = "Autocannon",

    muzzlePos = Vector(203, 4, -83),

    maxAmmo = 800,
    defaultAmmo = 800,
    clipSize = 40,

    primaryFireRate = 0.1,
    secondaryFireRate = 0.1,

    reloadDelay = 3.5
}

if SERVER then
    function Autocannon:Initialize()
        self:WeaponReload()
    end

    function Autocannon:Reloaded()
        self:WeaponClipReload()
    end
    
    function Autocannon:PrimaryFire()
        local muzzlePos = self:WeaponData("muzzlePos")
        local projectileDir = self:GetForward()
        local projectileSpeed = 10000
        local projectileSpread = Angle(0.25, 0.25, 0)
        local projectileVelocity = projectilesystem.MakeVelocity(projectileDir, projectileSpeed, projectileSpread)

        local proj = projectilesystem.CreateProjectile(self, muzzlePos, projectileVelocity, "autocannon")
        self:WeaponTakeAmmo(1)

        if self:WeaponNeedsReload() then
            self:WeaponReload()
        end
    end

    function Autocannon:SecondaryFire()
    end
end

if CLIENT then
    function Autocannon:Initialize()
        self.ParticleEmitter = ParticleEmitter(self:GetPos())
    end

    function Autocannon:OnRemove()
        if self.ParticleEmitter then
            self.ParticleEmitter:Finish()
        end
    end

    function Autocannon:Think()
    end

    function Autocannon:Reload()
        self:EmitSound("acs/vehicle_weapons/autocannon/reload.wav")
    end
    
    function Autocannon:PrimaryFire()
        self:EmitSound("acs/vehicle_weapons/autocannon/fire" .. math.random(1, 4) .. ".wav")
    end

    function Autocannon:SecondaryFire()
    end
end

local StingerMissile =
{
    speedDuration = 2,
    speedMax = 2400,

    blastDamage = 140,
    blastDistance = 400,
    
    guided = true,
    predicts = true,
    angDiff = 75,
    angMul = 40,

    mdl = "models/acs/missiles/default.mdl"
}

missilesystem.Register("stinger", StingerMissile)
vehicleseat.Register("combine_heli_pilot", PilotSeat)
helisystem.Register("combine_heli", CombineHeli)
vehicleweapon.Register("missile_launcher", MissileLauncher)
vehicleweapon.Register("autocannon", Autocannon)
projectilesystem.Register("autocannon", AutocannonProjectile)
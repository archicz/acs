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
    function PilotSeat.HUDPaint(seatEnt)
    end

    function PilotSeat.PostDrawOpaqueRenderables(seatEnt)
        local heliEnt = seatEnt:GetParent()
        if not IsValid(heliEnt) then return end

        local hudPos = seatEnt:LocalToWorld(vehicleseat.GetLookPos() + Vector(0, 20, 0))
        local hudAng = seatEnt:LocalToWorldAngles(Angle(0, 0, 90))

        local throttle = heliEnt:GetThrottle()

        local function applyBloom(rt)
            render.BloomRenderTarget(rt, 0.5, 0.5, 2, 10, 0)
        end

        cam.Start3DUI(hudPos, hudAng, 0.03, applyBloom)
            render.Clear(0, 0, 0, 0, true, true)

            --surface.SetDrawColor(255, 255, 255)
            --surface.DrawOutlinedRect(0, 0, 512, 512, 2)

            local centerX = 512 / 2
            local centerY = 512 / 2

            local heliForward = heliEnt:GetForward()
            local forwardAng = heliForward:Angle()
            forwardAng:Normalize()

            local heliUp = heliEnt:GetUp()
            local upAng = heliUp:Angle()
            upAng:Normalize()

            local pitch = -forwardAng.p
            local yaw = forwardAng.y
            local roll = -heliEnt:GetAngles().r

            local pitchLadderSpacing = 250
            local degPerPitchLadder = 5
            local pitchLadderNum = (180 / degPerPitchLadder)
            local pitchLadderSpace = 100
            local pitchLadderWidth = 60
            local pitchLadderHeight = 2

            local yawLadderSpacing = 100
            local degPerYawLadder = 5
            local yawLadderNum = (360 / degPerYawLadder)
            local yawLadderSpace = 40
            local yawLadderHeight = 20
            local yawLadderWidth = 2

            local crossWidth = 70
            local crossHeight = 2
            local crossSpacing = 25

            local textColor = Color(30, 255, 0)
            local shapeColor = Color(30, 255, 0)

            local pitchLadderMat = Matrix()
            pitchLadderMat:Translate(Vector(centerX, centerY, 0))
            pitchLadderMat:Rotate(Angle(0, roll, 0))

            local yawLadderMat = Matrix()
            yawLadderMat:Translate(Vector(centerX, centerY, 0))

            cam.PushModelMatrix(pitchLadderMat, true)
                surface.SetDrawColor(shapeColor)
                surface.DrawRect(-crossWidth - crossSpacing, 0, crossWidth, crossHeight)

                surface.SetDrawColor(shapeColor)
                surface.DrawRect(crossSpacing, 0, crossWidth, crossHeight)
                //drawRotatedRect(-11, 0, 2, -15, 45)
                //drawRotatedRect(10, 1, 2, -15, -45)

                for i = 0, pitchLadderNum do
                    local angNumber = -1 * math.floor((pitchLadderNum / 2 - i) * (180 / pitchLadderNum))
                    if math.abs(angNumber) == 0 then angNumber = 0 end

                    local offset = (angNumber % 10) > 0 and 30 or 0
                    local y = (pitchLadderNum / 2 - i) * pitchLadderSpacing + pitch * (pitchLadderSpacing *  (pitchLadderNum / 180))
                    
                    surface.SetDrawColor(shapeColor)
                    surface.DrawRect(pitchLadderSpace + offset, y - 2 + pitchLadderHeight / 2, pitchLadderWidth - offset, pitchLadderHeight)

                    surface.SetDrawColor(shapeColor)
                    surface.DrawRect(pitchLadderSpace + offset, y - 2 + pitchLadderHeight / 2, 2, 10)
                    
                    draw.SimpleText("" .. angNumber, "ChatFont", 0, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    surface.SetDrawColor(shapeColor)
                    surface.DrawRect(-pitchLadderSpace - pitchLadderWidth, y - 2 + pitchLadderHeight / 2, pitchLadderWidth - offset, pitchLadderHeight)

                    surface.SetDrawColor(shapeColor)
                    surface.DrawRect(-pitchLadderSpace - offset, y - 2 + pitchLadderHeight / 2, 2, 10)
                end
            cam.PopModelMatrix()

            cam.PushModelMatrix(yawLadderMat, true)
                for i = 0, yawLadderNum do
                    local angNumber = -1 * math.floor((yawLadderNum / 2 - i) * (360 / yawLadderNum))
                    if math.abs(angNumber) == 0 then angNumber = 0 end

                    local offset = (angNumber % 10) > 0 and 10 or 0
                    local x = (yawLadderNum / 2 - i) * yawLadderSpacing + yaw * (yawLadderSpacing *  (yawLadderNum / 360))
                    local y = -centerY + yawLadderHeight * 2

                    surface.SetDrawColor(shapeColor)
                    surface.DrawRect(x, y, yawLadderWidth, yawLadderHeight - offset)

                    surface.SetDrawColor(shapeColor)
                    surface.DrawRect(x - 10, y, 20, 2)

                    draw.SimpleText("" .. angNumber, "ChatFont", x, y - 10, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            cam.PopModelMatrix()
        cam.End3DUI()
    end

    function PilotSeat.CreateMove(seatEnt, cmd)
    end
end

if SERVER then
    function PilotSeat.StartCommand(seatEnt, ply, cmd)
        if vehicleseat.IsFreelooking(seatEnt) then return end

        local heliEnt = seatEnt:GetParent()
        if not IsValid(heliEnt) then return end

        helisystem.ControlHeli(heliEnt, ply, cmd)
        vehicleweapon.ControlWeapon(seatEnt, ply, cmd)
    end

    function PilotSeat.OnEnter(seatEnt, ply)
        local heliEnt = seatEnt:GetParent()
        if not IsValid(heliEnt) then return end

        heliEnt:HeliStart()
    end
    
    function PilotSeat.OnExit(seatEnt, ply)
        local heliEnt = seatEnt:GetParent()
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
                "autocannon"
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
    function CombineHeli.Initialize(heliEnt)
        heliEnt.RotorBone = heliEnt:LookupBone("Chopper.Rotor_Blur")
        heliEnt.TailBone = heliEnt:LookupBone("Chopper.Tail")
        heliEnt.RotorTailBone = heliEnt:LookupBone("Chopper.Blade_Tail")
        heliEnt.RotorHullBone = heliEnt:LookupBone("Chopper.Blade_Hull")
        heliEnt.RotorAng = 0
        heliEnt.TailAng = 0
    end

    function CombineHeli.Think(heliEnt)
        if heliEnt:IsDormant() then return end

        local throttle = heliEnt:GetThrottle()
        local collective = heliEnt:GetCollective()
        local cyclic = heliEnt:GetCyclic()
        
        local rotorThrottle = throttle * 10
        local rotorCollective = (collective > 0) and collective * 2 or 0

        local rotorAng = heliEnt.RotorAng
        local newRotorAng = rotorAng + rotorThrottle + rotorCollective

        heliEnt.RotorAng = newRotorAng % 360
        heliEnt.TailAng = cyclic.y * 45
    end

    function CombineHeli.Draw(heliEnt)    
        heliEnt:ManipulateBoneAngles(heliEnt.RotorBone, Angle(heliEnt.RotorAng, 0, 0), true)
        heliEnt:ManipulateBoneAngles(heliEnt.RotorTailBone, Angle(0, 0, heliEnt.RotorAng), true)
        heliEnt:ManipulateBoneAngles(heliEnt.RotorHullBone, Angle(0, 0, heliEnt.RotorAng), true)
        heliEnt:ManipulateBoneAngles(heliEnt.TailBone, Angle(0, heliEnt.TailAng, 0), true)
    end
end

if SERVER then
    function CombineHeli.Initialize(heliEnt)
        heliEnt:SetSubMaterial(1, "models/effects/vol_light001")
    end 
end

local MissileLauncher =
{
    leftLauncher = 
    {
        pos = Vector(21, 64, -71),
        ang = Angle(0, 0, 0)
    },

    rightLauncher = 
    {
        pos = Vector(21, -64, -71),
        ang = Angle(0, 0, 0)
    },

    missileName = "stinger",

    maxAmmo = 8,
    defaultAmmo = 8,

    primaryFireRate = 0.5,
    secondaryFireRate = 0.1,

    reloadDelay = 1.2
}

if SERVER then
    function MissileLauncher:ReloadRockets()
        local leftLauncherData = self:WeaponData("leftLauncher")
        local rightLauncherData = self:WeaponData("rightLauncher")

        self.LeftMissile = missilesystem.SpawnMissile(
            self, 
            leftLauncherData["pos"], 
            leftLauncherData["ang"], 
            self:WeaponData("missileName")
        )
        
        self.RightMissile = missilesystem.SpawnMissile(
            self, 
            rightLauncherData["pos"], 
            rightLauncherData["ang"], 
            self:WeaponData("missileName")
        )

        self.LeftLaunched = false
        self.RightLaunched = false
    end

    function MissileLauncher:Initialize()
        self:WeaponCall("ReloadRockets")
    end

    function MissileLauncher:Reloaded()
        self:WeaponCall("ReloadRockets")
    end
    
    function MissileLauncher:PrimaryFire()
        if not self.LeftLaunched then
            missilesystem.LaunchMissile(self.LeftMissile)
            self.LeftLaunched = true
        elseif not self.RightLaunched then
            missilesystem.LaunchMissile(self.RightMissile)
            self.RightLaunched = true
        end

        if self.LeftLaunched and self.RightLaunched then
            vehicleweapon.DoAction(self, VEHICLEWEAPON_ACTION_RELOAD)
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
    
    function MissileLauncher:PrimaryFire()
    end

    function MissileLauncher:SecondaryFire()
    end
end

local AutocannonProjectile = 
{
    dragCoef = 0.04,
    spreadAmount = 10
}

function AutocannonProjectile:OnCreated()
    print("created", self.Pos)
end

local Autocannon =
{
    muzzlePos = Vector(203, 4, -83),

    maxAmmo = 2000,
    defaultAmmo = 2000,

    primaryFireRate = 0.25,
    secondaryFireRate = 0.1,

    reloadDelay = 1.2
}

if SERVER then
    function Autocannon:Initialize()
    end

    function Autocannon:Reloaded()
    end
    
    function Autocannon:PrimaryFire()
        local muzzlePos = self:WeaponData("muzzlePos")
        local projectileSource = self:LocalToWorld(muzzlePos)
        local projectileSpeed = 6000
        local projectileDir = self:GetForward()

        local proj = projectilesystem.CreateProjectile(self, projectileSource, projectileDir * projectileSpeed, "autocannon")
        self:EmitSound("NPC_Combine_Cannon.FireBullet")
    end

    function Autocannon:SecondaryFire()
    end
end

if CLIENT then
    function Autocannon:Initialize()
    end

    function Autocannon:Think()
    end
    
    function Autocannon:PrimaryFire()
    end

    function Autocannon:SecondaryFire()
    end
end

vehicleseat.Register("combine_heli_pilot", PilotSeat)
helisystem.Register("combine_heli", CombineHeli)
vehicleweapon.Register("missile_launcher", MissileLauncher)
vehicleweapon.Register("autocannon", Autocannon)
projectilesystem.Register("autocannon", AutocannonProjectile)
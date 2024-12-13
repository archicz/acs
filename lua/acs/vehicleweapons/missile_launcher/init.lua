local Weapon = {}

function Weapon:SpawnRockets()
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

function Weapon:Initialize()
    self.Missiles = {}
    self:WeaponCall("SpawnRockets")
end

function Weapon:Reloaded()
    self:WeaponClipReload()
    self:WeaponCall("SpawnRockets")
end

function Weapon:Fire()
    local clip = self:GetClip()

    missilesystem.LaunchMissile(self.Missiles[clip])
    self.Missiles[clip] = nil
    self:WeaponTakeAmmo(1)
end

return Weapon
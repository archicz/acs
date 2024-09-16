if not missilesystem then return end

function missilesystem.SpawnMissile(launcher, localPos, localAng, missileName)
    if not missilesystem.Get(missileName) then return nil end

    local baseEnt = launcher:GetParent()
    if not IsValid(baseEnt) then return nil end

    local missileEnt = ents.Create(missilesystem.ClassName)
    local launcherOwner = launcher:GetRealOwner()

    missileEnt.LaunchPosition = localPos
    missileEnt.LaunchAngles = localAng

    if IsValid(missileEnt) and IsValid(launcherOwner) then
        missileEnt:MissileSetup(missileName)
        missileEnt:SetLauncher(launcher)
        missileEnt:SetRealOwner(launcherOwner)
        missileEnt:SetPos(baseEnt:LocalToWorld(localPos))
        missileEnt:SetAngles(baseEnt:LocalToWorldAngles(localAng))
        missileEnt:SetParent(baseEnt)
        missileEnt:Spawn()

        hook.Run("MissileSpawned", missileEnt)
    end
    
    return missileEnt
end

function missilesystem.SpawnMissileStandalone(launcher, pos, ang, missileName)
    if not missilesystem.Get(missileName) then return nil end
    
    local missileEnt = ents.Create(missilesystem.ClassName)
    local launcherOwner = launcher:GetRealOwner()

    if IsValid(missileEnt) and IsValid(launcherOwner) then
        missileEnt:MissileSetup(missileName)
        missileEnt:SetLauncher(launcher)
        missileEnt:SetRealOwner(launcherOwner)
        missileEnt:SetPos(pos)
        missileEnt:SetAngles(ang)
        missileEnt:Spawn()

        hook.Run("MissileSpawned", missileEnt)
    end
    
    return missileEnt
end

function missilesystem.SetGuidanceTarget(missileEnt, target)
    if not IsValid(missileEnt) then return end
    missileEnt:SetGuidanceTarget(target)
end

function missilesystem.LaunchMissile(missileEnt, ...)
    if not IsValid(missileEnt) then 
        return 
    end

    local launcher = missileEnt:GetLauncher()
    if not IsValid(launcher) then 
        return 
    end

    local baseEnt = launcher:GetParent()
    if not IsValid(baseEnt) then
        return 
    end

    missileEnt:SetParent(nil)
    hook.Run("MissileLaunched", missileEnt)

    if missileEnt.LaunchPosition and missileEnt.LaunchAngles then
        missileEnt:SetPos(baseEnt:LocalToWorld(missileEnt.LaunchPosition))
        missileEnt:SetAngles(baseEnt:LocalToWorldAngles(missileEnt.LaunchAngles))
    end
    
    missileEnt:MissileLaunch(...)
end
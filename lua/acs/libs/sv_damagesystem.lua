if not dmgsystem then return end

function dmgsystem.SetupEntity(ent)
    function ent:DamageInit(dmgCfg)
        self:SetMaxHealth(dmgCfg["maxHealth"])
        self:SetHealth(dmgCfg["defaultHealth"])

        function ent:OnTakeDamage(dmgInfo)

        end

        if not dmgCfg["physics"] then return end

        function ent:PhysicsCollide(colData, collider)
            local physCfg = dmgCfg["physics"]

            local velocity = colData["Speed"]
            local pos = colData["HitPos"]
            local hitEntity = colData["HitEntity"]

            if IsValid(hitEntity) and hitEntity:IsPlayer() then return end

            if velocity >= physCfg["damageThreshold"] then
                local damage = math.Clamp(velocity * physCfg["damageCoeff"], 0, physCfg["damageMax"])
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamageType(DMGSYS_TYPE_PHYSICS)
                dmgInfo:SetInflictor(hitEntity)
                dmgInfo:SetDamagePosition(pos)
                dmgInfo:SetDamage(damage)
                
                self:TakeDamageInfo(dmgInfo)
                ent:OnDamagePhysicsDamage(colData)
                return
            end
            
            if velocity < physCfg["collideThreshold"] then return end
            ent:OnDamagePhysicsCollide(colData)
        end
    end
end

function dmgsystem.ExplosionBlast(inflictor, attacker, originPos, dmgRadius, dmg)
    if not IsValid(inflictor) or not IsValid(attacker) then return end

    local effectdata = EffectData()
    effectdata:SetOrigin(originPos)
    effectdata:SetScale(100)
    effectdata:SetMagnitude(800)
    util.Effect("Explosion", effectdata)

    util.BlastDamage(inflictor, attacker, originPos, dmgRadius, dmg)
end
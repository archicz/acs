dmgsystem = {}

function dmgsystem.ExplosionBlast(inflictor, attacker, originPos, dmgRadius, dmg)
    if not IsValid(inflictor) or not IsValid(attacker) then return end

    local effectdata = EffectData()
    effectdata:SetOrigin(originPos)
    effectdata:SetScale(100)
    effectdata:SetMagnitude(800)
    util.Effect("Explosion", effectdata)

    util.BlastDamage(inflictor, attacker, originPos, dmgRadius, dmg)
end
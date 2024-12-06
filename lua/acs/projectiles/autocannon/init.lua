local Projectile = {}

function Projectile:OnImpactWorld(trace)
    dmgsystem.ExplosionBlast(self:GetLauncher():GetRealOwner(), self:GetLauncher(), trace.HitPos, 200, 40)

    -- local effectdata = EffectData()
    -- effectdata:SetOrigin(trace.HitPos)
    -- effectdata:SetScale(100)
    -- effectdata:SetMagnitude(800)
    -- util.Effect("Explosion", effectdata)
end

return Projectile
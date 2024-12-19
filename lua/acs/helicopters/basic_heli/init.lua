local Heli = {}

function Heli:Initialize()
end

function Heli:OnHeliMainRotorHit(traceResult)
    local effectdata = EffectData()
    effectdata:SetOrigin(traceResult.HitPos)
    effectdata:SetScale(8)
    effectdata:SetMagnitude(25)
    util.Effect("acs_rotorscrape", effectdata)
end

function Heli:OnHeliTailRotorHit(traceResult)
    local effectdata = EffectData()
    effectdata:SetOrigin(traceResult.HitPos)
    effectdata:SetScale(8)
    effectdata:SetMagnitude(25)
    util.Effect("acs_rotorscrape", effectdata)
end

function Heli:OnDamagePhysicsCollide(colData)
    local effectdata = EffectData()
    effectdata:SetOrigin(colData.HitPos)
    effectdata:SetScale(4)
    effectdata:SetMagnitude(25)
    util.Effect("acs_metalscrape", effectdata)
end

function Heli:OnDamagePhysicsDamage(colData)
    local effectdata = EffectData()
    effectdata:SetOrigin(colData.HitPos)
    effectdata:SetNormal(colData.HitNormal)
    effectdata:SetScale(8)
    effectdata:SetMagnitude(30)
    util.Effect("acs_metalhit", effectdata)
end

function Heli:Use(activator, caller)
    self:VehicleEnterSeat(activator)
end

return Heli
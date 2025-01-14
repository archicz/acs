function EFFECT:Init(data)
    EmitSound("MetalVent.ImpactHard", data:GetOrigin())
    util.Effect("stunstickimpact", data)
end

function EFFECT:Render()
end
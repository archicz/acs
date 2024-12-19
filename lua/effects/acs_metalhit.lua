function EFFECT:Init(data)
    EmitSound("Metal_Box.ImpactHard", data:GetOrigin())
    util.Effect("stunstickimpact", data)
end

function EFFECT:Render()
end
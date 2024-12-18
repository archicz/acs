sound.Add(
    {
        name = "acs.RotorScrape",
        channel = CHAN_STATIC,
        volume = 1.0,
        level = 70,
        pitch = {100, 105},
        sound =
        {
            "physics/metal/metal_computer_impact_bullet1.wav",
            "physics/metal/metal_computer_impact_bullet2.wav",
            "physics/metal/metal_computer_impact_bullet3.wav"
        }
    }
)

function EFFECT:Init(data)
    EmitSound("acs.RotorScrape", data:GetOrigin())
    util.Effect("manhacksparks", data)
end

function EFFECT:Render()
end
sound.Add(
    {
        name = "acs.MetalScrape",
        channel = CHAN_STATIC,
        volume = 1.0,
        level = 70,
        pitch = {100, 105},
        sound =
        {
            "acs/physics/metal_scrape1.wav",
            "acs/physics/metal_scrape2.wav",
            "acs/physics/metal_scrape3.wav",
            "acs/physics/metal_scrape4.wav"
        }
    }
)

function EFFECT:Init(data)
    self.Pos = data:GetOrigin()
    self.Magnitude = data:GetMagnitude()
    self.Scale = data:GetScale()
    self.Emitter = ParticleEmitter(self.Pos)

    EmitSound("acs.MetalScrape", self.Pos)
end

function EFFECT:Render()
    if not self.Emitter then return end

    for i = 1, self.Magnitude do
        local part = self.Emitter:Add("effects/yellowflare", self.Pos)
        part:SetDieTime(self.Scale)
        part:SetColor(255, 191, 0)
    
        part:SetStartAlpha(255)
        part:SetEndAlpha(0)

        part:SetStartSize(self.Scale)
        part:SetEndSize(0)

        part:SetGravity(Vector( 0, 0, -250 ))
        part:SetVelocity(VectorRand() * 50)
    end

    self.Emitter:Finish()
end
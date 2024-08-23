if not sound then return end

function sound.GenerateReverse(identifier, path)
    if string.EndsWith(path, ".mp3") then error("MP3 not supported") end
    local soundPath = path

    if not string.EndsWith(path, ".wav") then
        local soundScript = sound.GetProperties(path)
        if not soundScript then return end

        soundPath = soundScript["sound"]
    end

    local wav = WaveFile("sound/" .. soundPath)
    local data = wav:ReadSamplesReverse()
    local duration = wav:GetDuration()
    local sampleRate = wav:GetSampleRate()

    local function genCallback(t)
        return data[t]
    end

    sound.Generate(
        identifier,
        sampleRate,
        duration,
        genCallback
    )
end
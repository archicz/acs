local WavFile = {}
WavFile.__index = WavFile

function WavFile:New(path)
    self.FileHandle = file.Open(path, "rb", "GAME")
    if not self.FileHandle then return end

    self.FileHandle:Skip(15)

    assert(self.FileHandle:ReadByte() == 0x20, "Only format 0x20 is supported")

    self.FileHandle:Skip(4)

    assert(self.FileHandle:ReadUShort() == 1, "Only PCM-Int is supported")

    self.NumChannels = self.FileHandle:ReadUShort()
    self.SampleRate = self.FileHandle:ReadULong()
    
    self.FileHandle:Skip(6)
    
    self.BitsPerSample = self.FileHandle:ReadUShort()

    self.FileHandle:Skip(4)

    self.ByteSize = self.FileHandle:ReadULong() / (self.BitsPerSample / 8)
    self.NumSamples = self.ByteSize / self.NumChannels
    self.Duration = self.NumSamples / self.SampleRate
end

function WavFile:GetNumSamples()
    return self.NumSamples or 0
end

function WavFile:GetSampleRate()
    return self.SampleRate or 0
end

function WavFile:GetDuration()
    return self.Duration or 0
end

function WavFile:ReadSamples()
    if not self.FileHandle then return end
    local data = {}

    for sample = 1, self.NumSamples do
        local sampleData = 0

        for chan = 1, self.NumChannels do
            local chanData = 0

            if self.BitsPerSample == 8 then
                chanData = self.FileHandle:ReadByte() / 255
            elseif self.BitsPerSample == 16 then
                chanData = self.FileHandle:ReadShort() / 65535
            end

            sampleData = sampleData + chanData
        end

        data[sample] = math.Clamp(sampleData, -1, 1)
    end

    return data
end

function WavFile:ReadSamplesReverse()
    if not self.FileHandle then return end
    local data = {}

    for sample = 1, self.NumSamples do
        local sampleData = 0

        for chan = 1, self.NumChannels do
            local chanData = 0

            if self.BitsPerSample == 8 then
                chanData = self.FileHandle:ReadByte() / 255
            elseif self.BitsPerSample == 16 then
                chanData = self.FileHandle:ReadShort() / 65535
            end

            sampleData = sampleData + chanData
        end

        data[self.NumSamples - sample] = math.Clamp(sampleData, -1, 1)
    end

    return data
end

function WaveFile(path)
    local instance = {}
    setmetatable(instance, WavFile)

    instance:New(path)

    return instance
end
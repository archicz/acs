local WavFile = {}
WavFile.__index = WavFile

function WavFile:New(path)
    self.fileHandle = file.Open(path, "rb", "GAME")
    if not self.fileHandle then return end

    self.fileHandle:Skip(15)

    assert(self.fileHandle:ReadByte() == 0x20, "Only format 0x20 is supported")

    self.fileHandle:Skip(4)

    assert(self.fileHandle:ReadUShort() == 1, "Only PCM-Int is supported")

    self.numChannels = self.fileHandle:ReadUShort()
    self.sampleRate = self.fileHandle:ReadULong()
    
    self.fileHandle:Skip(6)
    
    self.bitsPerSample = self.fileHandle:ReadUShort()

    self.fileHandle:Skip(4)

    self.byteSize = self.fileHandle:ReadULong() / (self.bitsPerSample / 8)
    self.numSamples = self.byteSize / self.numChannels
    self.duration = self.numSamples / self.sampleRate
end

function WavFile:GetNumSamples()
    return self.numSamples or 0
end

function WavFile:GetSampleRate()
    return self.sampleRate or 0
end

function WavFile:GetDuration()
    return self.duration or 0
end

function WavFile:ReadSamples()
    if not self.fileHandle then return end
    local data = {}

    for sample = 1, self.numSamples do
        local sampleData = 0

        for chan = 1, self.numChannels do
            local chanData = 0

            if self.bitsPerSample == 8 then
                chanData = self.fileHandle:ReadByte() / 255
            elseif self.bitsPerSample == 16 then
                chanData = self.fileHandle:ReadShort() / 65535
            end

            sampleData = sampleData + chanData
        end

        data[sample] = math.Clamp(sampleData, -1, 1)
    end

    return data
end

function WavFile:ReadSamplesReverse()
    if not self.fileHandle then return end
    local data = {}

    for sample = 1, self.numSamples do
        local sampleData = 0

        for chan = 1, self.numChannels do
            local chanData = 0

            if self.bitsPerSample == 8 then
                chanData = self.fileHandle:ReadByte() / 255
            elseif self.bitsPerSample == 16 then
                chanData = self.fileHandle:ReadShort() / 65535
            end

            sampleData = sampleData + chanData
        end

        data[self.numSamples - sample] = math.Clamp(sampleData, -1, 1)
    end

    return data
end

function WaveFile(path)
    local instance = {}
    setmetatable(instance, WavFile)

    instance:New(path)

    return instance
end
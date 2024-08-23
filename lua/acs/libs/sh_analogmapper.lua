local PercentMapper = {}
PercentMapper.__index = PercentMapper

function PercentMapper:New(strength)
    self.strength = strength or 0.1
    self.nextProgress = 0
    self.inputValue = 0
    self.outputValue = 0
end

function PercentMapper:Input(inValue)
    if inValue ~= nil then
        self.inputValue = math.Clamp(inValue, -1, 1)
    end
end

function PercentMapper:Output()
    local delta = self.inputValue - self.outputValue
    local deltaDir = (delta > 0) and 1 or -1
    local strength = FrameTime() * self.strength
    local remaining = math.abs(delta) < strength
    
    local outputValue = remaining and self.inputValue or (self.outputValue + (strength * deltaDir))
    local clamped = math.Clamp(outputValue, -1, 1)
    local rounded = math.Round(clamped, 2)

    self.outputValue = clamped
    return rounded
end

function AnalogMapper(...)
    local instance = {}
    setmetatable(instance, PercentMapper)

    instance:New(...)

    return instance
end
if not surface then return end

local BaseWidth = 1920
local BaseHeight = 1080

local WidthDPI = ScrW() / BaseWidth
local HeightDPI = ScrH() / BaseHeight
local BothDPI = math.min(WidthDPI, HeightDPI)

function ScaleWidthDPI(w)
    return w * WidthDPI
end

function ScaleHeightDPI(h)
    return h * HeightDPI
end

function ScaleDPI(n)
    return n * BothDPI
end

function surface.CreateFontDPI(name, fontData)
    fontData["size"] = fontData["size"] * BothDPI

    surface.CreateFont(name, fontData)
end
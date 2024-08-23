if not cam then return end
if not render then return end

local rtSize = 512
local rtTexture = GetRenderTarget("3dui", rtSize, rtSize)
local rtMaterial = CreateMaterial("3dui_mat", "UnlitGeneric",
{
    ["$basetexture"] = rtTexture:GetName(),
    ["$translucent"] = "1"
});

local uiPos = 0
local uiAng = 0
local uiScale = 0
local uiCalllback = 0

function cam.Start3DUI(pos, ang, scale, cb)
    uiPos = pos
    uiAng = ang
    uiScale = scale
    uiCalllback = cb or 0

    render.PushRenderTarget(rtTexture)
    cam.Start2D()
end

function cam.End3DUI()
    cam.End2D()
    render.PopRenderTarget()

    if uiCalllback then
        pcall(uiCalllback, rtTexture)
    end

    cam.Start3D2D(uiPos, uiAng, uiScale)
        render.PushFilterMag(TEXFILTER.POINT)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(rtMaterial)
            surface.DrawTexturedRect(-rtSize / 2, -rtSize / 2, rtSize, rtSize)
        render.PopFilterMag()
    cam.End3D2D()
end
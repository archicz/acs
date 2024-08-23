if not cam then return end
if not render then return end

local rtTexture = GetRenderTarget("bloomrt", ScrW(), ScrH())
local rtMaterial = CreateMaterial("bloomrt_mat", "UnlitGeneric",
{
    ["$basetexture"] = rtTexture:GetName(),
    ["$translucent"] = "1"
});

local rtTextureCopy = GetRenderTarget("bloomrt_copy", ScrW(), ScrH())
local rtMaterialCopy = CreateMaterial("bloomrt_copy_mat", "UnlitGeneric",
{
    ["$basetexture"] = rtTextureCopy:GetName(),
    ["$translucent"] = "1"
});

local colorMod = 
{
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 10,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

function render.BloomRenderTarget(rt, blurX, blurY, passes, contrast, brightness, mulR, mulG, mulB)
    if not rt then return end

    local colorModCopy = table.Copy(colorMod)
    colorModCopy["$pp_colour_contrast"] = contrast or 10
    colorModCopy["$pp_colour_brightness"] = brightness or 0
    colorModCopy["$pp_colour_mulr"] = mulR or 0
    colorModCopy["$pp_colour_mulg"] = mulG or 0
    colorModCopy["$pp_colour_mulb"] = mulB or 0

    render.CopyTexture(rt, rtTexture)
    render.CopyTexture(rt, rtTextureCopy)

    render.PushRenderTarget(rtTexture)
    cam.Start2D()
        render.BlurRenderTarget(rtTexture, blurX, blurY, passes)
        DrawColorModify(colorModCopy)
    cam.End2D()
    render.PopRenderTarget()

    render.PushRenderTarget(rt)
    cam.Start2D()
        render.SetMaterial(rtMaterial)
        render.DrawScreenQuad()

        render.SetMaterial(rtMaterialCopy)
        render.DrawScreenQuad()
    cam.End2D()
    render.PopRenderTarget()
end
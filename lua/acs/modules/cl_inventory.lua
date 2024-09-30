local nigger = false
local prevNigger = false
local tglNigger = false

local ctx = {}
local scroll = 0

local idk = 0

local function CalculateMinCellWidth(totalWidth, paddingLeft, paddingRight, numItems)
    local availableWidth = totalWidth - paddingLeft - paddingRight
    local totalSpacing = (numItems - 1)
    local cellWidth = (availableWidth - totalSpacing) / numItems

    return math.floor(cellWidth)
end

local srackaVelikost = 93
local hovnoRT = GetRenderTarget("HOVNORTCKO", srackaVelikost, srackaVelikost)

local kokotMat = CreateMaterial("itemekvinventariMAT", "UnlitGeneric",
{
	["$basetexture"] = hovnoRT:GetName(),
    ["$translucent"] = 1
});

local mrdat = Material("gui/gradient_down")

local scene = false

local function ItemScene()
    scene = interactivescene.CreateScene()
    scene:CreateCamera(Vector(0, 0, 0), Angle(0, 0, 0), 60)
    -- scene:SetSkybox("skybox/sky_day02_02")

    local prop = interactivescene.CreateProp()
    prop:SetPos(Vector(0, 0, 0))
    prop:SetAngles(Angle(0, 0, 0))
    prop:SetModel("models/Items/car_battery01.mdl")
    scene:AddObject(prop)
end

function SerMe()
    scene.Objects[1].Pos.x = 25
    scene.Objects[1].Ang.y = CurTime() * 40

    interactivescene.DrawRT(scene, hovnoRT)
end

local function ItemWidget(w, h)
    local x, y = imgui.GetCursor()

    imgui.Draw(function()
        surface.SetDrawColor(60, 60, 60)
        surface.DrawRect(x, y, w, h)
        
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(kokotMat)
        surface.DrawTexturedRect(x, y, srackaVelikost, srackaVelikost)
    end)

    imgui.ContentAdd(w, h)
end

ItemScene()

hook.Add("DrawOverlay", "Negr2Draw", function()
    prevNigger = nigger
    nigger = input.IsKeyDown(KEY_F2)

    if nigger and not prevNigger then
        tglNigger = !tglNigger
    end

    if not tglNigger then return end

    SerMe()

    input.UnlockCursor()
    imgui.Context2D(ctx)
        imgui.BeginWindow("Inventory", IMGUI_POS_CENTER, IMGUI_POS_CENTER, 1280, 720)
            imgui.SetPadding(2, 2, 2, 2)
            imgui.SameLine()

            local spaceW, spaceH = imgui.GetLayout()

            imgui.BeginGroup(spaceW * 0.75, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(0, 0, 0, 0)
                imgui.SameLine()
                
                local scrollWidth = 8
                local insideW, insideH = imgui.GetLayout()

                local canvas = imgui.BeginGroup(insideW - scrollWidth, insideH, scroll)
                    imgui.SetPadding(2, 2, 2, 2)

                    local layoutW, layoutH = imgui.GetLayout()
                    
                    local width = 10
                    local height = 20
                    local cellSize = CalculateMinCellWidth(layoutW, 2, 2, width)

                    for y = 1, height do
                        imgui.SameLine()

                        for x = 1, width do
                            ItemWidget(cellSize, cellSize)
                        end

                        imgui.NewLine()
                    end
                imgui.EndGroup()

                scroll = imgui.VerticalScroll(scrollWidth, true, canvas)
            imgui.EndGroup()

            imgui.BeginGroup(IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)

            imgui.EndGroup()
        imgui.EndWindow()
    imgui.ContextEnd()
end)
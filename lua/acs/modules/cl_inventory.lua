local nigger = false
local prevNigger = false
local tglNigger = false

local ctx = {}
local scroll = 0

local idk = 0

local srackaVelikost = 117
local hovnoRT = GetRenderTarget("HOVNORTCKO", srackaVelikost, srackaVelikost)

local kokotMat = Material("pp/scanlines")
kokotMat:SetTexture("$basetexture", hovnoRT:GetName())

local mrdat = Material("gui/gradient_down")

local scene = false

local function ItemScene()
    scene = interactivescene.CreateScene()
    scene:CreateCamera(Vector(0, 0, 0), Angle(0, 0, 0), 60)
    -- scene:SetSkybox("skybox/sky_dust")

    function scene:PreDrawObjects()
        local camera = self.Camera
        local w = camera.ScreenW
        local h = camera.ScreenH

        cam.Start2D()
        surface.SetDrawColor(87, 0, 200, 200)
        surface.SetMaterial(mrdat)
        surface.DrawTexturedRect(2, 2, w - 4, h - 4)
        cam.End2D()
    end

    function scene:PostDrawObjects()

    end

    local prop = interactivescene.CreateProp()
    prop:SetPos(Vector(15, 0, -7))
    prop:SetAngles(Angle(0, 0, 0))
    prop:SetModel("models/Items/battery.mdl")
    scene:AddObject(prop)
end

function PojebSveta()
    return kokotMat
end

function SerMe()
    scene.Objects[1].Ang.y = CurTime() * 100

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
        
        local captionH = 16

        surface.SetFont("DermaDefault")
        local text = "Pivo"
        local textW, textH = surface.GetTextSize(text)

        surface.SetDrawColor(8, 8, 8, 200)
        surface.DrawRect(x + 2, y + w - captionH - 2, w - 4, captionH)

        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetTextPos(x + (w - 4) / 2 - textW / 2, y + (w - captionH - 2) + captionH / 2 - textH / 2)
        surface.SetFont("DermaDefault")
        surface.DrawText(text)
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

            imgui.BeginGroup(spaceW * 0.75 + 3, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(0, 0, 0, 0)
                imgui.SameLine()
                
                local scrollWidth = 6
                local insideW, insideH = imgui.GetLayout()

                local canvas = imgui.BeginGroup(insideW - scrollWidth, insideH, scroll)
                    imgui.SetPadding(2, 2, 2, 2)

                    local cols = 8
                    local rows = 10
                    local cellSize = imgui.LayoutCalculateWidth(cols)

                    for y = 1, rows do
                        imgui.SameLine()

                        for x = 1, cols do
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
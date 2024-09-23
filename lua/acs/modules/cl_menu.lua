local nigger = false
local prevNigger = false
local tglNigger = false

local ctx = {}

local chkb = false
local sldr = 1.2

hook.Add("DrawOverlay", "NegrDraw", function()
    prevNigger = nigger
    nigger = input.IsKeyDown(KEY_F3)

    if nigger and not prevNigger then
        tglNigger = !tglNigger
    end

    if not tglNigger then return end

    input.UnlockCursor()
    imgui.Context2D(ctx)
        imgui.BeginWindow("Settings", IMGUI_POS_CENTER, IMGUI_POS_CENTER, 800, 600)
            imgui.SetPadding(2, 2, 2, 2)
            
            imgui.BeginGroup(200, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(2, 2, 2, 2)
                imgui.Button("test1", IMGUI_SIZE_CONTENT, 40)

                imgui.SameLine()
                imgui.Label("label test")
                imgui.Label("another text")
                imgui.Label("label madness")

                imgui.NewLine()
                imgui.Label("new line")

                imgui.SameLine()
                chkb = imgui.Checkbox("test checkbox", chkb)
                chkb = imgui.Checkbox("test checkbox", chkb)

                imgui.NewLine()
                sldr = imgui.SliderDecimal("test slider", 0, 10, sldr)
                -- sldr = imgui.Slider("slider", 0, 10, sldr)
            imgui.EndGroup()
        imgui.EndWindow()
    imgui.ContextEnd()
end)
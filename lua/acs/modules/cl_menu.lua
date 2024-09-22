local nigger = false
local prevNigger = false
local tglNigger = false

local ctx = {}

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
            
            imgui.BeginGroup(IMGUI_SIZE_CONTENT, 44)
                imgui.SetPadding(2, 2, 2, 2)
                imgui.Button("test1", IMGUI_SIZE_CONTENT, 40)
            imgui.EndGroup()
        imgui.EndWindow()
    imgui.ContextEnd()
end)
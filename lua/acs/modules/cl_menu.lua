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

    imgui.Context2D(ctx)
        imgui.BeginWindow("Example Window", 100, 100, 400, 400)
            imgui.SameLine()
            if imgui.Button("Test", 50, 20) then
                print("test clicked")
            end
            imgui.Button("Test2", 100, 20)
            
            imgui.NewLine()
            imgui.Button("Test3", 100, 20)
            imgui.BeginGroup(200, 100)
                imgui.SameLine()
                imgui.Button("Test4", 50, 20)
                imgui.Button("Test5", 100, 20)
                
                imgui.NewLine()
                imgui.BeginGroup(100, 50)
                    imgui.Button("Test6", 50, 20)
                imgui.EndGroup()
            imgui.EndGroup()
        imgui.EndWindow()
    imgui.ContextEnd()
end)
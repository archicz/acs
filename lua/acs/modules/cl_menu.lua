local nigger = false
local prevNigger = false
local tglNigger = false

hook.Add("DrawOverlay", "NegrDraw", function()
    prevNigger = nigger
    nigger = input.IsKeyDown(KEY_F3)

    if nigger and not prevNigger then
        tglNigger = !tglNigger
    end

    if not tglNigger then return end

    imgui.Start2D()
    imgui.End2D()
end)
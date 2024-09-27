local nigger = false
local prevNigger = false
local tglNigger = false

local ctx = {}

local chkb = false
local sldr = 1.2

local hangarScene = {}
local hangarCamera = {}

local function PrototypeScene()
    hangarScene = interactivescene.CreateScene()
    hangarScene:CreateCamera(Vector(175, -240, 200), Angle(30, 125, 0), 100)
    hangarScene:SetSkybox("skybox/militia_hdr")
    -- hangarScene:CreateCamera(Vector(0, 0, 0), Angle(0, 0, 0), 100)

    local pacData = pace.luadata.ReadFile("pac3/hangar_alpha.txt")

    for _, entry in pairs(pacData[1]["children"]) do
        local partData = entry["self"]
        
        local prop = interactivescene.CreateProp()
        prop:SetPos(partData["Position"])
        prop:SetAngles(partData["Angles"])
        prop:SetScale(partData["Scale"])
        prop:SetDirectionalLight(BOX_TOP, Color(100, 100, 100, 255))
        prop:SetModel(partData["Model"])

        hangarScene:AddObject(prop)
    end

    hangarCamera = hangarScene:GetCamera()
end

PrototypeScene()

local scroll = 0

hook.Add("DrawOverlay", "NegrDraw", function()
    prevNigger = nigger
    nigger = input.IsKeyDown(KEY_F3)

    if nigger and not prevNigger then
        tglNigger = !tglNigger
    end

    if not tglNigger then return end

    input.UnlockCursor()
    imgui.Context2D(ctx)
        imgui.BeginWindow("Settings", IMGUI_POS_CENTER, IMGUI_POS_CENTER, 1280, 720)
            imgui.SetPadding(2, 2, 2, 2)
            imgui.SameLine()

            imgui.BeginScrollGroup(300, IMGUI_SIZE_CONTENT, scroll)
                imgui.SetPadding(2, 2, 2, 2)
            scroll = imgui.EndScrollGroup()
            
            imgui.BeginGroup(IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(2, 2, 2, 2)
                imgui.SceneViewer(hangarScene, IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
            imgui.EndGroup()
        imgui.EndWindow()
    imgui.ContextEnd()
end)
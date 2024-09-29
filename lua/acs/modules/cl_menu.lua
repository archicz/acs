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
    hangarScene:CreateCamera(Vector(175, -240, 200), Angle(25, 125, 0), 100)
    hangarScene:SetSkybox("skybox/sky_day02_02")
    
    local pacData = pace.luadata.ReadFile("pac3/hangar_alpha.txt")

    for _, entry in pairs(pacData[1]["children"]) do
        local partData = entry["self"]
        
        local prop = interactivescene.CreateProp()
        prop:SetPos(partData["Position"])
        prop:SetAngles(partData["Angles"])
        prop:SetScale(partData["Scale"])
        prop:SetModel(partData["Model"])

        hangarScene:AddObject(prop)
    end

    hangarCamera = hangarScene:GetCamera()
    hangarCamera:SetAmbientLight(Color(0, 0, 0))

    local mainLight = interactivescene.CreatePointLight()
    mainLight:SetPos(Vector(0, -13, 200))
    mainLight:SetColor(Color(102, 102, 102), 0.1)
    mainLight:SetMinDistance(50)
    mainLight:SetMaxDistance(350)

    hangarScene:AddLight(mainLight)

    local glowSpr = interactivescene.CreateSprite()
    glowSpr:SetMaterial("sprites/light_glow02")
    glowSpr:SetAdditive(true)
    glowSpr:SetPos(Vector(0, -13, 230))
    glowSpr:SetSize(80)

    hangarScene:AddObject(glowSpr)
end

PrototypeScene()

local scroll = 0
local scroll2 = 0

local selectedObj = 0
local cringeX = 0
local cringeY = 0
local cringeZ = 0

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

            imgui.BeginGroup(IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(2, 2, 2, 2)
                imgui.SceneViewer(hangarScene, IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
            imgui.EndGroup()
        imgui.EndWindow()
    imgui.ContextEnd()
end)
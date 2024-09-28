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
    hangarScene:CreateCamera(Vector(175, -240, 200), Angle(25, 125, 0), 90)
    hangarScene:SetSkybox("skybox/militia_hdr")
    -- hangarScene:CreateCamera(Vector(0, 0, 0), Angle(0, 0, 0), 100)

    local pacData = pace.luadata.ReadFile("pac3/hangar_alpha.txt")

    for _, entry in pairs(pacData[1]["children"]) do
        local partData = entry["self"]
        
        local prop = interactivescene.CreateProp()
        prop:SetPos(partData["Position"])
        prop:SetAngles(partData["Angles"])
        prop:SetScale(partData["Scale"])
        -- prop:SetDirectionalLight(BOX_TOP, Color(100, 100, 100, 255))
        prop:SetModel(partData["Model"])

        hangarScene:AddObject(prop)
    end

    hangarCamera = hangarScene:GetCamera()
    hangarCamera:SetAmbientLight(Color(0, 0, 0))

    local mainLight = interactivescene.CreatePointLight()
    mainLight:SetPos(Vector(0, 0, 170))
    mainLight:SetColor(Color(255, 255, 255), 0.05)
    mainLight:SetMinDistance(10)
    mainLight:SetMaxDistance(300)

    hangarScene:AddLight(mainLight)
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

            imgui.BeginGroup(300, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(0, 0, 0, 2)

                imgui.BeginScrollGroup(IMGUI_SIZE_CONTENT, 400, scroll)
                    imgui.SetPadding(2, 2, 2, 2)

                    -- hangarCamera.FOV = imgui.SliderDecimal("Cam FOV", 0, 140, hangarCamera.FOV)

                    local sceneObjects = hangarScene:GetObjects()

                    for i = 1, #sceneObjects do
                        local obj = sceneObjects[i]
                        
                        if imgui.Button("#" .. i .. " " .. obj:GetModel(), IMGUI_SIZE_CONTENT, 25) then
                            selectedObj = i

                            cringeX = 0
                            cringeY = 0
                            cringeZ = 0
                        end
                    end
                scroll = imgui.EndScrollGroup()

                imgui.SetPadding(0, 0, 0, 0)

                imgui.BeginScrollGroup(IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT, scroll2)
                    imgui.SetPadding(2, 2, 2, 2)

                    if selectedObj > 0 then
                        local sceneObjects = hangarScene:GetObjects()
                        local obj = sceneObjects[selectedObj]
                        local mdl = obj:GetModel()
                        local pos = obj:GetPos()
                        local ang = obj:GetAngles()
                        
                        imgui.Label(mdl)
                        imgui.Label(string.format("Pos: %2f, %2f, %2f", pos.x, pos.y, pos.z))
                        imgui.Label(string.format("Ang: %2f, %2f, %2f", ang.p, ang.y, ang.r))

                        cringeX = imgui.SliderDecimal("Pos X Offset", -100, 100, cringeX)
                        cringeY = imgui.SliderDecimal("Pos Y Offset", -100, 100, cringeY)
                        cringeZ = imgui.SliderDecimal("Pos Z Offset", -100, 100, cringeZ)

                        obj.PosOffset.x = cringeX
                        obj.PosOffset.y = cringeY
                        obj.PosOffset.z = cringeZ
                    end
                scroll2 = imgui.EndScrollGroup()
            imgui.EndGroup(true)

            imgui.BeginGroup(IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(2, 2, 2, 2)
                imgui.SceneViewer(hangarScene, IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
            imgui.EndGroup()
        imgui.EndWindow()
    imgui.ContextEnd()
end)
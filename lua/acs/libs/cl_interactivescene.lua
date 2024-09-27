interactivescene = {}

local SceneObjectProp = {}
SceneObjectProp.__index = SceneObjectProp

function SceneObjectProp:New()
    self.Model = ""
    self.Pos = Vector(0, 0, 0)
    self.Ang = Angle(0, 0, 0)
    self.Scale = Vector(1, 1, 1)
    self.Lights = {}
    self.LightOrigin = Vector(0, 0, 0)
    self.Entity = NULL
end

function SceneObjectProp:GetModel()
    return self.Model
end

function SceneObjectProp:SetModel(model)
    self.Model = model
    self:Generate()
end

function SceneObjectProp:GetEntity()
    return self.Entity
end

function SceneObjectProp:GetPos()
    return self.Pos
end

function SceneObjectProp:SetPos(pos)
    self.Pos = pos
end

function SceneObjectProp:GetAngles()
    return self.Ang
end

function SceneObjectProp:SetAngles(ang)
    self.Ang = ang
end

function SceneObjectProp:GetScale()
    return self.Scale
end

function SceneObjectProp:SetScale(scale)
    self.Scale = scale
end

function SceneObjectProp:GetDirectionalLight(dir)
    return self.Lights[dir]
end

function SceneObjectProp:SetDirectionalLight(dir, intensity)
    self.Lights[dir] = intensity
end

function SceneObjectProp:GetLightOrigin()
    return self.LightOrigin
end

function SceneObjectProp:SetLightOrigin(pos)
    self.LightOrigin = pos
end

function SceneObjectProp:Draw()
    local ent = self.Entity
    if not IsValid(ent) then return end

    local lights = self.Lights

    for dir = BOX_FRONT, BOX_BOTTOM do
        local color = lights[dir]
	    if not color then continue end
        
        render.SetModelLighting(dir, color.r / 255, color.g / 255, color.b / 255)
    end

    render.SetLightingOrigin(self.LightOrigin)

    local modelMat = Matrix()
    modelMat:Scale(self.Scale)

    ent:EnableMatrix("RenderMultiply", modelMat)
    ent:DrawModel()
end

function SceneObjectProp:Generate()
    local ent = self:GetEntity()
    if IsValid(ent) then
        SafeRemoveEntity(ent)
    end

    ent = ClientsideModel(self.Model)
    if not IsValid(ent) then return end

    ent:SetNoDraw(true)
    ent:SetIK(false)
    ent:SetPos(self.Pos)
    ent:SetAngles(self.Ang)

    self.Entity = ent
end



local SceneCamera = {}
SceneCamera.__index = SceneCamera

function SceneCamera:New(pos, ang, fov)
    self.Pos = pos or Vector(0, 0, 0)
    self.Ang = ang or Angle(0, 0, 0)
    self.FOV = fov or 90

    self.NearZ = 4
    self.FarZ = 16384

    self.ColorMod = Color(255, 255, 255)
    self.AmbientLight = Color(75, 75, 75)
end

function SceneCamera:GetPos()
    return self.Pos
end

function SceneCamera:SetPos(pos)
    self.Pos = pos
end

function SceneCamera:GetAngles()
    return self.Ang
end

function SceneCamera:SetAngles(ang)
    self.Ang = ang
end

function SceneCamera:LookAt(pos)
    local dir = (self.Pos - pos)
    dir:Normalize()

    self.Ang = dir:Angle()
end

function SceneCamera:GetFOV()
    return self.FOV
end

function SceneCamera:SetFOV(fov)
    self.FOV = fov
end

function SceneCamera:GetColorModulation()
    return self.ColorMod
end

function SceneCamera:SetColorModulation(color)
    self.ColorMod = color
end

function SceneCamera:GetAmbientLight()
    return self.AmbientLight
end

function SceneCamera:SetAmbientLight(color)
    self.AmbientLight = color
end



local SceneSkybox = {}
SceneSkybox.__index = SceneSkybox

function SceneSkybox:New(path)
    self.Path = ""
end

function SceneSkybox:SetPath(path)
    self.Path = path
    self:Generate()
end

function SceneSkybox:Generate()
    self.MaterialFaces =
    {
        up = Material(self.Path .. "up"),
        down = Material(self.Path .. "dn"),
        left = Material(self.Path .. "lf"),
        right = Material(self.Path .. "rt"),
        front = Material(self.Path .. "ft"),
        back = Material(self.Path .. "bk")
    }
end

function SceneSkybox:Draw(pos, size)
    if not self.MaterialFaces then return end

    render.SetMaterial(self.MaterialFaces.up)
    render.DrawQuadEasy(pos + Vector(0, 0, size / 2), Vector(0, 0, -1), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.down)
    render.DrawQuadEasy(pos + Vector(0, 0, -size / 2), Vector(0, 0, 1), size, size, 0, 0)

    render.SetMaterial(self.MaterialFaces.right)
    render.DrawQuadEasy(pos + Vector(-size / 2, 0, 0), Vector(1, 0, 0), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.left)
    render.DrawQuadEasy(pos + Vector(size / 2, 0, 0), Vector(-1, 0, 0), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.front)
    render.DrawQuadEasy(pos + Vector(0, size / 2, 0), Vector(0, -1, 0), size, size, 0, 180)

    render.SetMaterial(self.MaterialFaces.back)
    render.DrawQuadEasy(pos + Vector(0, -size / 2, 0), Vector(0, 1, 0), size, size, 0, 180)
end



local Scene = {}
Scene.__index = Scene

function Scene:New()
    self.Objects = {}
    self.Camera = nil
    self.Skybox = nil

    self.ViewAngles = Angle(0, 0, 0)
end

function Scene:GetCamera()
    return self.Camera
end

function Scene:GetObjects()
    return self.Objects
end

function Scene:CreateCamera(pos, ang, fov)
    local camera = {}
    setmetatable(camera, SceneCamera)
    camera:New(pos, ang, fov)

    self.Camera = camera
    return camera
end

function Scene:SetSkybox(path)
    if not self.Skybox then
        local skybox = {}
        setmetatable(skybox, SceneSkybox)
        skybox:New()

        self.Skybox = skybox
    end

    self.Skybox:SetPath(path)
end

function Scene:AddObject(obj)
    table.insert(self.Objects, obj)
end

function Scene:PreDrawObjects()
end

function Scene:PostDrawObjects()
end

function Scene:PreDrawSkybox()
end

function Scene:PostDrawSkybox()
end

function Scene:Draw(x, y, w, h)
    local camera = self.Camera
    if not camera then return end

    local up = input.IsKeyDown(KEY_PAD_8) and -1 or 0
    local down = input.IsKeyDown(KEY_PAD_2) and 1 or 0

    local left = input.IsKeyDown(KEY_PAD_4) and 1 or 0
    local right = input.IsKeyDown(KEY_PAD_6) and -1 or 0

    self.ViewAngles.p = self.ViewAngles.p + (up + down)
    self.ViewAngles.y = self.ViewAngles.y + (left + right)

    cam.Start3D(camera.Pos, camera.Ang + self.ViewAngles, camera.FOV, x, y, w, h, camera.NearZ, camera.FarZ)
        render.Clear(0, 0, 0, 255, true, true)

        render.SuppressEngineLighting(true)
        render.ResetModelLighting(camera.AmbientLight.r / 255, camera.AmbientLight.g / 255, camera.AmbientLight.b / 255)
        render.SetColorModulation(camera.ColorMod.r / 255, camera.ColorMod.g / 255, camera.ColorMod.b / 255)
        render.SetBlend(1)

        if self.Skybox then
            self:PreDrawSkybox()

            self.Skybox:Draw(Vector(0, 0, 0), camera.FarZ)

            self:PostDrawSkybox()
        end

        self:PreDrawObjects()

        for i = 1, #self.Objects do
            self.Objects[i]:Draw()
        end

        self:PostDrawObjects()

        render.SuppressEngineLighting(false)
    cam.End3D()    
end

function interactivescene.CreateProp()
    local instance = {}
    setmetatable(instance, SceneObjectProp)
    instance:New()

    return instance
end

function interactivescene.CreateScene()
    local instance = {}
    setmetatable(instance, Scene)
    instance:New()

    return instance
end

if not imgui then return end
function imgui.SceneViewer(scene, w, h)
    local parentW, parentH = imgui.GetLayout()
    local x, y = imgui.GetCursor()

    if w == IMGUI_SIZE_CONTENT then
        w = parentW
    end

    if h == IMGUI_SIZE_CONTENT then
        h = parentH
    end

    local isHovering = imgui.MouseInRect(x, y, w, h)
    local hasClicked = imgui.HasClicked()

    imgui.Draw(function()
        scene:Draw(x, y, w, h)
    end)

    imgui.ContentAdd(w, h)
end

/*
local nigger = false
local prevNigger = false
local tglNigger = false

local ctx = {}
local ctx2 = {}

local Props = {}
local FarZ = 4096

local CamPos = Vector(45, 0, 70)
local LookAng = Angle(0, 180, 0)
local FOV = 100
local AmbientLight = Color(100, 100, 100)
local Kolour = Color(255, 255, 255)

function ZapniKreteni()
    for _, entry in pairs(kokoti[1]["children"]) do
        local partData = entry["self"]
        
        local prop = ClientsideModel(partData["Model"])
        if IsValid(prop) then
            prop:SetNoDraw(true)
            prop:SetIK(false)
            prop:SetPos(partData["Position"])
            prop:SetAngles(partData["Angles"])
    
            table.insert(Props, prop)
        end
    end
end

function Kreteni(x, y, w, h)
    surface.SetDrawColor(50, 50, 50)
    surface.DrawRect(x, y, w, h)

    local up = input.IsKeyDown(KEY_PAD_8) and -1 or 0
    local down = input.IsKeyDown(KEY_PAD_2) and 1 or 0

    local left = input.IsKeyDown(KEY_PAD_4) and 1 or 0
    local right = input.IsKeyDown(KEY_PAD_6) and -1 or 0

    LookAng.p = LookAng.p + (up + down)
    LookAng.y = LookAng.y + (left + right)

	cam.Start3D(CamPos, LookAng, FOV, x, y, w, h, 5, FarZ)

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( Vector(0, 0, 0) )
	render.ResetModelLighting( AmbientLight.r / 255, AmbientLight.g / 255, AmbientLight.b / 255 )
	render.SetColorModulation( Kolour.r / 255, Kolour.g / 255, Kolour.b / 255 )
	render.SetBlend( 1 ) -- * surface.GetAlphaMultiplier()

	//for i = 0, 6 do
	//	local col = self.DirectionalLight[ i ]
	//	if ( col ) then
	//		render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
	//	end
	//end

    render.ClearDepth( false )
    for _, prop in pairs(Props) do
        prop:DrawModel()
    end

    local pozicka = Vector(20, 0, 75)
    local angl = Angle(0, 90, 90)
    local skal = 0.05

    local kurzoresX, kurzoresY = input.GetCursorPos()
    local smericek = util.AimVector(LookAng, FOV, kurzoresX - x, kurzoresY - y, w, h)
    smericek:Normalize()

    local testHovna = util.IntersectRayWithPlane(CamPos, smericek, pozicka, angl:Up())

    local rozdl = pozicka - testHovna
    local skutecneX = rozdl:Dot(-angl:Forward()) / skal
    local skutecneY = rozdl:Dot(-angl:Right()) / skal

    local sracka = Props[23]
    local obbMin, obbMax = sracka:GetModelBounds()
    local srackAng = sracka:GetAngles()
    local srackPos = sracka:GetPos() + sracka:OBBCenter()

    render.DrawWireframeBox(srackPos, srackAng, obbMin, obbMax, Color(255, 0, 0))

    local hitPos, hitNormal, frac = util.IntersectRayWithOBB(CamPos, smericek * 1000, srackPos, srackAng, obbMin, obbMax)
    if hitPos then
        render.DrawLine(Vector(0, 0, 0), hitPos, Color(255, 0, 0), false)
    end
    
    cam.Start3D2D(pozicka, angl, skal)
        imgui.Context3D2D(ctx2)
        ctx2.MouseX = skutecneX
        ctx2.MouseY = skutecneY
            imgui.BeginWindow("Settings", 0, 0, IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(2, 2, 2, 2)
                
                imgui.BeginGroup(IMGUI_SIZE_CONTENT, 44)
                    imgui.SetPadding(2, 2, 2, 2)
                    imgui.Button("3D2D ImGUI Test", IMGUI_SIZE_CONTENT, 40)
                imgui.EndGroup()
            imgui.EndWindow()
        imgui.ContextEnd()

        --surface.SetDrawColor(200, 0, 0)
        --surface.DrawRect(skutecneX, skutecneY, 2, 2)
    cam.End3D2D()

	render.SuppressEngineLighting( false )
	cam.End3D()
end

ZapniKreteni()

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

            imgui.BeginGroup(IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT)
                imgui.SetPadding(2, 2, 2, 2)
                imgui.Custom(IMGUI_SIZE_CONTENT, IMGUI_SIZE_CONTENT, Kreteni)
            imgui.EndGroup()

        imgui.EndWindow()
    imgui.ContextEnd()
end)

*/
interactivescene = {}

INTERACTIVESCENE_CLASS_PROP = 0
INTERACTIVESCENE_CLASS_SPRITE = 1
INTERACTIVESCENE_CLASS_MAX = INTERACTIVESCENE_CLASS_SPRITE

local SceneObjectProp = {}
SceneObjectProp.__index = SceneObjectProp

function SceneObjectProp:New()
    self.Class = INTERACTIVESCENE_CLASS_PROP

    self.Model = ""
    self.Pos = Vector(0, 0, 0)
    self.Ang = Angle(0, 0, 0)
    self.Scale = Vector(1, 1, 1)
    self.LightOrigin = Vector(0, 0, 0)
    self.Entity = NULL

    // DEBUG
    self.PosOffset = Vector(0, 0, 0)
    self.AngOffset = Angle(0, 0, 0)
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

function SceneObjectProp:GetLightOrigin()
    return self.LightOrigin
end

function SceneObjectProp:SetLightOrigin(pos)
    self.LightOrigin = pos
end

function SceneObjectProp:PreDraw(camera)
end

function SceneObjectProp:Draw(camera)
    local ent = self.Entity
    if not IsValid(ent) then return end

    render.SetLightingOrigin(self.LightOrigin)

    local modelMat = Matrix()
    modelMat:Translate(self.Pos + self.PosOffset)
    modelMat:Rotate(self.Ang + self.AngOffset)
    modelMat:Scale(self.Scale)

    ent:EnableMatrix("RenderMultiply", modelMat)
    ent:DrawModel()
end

function SceneObjectProp:PostDraw(camera)
end

function SceneObjectProp:Generate()
    if IsValid(self.Entity) then
        SafeRemoveEntity(self.Entity)
    end

    local ent = ClientsideModel(self.Model)
    if not IsValid(ent) then return end

    ent:SetNoDraw(true)
    ent:SetIK(false)

    self.Entity = ent
end



local SceneObjectSprite = {}
SceneObjectSprite.__index = SceneObjectSprite

function SceneObjectSprite:New()
    self.Class = INTERACTIVESCENE_CLASS_SPRITE

    self.Material = nil
    self.Additive = false
    self.Pos = Vector(0, 0, 0)
    self.Size = 16
    self.Color = Color(255, 255, 255)
end

function SceneObjectSprite:GetMaterial()
    return self.Material
end

function SceneObjectSprite:SetMaterial(path)
    self.Material = Material(path)
end

function SceneObjectSprite:GetAdditive()
    return self.Additive
end

function SceneObjectSprite:SetAdditive(additive)
    self.Additive = additive
end

function SceneObjectSprite:GetPos()
    return self.Pos
end

function SceneObjectSprite:SetPos(pos)
    self.Pos = pos
end

function SceneObjectSprite:GetColor()
    return self.Color
end

function SceneObjectSprite:SetColor(color)
    self.Color = color
end

function SceneObjectSprite:GetSize()
    return self.Size
end

function SceneObjectSprite:SetSize(size)
    self.Size = size
end

function SceneObjectSprite:PreDraw(camera)
end

function SceneObjectSprite:Draw(camera)
    if not self.Material or self.Material:IsError() then return end

    local pos = self.Pos
    local size = self.Size
    local color = self.Color
    local mat = self.Material

    local camPos = camera.Pos
    local camUp = camera.Ang:Up()
    local camRight = camera.Ang:Right()

    local halfSize = size / 2
    local topLeft = pos - camRight * halfSize + camUp * halfSize
    local topRight = pos + camRight * halfSize + camUp * halfSize
    local bottomLeft = pos - camRight * halfSize - camUp * halfSize
    local bottomRight = pos + camRight * halfSize - camUp * halfSize
    
    render.SetMaterial(mat)

    if self.Additive then
        render.OverrideBlend(true, BLEND_SRC_ALPHA, BLEND_ONE, BLENDFUNC_ADD)
    end

    render.DrawQuad(topLeft, topRight, bottomRight, bottomLeft, color)

    if self.Additive then
        render.OverrideBlend(false)
    end
end

function SceneObjectSprite:PostDraw(camera)
end



local SceneObjectUI = {}
SceneObjectUI.__index = SceneObjectUI

function SceneObjectUI:New()
    self.Pos = Vector(0, 0, 0)
    self.Ang = Angle(0, 0, 0)
    self.Scale = 0.1
    self.Context = {}
end

function SceneObjectUI:GetPos()
    return self.Pos
end

function SceneObjectUI:SetPos(pos)
    self.Pos = pos 
end

function SceneObjectUI:GetAngles()
    return self.Ang
end

function SceneObjectUI:SetAngles(ang)
    self.Ang = ang
end

function SceneObjectUI:GetScale()
    return self.Scale
end

function SceneObjectUI:SetScale(scale)
    self.Scale = scale
end

function SceneObjectUI:DoGUI()
end

function SceneObjectUI:PreDraw(camera)
end

function SceneObjectUI:Draw(camera)
    local pos = self.Pos
    local ang = self.Ang
    local scale = self.Scale
    local ctx = self.Context

    local camPos = camera.Pos
    local camAng = camera.Ang + camera.ViewAngles // USES DEBUG CODE
    local camFOV = camera.FOV
    local camX = camera.ScreenX
    local camY = camera.ScreenY
    local camW = camera.ScreenW
    local camH = camera.ScreenH

    local cursorX, cursorY = input.GetCursorPos()
    local sceneDir = util.AimVector(camAng, camFOV, cursorX - camX, cursorY - camY, camW, camH)
    sceneDir:Normalize()

    local planeIntersect = util.IntersectRayWithPlane(camPos, sceneDir, pos, ang:Up())
    local planeX = 0
    local planeY = 0

    if planeIntersect then
        local diff = (pos - planeIntersect)
        planeX = diff:Dot(-ang:Forward()) / scale
        planeY = diff:Dot(-ang:Right()) / scale

        planeX = math.floor(planeX)
        planeY = math.floor(planeY)
    end

    cam.Start3D2D(pos, ang, scale)
    imgui.Context3D2D(ctx, planeX, planeY, input.IsMouseDown(MOUSE_LEFT))
        self:DoGUI()
    imgui.ContextEnd()
    cam.End3D2D()
end

function SceneObjectUI:PostDraw(camera)
end



local SceneCamera = {}
SceneCamera.__index = SceneCamera

function SceneCamera:New(pos, ang, fov)
    self.Pos = pos or Vector(0, 0, 0)
    self.Ang = ang or Angle(0, 0, 0)
    self.FOV = fov or 90

    self.NearZ = 4
    self.FarZ = 16384

    self.Additive = false
    self.ColorMod = Color(255, 255, 255)
    self.AmbientLight = Color(75, 75, 75)

    self.ScreenX = 0
    self.ScreenY = 0
    self.ScreenW = 0
    self.ScreenH = 0

    // DEBUG
    self.ViewAngles = Angle(0, 0, 0)
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

function SceneCamera:GetAdditive()
    return self.Additive
end

function SceneCamera:SetAdditive(additive)
    self.Additive = additive
end

function SceneCamera:LookAt(pos)
    local dir = (self.Pos - pos)
    dir:Normalize()

    self.Ang = dir:Angle()
end

function SceneCamera:WorldToScreen(worldPos)
    local camPos = self.Pos
    local camAng = self.Ang + self.ViewAngles // HAS DEBUG VARIABLE
    local camFOV = self.FOV

    local screenW = self.ScreenW or ScrW()
    local screenH = self.ScreenH or ScrH()

    local viewDir = worldPos - camPos
    local forward = camAng:Forward()
    local right = camAng:Right()
    local up = camAng:Up()

    local localX = viewDir:Dot(forward)
    local localY = viewDir:Dot(right)
    local localZ = viewDir:Dot(up)

    if localX <= 0 then
        return false, -1, -1
    end

    local fovRad = math.rad(camFOV / 2)
    local scale = screenW / (2 * math.tan(fovRad))

    local screenX = (localY / localX) * scale + (screenW / 2)
    local screenY = -(localZ / localX) * scale + (screenH / 2)

    return true, screenX, screenY
end

function SceneCamera:Begin(x, y, w, h)
    self.ScreenX = x
    self.ScreenY = y
    self.ScreenW = w
    self.ScreenH = h

    // DEBUG CODE
    local up = input.IsKeyDown(KEY_PAD_8) and -1 or 0
    local down = input.IsKeyDown(KEY_PAD_2) and 1 or 0

    local left = input.IsKeyDown(KEY_PAD_4) and 1 or 0
    local right = input.IsKeyDown(KEY_PAD_6) and -1 or 0

    self.ViewAngles.p = self.ViewAngles.p + (up + down)
    self.ViewAngles.y = self.ViewAngles.y + (left + right)
    // DEBUG CODE

    cam.Start3D(self.Pos, self.Ang + self.ViewAngles, self.FOV, self.ScreenX, self.ScreenY, self.ScreenW, self.ScreenH, self.NearZ, self.FarZ)

    render.Clear(0, 0, 0, 0, true, true)

    render.SuppressEngineLighting(true)
    render.ResetModelLighting(self.AmbientLight.r / 255, self.AmbientLight.g / 255, self.AmbientLight.b / 255)
    render.SetColorModulation(self.ColorMod.r / 255, self.ColorMod.g / 255, self.ColorMod.b / 255)
    render.SetBlend(1)
end

function SceneCamera:End()
    render.SuppressEngineLighting(false)
    cam.End3D()
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

function SceneSkybox:Draw(camera)
    if not self.MaterialFaces then return end

    local pos = Vector(0, 0, 0)
    local size = camera.FarZ

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



local ScenePointLight = {}
ScenePointLight.__index = ScenePointLight

function ScenePointLight:New()
    self.type = MATERIAL_LIGHT_POINT
    self.color = Vector(0, 0, 0)
    self.pos = Vector(0, 0, 0)
    self.range = 0
    self.fiftyPercentDistance = 100
    self.zeroPercentDistance = 200
end

function ScenePointLight:SetPos(pos)
    self.pos = pos
end

function ScenePointLight:SetColor(color, intensity)
    self.color.x = color.r * intensity
    self.color.y = color.g * intensity
    self.color.z = color.b * intensity
end

function ScenePointLight:SetMinDistance(minDist)
    self.fiftyPercentDistance = minDist
end

function ScenePointLight:SetMaxDistance(maxDist)
    self.zeroPercentDistance = maxDist
end



local Scene = {}
Scene.__index = Scene

function Scene:New()
    self.Objects = {}
    self.Lights = {}
    self.Camera = nil
    self.Skybox = nil
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

function Scene:AddLight(light)
    table.insert(self.Lights, light)
end

function Scene:PreDrawObjects()
end

function Scene:PostDrawObjects()
end

function Scene:PreDrawSkybox()
end

function Scene:PostDrawSkybox()
end

function Scene:Draw()
    local camera = self.Camera
    if not camera then return end

    if self.Skybox then
        self:PreDrawSkybox()
            self.Skybox:Draw(camera)
        self:PostDrawSkybox()
    end

    local hasLights = #self.Lights > 0

    self:PreDrawObjects()
        if hasLights then
            render.SetLocalModelLights(self.Lights)
        end

        for i = 1, #self.Objects do
            local obj = self.Objects[i]

            obj:PreDraw(camera)
            obj:Draw(camera)
            obj:PostDraw(camera)
        end

        if hasLights then
            render.SetLocalModelLights()
        end
    self:PostDrawObjects()
end

function Scene:DrawDirect(x, y, w, h)
    local camera = self.Camera
    if not camera then return end

    camera:Begin(x, y, w, h)
        self:Draw()
    camera:End()
end

function interactivescene.CreatePointLight()
    local instance = {}
    setmetatable(instance, ScenePointLight)
    instance:New()

    return instance
end

function interactivescene.CreateProp()
    local instance = {}
    setmetatable(instance, SceneObjectProp)
    instance:New()

    return instance
end

function interactivescene.CreateSprite()
    local instance = {}
    setmetatable(instance, SceneObjectSprite)
    instance:New()

    return instance
end

function interactivescene.CreateUI()
    local instance = {}
    setmetatable(instance, SceneObjectUI)
    instance:New()

    return instance
end

function interactivescene.CreateScene()
    local instance = {}
    setmetatable(instance, Scene)
    instance:New()

    return instance
end

function interactivescene.DrawRT(scene, rt)
    local x = 0
    local y = 0
    local w = rt:Width()
    local h = rt:Height()

    render.PushRenderTarget(rt)
    render.OverrideAlphaWriteEnable(true, true)
        render.ClearDepth()
        render.Clear(0, 0, 0, 0)
    
        render.SetWriteDepthToDestAlpha(false)
        scene:DrawDirect(x, y, w, h)
        render.SetWriteDepthToDestAlpha(true)
    render.OverrideAlphaWriteEnable(false)
    render.PopRenderTarget()
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
        scene:DrawDirect(x, y, w, h)
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
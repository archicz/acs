local SceneObject = {}
SceneObject.__index = SceneObject

function SceneObject:New()

end

local SceneCamera = {}
SceneCamera.__index = SceneCamera

function SceneCamera:New()
    self.Pos = Vector(0, 0, 0)
    self.FOV = 90
end

local Scene = {}
Scene.__index = Scene

function Scene:New()

end

function Scene:ImportPAC()

end

/*local PANEL = {}

AccessorFunc( PANEL, "m_fAnimSpeed",	"AnimSpeed" )
AccessorFunc( PANEL, "vCamPos",			"CamPos" )
AccessorFunc( PANEL, "fFOV",			"FOV" )
AccessorFunc( PANEL, "vLookatPos",		"LookAt" )
AccessorFunc( PANEL, "aLookAngle",		"LookAng" )
AccessorFunc( PANEL, "colAmbientLight",	"AmbientLight" )
AccessorFunc( PANEL, "colColor",		"Color" )
AccessorFunc( PANEL, "bAnimated",		"Animated" )

function PANEL:Init()
	self.LastPaint = 0
	self.DirectionalLight = {}
	self.FarZ = 4096

	self:SetCamPos( Vector( 45, 0, 70 ) )
	self:SetLookAng( Angle(0, 180, 0) )
	self:SetFOV( 90 )

	self:SetText( "" )
	self:SetAnimSpeed( 0.5 )
	self:SetAnimated( false )

	self:SetAmbientLight( Color( 50, 50, 50 ) )

	self:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255) )
	self:SetDirectionalLight( BOX_FRONT, Color( 155, 155, 155) )

	self:SetColor( color_white )

    self.Props = {}

    for _, entry in pairs(kokoti[1]["children"]) do
        local partData = entry["self"]
        
        local prop = ClientsideModel(partData["Model"])
        if IsValid(prop) then
            prop:SetNoDraw(true)
            prop:SetIK(false)
            prop:SetPos(partData["Position"])
            prop:SetAngles(partData["Angles"])

            table.insert(self.Props, prop)
        end
    end

end

function PANEL:SetDirectionalLight( iDirection, color )
	self.DirectionalLight[ iDirection ] = color
end

function PANEL:DrawModel()

	local curparent = self
	local leftx, topy = self:LocalToScreen( 0, 0 )
	local rightx, bottomy = self:LocalToScreen( self:GetWide(), self:GetTall() )
	while ( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()

		local x1, y1 = curparent:LocalToScreen( 0, 0 )
		local x2, y2 = curparent:LocalToScreen( curparent:GetWide(), curparent:GetTall() )

		leftx = math.max( leftx, x1 )
		topy = math.max( topy, y1 )
		rightx = math.min( rightx, x2 )
		bottomy = math.min( bottomy, y2 )
		previous = curparent
	end

	render.ClearDepth( false )

	render.SetScissorRect( leftx, topy, rightx, bottomy, true )

    for _, prop in pairs(self.Props) do
        prop:DrawModel()
    end

	render.SetScissorRect( 0, 0, 0, 0, false )

end

function PANEL:Paint( w, h )

	local x, y = self:LocalToScreen( 0, 0 )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = ( self.vLookatPos - self.vCamPos ):Angle()
	end

	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( Vector(0, 0, 0) )
	render.ResetModelLighting( self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255 )
	render.SetColorModulation( self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255 )
	render.SetBlend( ( self:GetAlpha() / 255 ) * ( self.colColor.a / 255 ) ) -- * surface.GetAlphaMultiplier()

	for i = 0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r / 255, col.g / 255, col.b / 255 )
		end
	end

	self:DrawModel()

	render.SuppressEngineLighting( false )
	cam.End3D()

	self.LastPaint = RealTime()

end

function PANEL:OnRemove()
end

derma.DefineControl("D3DScene", "A panel containing a 3D scene", PANEL, "DButton")



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
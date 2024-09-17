local function TestMenu()
	local frame = vgui.Create("DFrame")
	frame:SetSize(1024, 1024)
	frame:SetTitle("Derma Frame")
    frame:Center()
	frame:MakePopup()

    local icon = vgui.Create("D3DScene", frame)
    icon:Dock(FILL)
    -- icon:SetModel("models/hunter/blocks/cube025x025x025.mdl")
end

concommand.Add("3dinteractive", TestMenu)
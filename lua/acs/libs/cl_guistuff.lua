local function openMenu()
	local frame = vgui.Create("DFrame")
	frame:SetSize(400, 600)
    frame:Center()
	frame:SetTitle("Derma Testing")
    frame:SetDraggable(false)
	frame:MakePopup()
end

concommand.Add("open_stuff", openMenu)
if not input then return end

local UnlockRequested = false
local UnlockPanel = false

local function ResetState()
    UnlockRequested = false
end

local function CheckState()
    if not UnlockRequested and ispanel(UnlockPanel) then
        UnlockPanel:Remove()
        UnlockPanel = false
    end
end

function input.UnlockCursor()
    UnlockRequested = true
    if ispanel(UnlockPanel) then return end

    UnlockPanel = vgui.Create("DFrame")
    UnlockPanel:SetSize(0, 0)
    UnlockPanel:SetPos(0, 0)
    UnlockPanel:SetPaintedManually(true)
    UnlockPanel:MakePopup()
end

hook.Add("PreRender", "CursorUnlockReset", ResetState)
hook.Add("PostRender", "CursorUnlockCheck", CheckState)
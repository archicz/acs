if not input then return end

local MouseWheel = 0

local function UpdateMouseWheel(cmd)
    MouseWheel = cmd:GetMouseWheel()
end

function input.GetMouseWheel()
    return MouseWheel
end

hook.Add("CreateMove", "InputMouseWheel", UpdateMouseWheel)
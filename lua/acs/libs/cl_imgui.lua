imgui = {}

local MouseX = 0
local MouseY = 0

local LeftPressing = false
local PreviousLeftPressing = false
local LeftPressed = false

local RightPressing = false
local PreviousRightPressing = false
local RightPressed = false

local function CursorInRect(x, y, w, h)
    return MouseX >= x and MouseX <= x + w and MouseY >= y and MouseY <= y + h
end

function imgui.Start2D()
    input.UnlockCursor()
    MouseX, MouseY = input.GetCursorPos()

    PreviousLeftPressing = LeftPressing
    LeftPressing = input.IsMouseDown(MOUSE_LEFT)
    LeftPressed = (LeftPressing and not PreviousLeftPressing)

    PreviousRightPressing = RightPressing
    RightPressing = input.IsMouseDown(MOUSE_RIGHT)
    RightPressed = (RightPressing and not PreviousRightPressing)

    cam.Start2D()
end

function imgui.End2D()
    cam.End2D()
end
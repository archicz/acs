imgui = {}

local BaseWidth = 1920
local BaseHeight = 1080
local ScaleDPI = math.min(ScrW() / BaseWidth, ScrH() / BaseHeight)

local Padding = 4
local TextPadding = 2

local ContextStack = util.Stack()
local CurrentContext = false

function imgui.Button(label, w, h)
    local window = CurrentContext.Window
    if not window then return end

    local x, y = imgui.GetCursor()
    local isHovering = imgui.MouseInRect(x, y, w, h)
    local hasClicked = imgui.HasClicked()

    imgui.Draw(function()
        if isHovering then
            surface.SetDrawColor(60, 60, 60)
        else
            surface.SetDrawColor(50, 50, 50)
        end

        surface.DrawRect(x, y, w, h)

        surface.SetFont("DermaDefault")
        local textW, textH = surface.GetTextSize(label)

        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x + w / 2 - textW / 2, y + h / 2 - textH / 2)
        surface.DrawText(label)
    end)

    imgui.ContentAdd(w, h)

    return isHovering and hasClicked
end

function imgui.Draw(drawFn)
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    table.insert(active.drawQueue, drawFn)
end

function imgui.MouseInRect(x, y, w, h)
    local window = CurrentContext.Window
    if not window then return false end

    return CurrentContext.MouseX >= x and CurrentContext.MouseX <= x + w and CurrentContext.MouseY >= y and CurrentContext.MouseY <= y + h
end

function imgui.HasClicked()
    return CurrentContext.LeftPressed
end

function imgui.GetCursor()
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    return active.cursorX, active.cursorY
end

function imgui.ContentAdd(w, h)
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    if active.sameLine then
        active.cursorX = active.cursorX + w + Padding
        active.lineHeight = math.max(active.lineHeight, h)
    else
        active.cursorX = active.x + Padding
        active.cursorY = active.cursorY + h + Padding
    end
end

function imgui.SameLine()
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    active.sameLine = true
end

function imgui.NewLine()
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    active.cursorX = active.x + Padding
    active.cursorY = active.y + Padding + active.lineHeight + Padding
    active.sameLine = false
    active.lineHeight = 0
end

function imgui.BeginGroup(w, h)
    local window = CurrentContext.Window
    if not window then return end

    local x, y = imgui.GetCursor()

    local canvas =
    {
        x = x,
        y = y,
        w = w,
        h = h,

        drawQueue = {},

        cursorX = x + Padding,
        cursorY = y + Padding,
        sameLine = false,
        lineHeight = 0
    }

    window.canvasStack:Push(canvas)
    window.currentCanvas = window.canvasStack:Top()
end

function imgui.EndGroup()
    local window = CurrentContext.Window
    if not window then return end

    local currentCanvas = window.canvasStack:Pop()
    local previousCanvas = window.canvasStack:Top()
    if not currentCanvas then return end

    window.currentCanvas = previousCanvas

    imgui.Draw(function()
        surface.SetDrawColor(40, 40, 40)
        surface.DrawRect(currentCanvas.x, currentCanvas.y, currentCanvas.w, currentCanvas.h)

        surface.SetDrawColor(100, 100, 100)
        surface.DrawOutlinedRect(currentCanvas.x, currentCanvas.y, currentCanvas.w, currentCanvas.h)
    end)

    for i = 1, #currentCanvas.drawQueue do
        imgui.Draw(currentCanvas.drawQueue[i])
    end
end

function imgui.BeginWindow(title, x, y, w, h)
    local window =
    {
        title = title,
        x = x,
        y = y,
        w = w,
        h = h,

        drawQueue = {},
        canvasStack = util.Stack(),
        currentCanvas = nil,

        cursorX = x + Padding,
        cursorY = y + Padding,
        sameLine = false,
        lineHeight = 0
    }

    CurrentContext.Window = window
end

function imgui.EndWindow()
    local window = CurrentContext.Window
    if not window then return end

    surface.SetDrawColor(32, 32, 32)
    surface.DrawRect(window.x, window.y, window.w, window.h)

    surface.SetDrawColor(100, 100, 100)
    surface.DrawOutlinedRect(window.x, window.y, window.w, window.h)
    
    for i = 1, #window.drawQueue do
        local drawFn = window.drawQueue[i]
        drawFn()
    end

    CurrentContext.Window = nil
end

function imgui.Context2D(ctx)
    ContextStack:Push(ctx)
    CurrentContext = ContextStack:Top()

    cursorunlock.Request()
    CurrentContext.MouseX, CurrentContext.MouseY = input.GetCursorPos()

    CurrentContext.PreviousLeftPressing = (CurrentContext.LeftPressing or false)
    CurrentContext.LeftPressing = input.IsMouseDown(MOUSE_LEFT)
    CurrentContext.LeftPressed = (CurrentContext.LeftPressing and not CurrentContext.PreviousLeftPressing)

    CurrentContext.PreviousRightPressing = (CurrentContext.RightPressing or false)
    CurrentContext.RightPressing = input.IsMouseDown(MOUSE_RIGHT)
    CurrentContext.RightPressed = (CurrentContext.RightPressing and not CurrentContext.PreviousRightPressing)

    CurrentContext.Window = nil
end

function imgui.ContextEnd()
    if not ContextStack then return end

    ContextStack:Pop()
    CurrentContext = ContextStack:Top()
end
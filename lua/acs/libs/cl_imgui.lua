imgui = {}

IMGUI_POS_CENTER = -1
IMGUI_SIZE_CONTENT = -1

local BaseWidth = 1920
local BaseHeight = 1080
local ScaleDPI = math.min(ScrW() / BaseWidth, ScrH() / BaseHeight)

-- local Padding = 4
-- local TextPadding = 2

local ContextStack = util.Stack()
local CurrentContext = false

function imgui.Button(label, w, h)
    local window = CurrentContext.Window
    if not window then return end

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

    local x = active.cursorX
    local y = active.cursorY

    local paddingLeft = active.paddingLeft or 0
    local paddingTop = active.paddingTop or 0

    return x + paddingLeft, y + paddingTop
end

function imgui.GetLayout()
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    local w = active.w
    local h = active.h

    local paddingLeft = active.paddingLeft or 0
    local paddingTop = active.paddingTop or 0
    local paddingRight = active.paddingRight or 0
    local paddingBottom = active.paddingBottom or 0

    return w - (paddingRight + paddingLeft), h - (paddingBottom + paddingTop)
end

function imgui.SetPadding(left, top, right, bottom)
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    active.paddingLeft = left
    active.paddingTop = top
    active.paddingRight = right
    active.paddingBottom = bottom
end

function imgui.ContentAdd(w, h)
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    local paddingLeft = active.paddingLeft or 0
    local paddingTop = active.paddingTop or 0
    local paddingRight = active.paddingRight or 0
    local paddingBottom = active.paddingBottom or 0

    if active.sameLine then
        active.cursorX = active.cursorX + w + paddingRight
        active.lineHeight = math.max(active.lineHeight, h)
    else
        active.cursorX = active.x
        active.cursorY = active.cursorY + h + paddingBottom
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

    active.cursorX = active.x
    active.cursorY = active.y + active.lineHeight
    active.sameLine = false
    active.lineHeight = 0
end

function imgui.BeginGroup(w, h)
    local window = CurrentContext.Window
    if not window then return end

    local parentW, parentH = imgui.GetLayout()
    local x, y = imgui.GetCursor()

    if w == IMGUI_SIZE_CONTENT then
        w = parentW
    end

    if h == IMGUI_SIZE_CONTENT then
        h = parentH
    end

    local canvas =
    {
        x = x,
        y = y,
        w = w,
        h = h,

        drawQueue = {},

        cursorX = x,
        cursorY = y,
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
        surface.SetDrawColor(80, 80, 80)
        surface.DrawRect(currentCanvas.x, currentCanvas.y, currentCanvas.w, currentCanvas.h)
    end)

    imgui.Draw(function()
        render.SetScissorRect(currentCanvas.x, currentCanvas.y, currentCanvas.x + currentCanvas.w, currentCanvas.y + currentCanvas.h, true)
    end)

    for i = 1, #currentCanvas.drawQueue do
        imgui.Draw(currentCanvas.drawQueue[i])
    end

    imgui.Draw(function()
        render.SetScissorRect(0, 0, 0, 0, false)
    end)

    imgui.ContentAdd(currentCanvas.w, currentCanvas.h)
end

function imgui.BeginWindow(title, x, y, w, h)
    if x == IMGUI_POS_CENTER then
        x = ScrW() / 2 - w / 2
    end 
    
    if y == IMGUI_POS_CENTER then
        y = ScrH() / 2 - h / 2
    end

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

        cursorX = x,
        cursorY = y,
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
    
    for i = 1, #window.drawQueue do
        local drawFn = window.drawQueue[i]
        drawFn()
    end

    CurrentContext.Window = nil
end

function imgui.Context2D(ctx)
    ContextStack:Push(ctx)
    CurrentContext = ContextStack:Top()

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
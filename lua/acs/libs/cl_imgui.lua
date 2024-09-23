imgui = {}

IMGUI_POS_CENTER = -1
IMGUI_SIZE_CONTENT = -1

IMGUI_SLIDER_FORMAT_ABS = 0
IMGUI_SLIDER_FORMAT_DEC = 1

local BaseWidth = 1920
local BaseHeight = 1080
local ScaleDPI = math.min(ScrW() / BaseWidth, ScrH() / BaseHeight)

-- local Padding = 4
-- local TextPadding = 2

local ContextStack = util.Stack()
local CurrentContext = false

function imgui.Button(label, w, h)
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

    if isHovering then
        input.SetCursorType("hand")
    end

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

function imgui.Label(label)
    local parentW, parentH = imgui.GetLayout()
    local x, y = imgui.GetCursor()

    surface.SetFont("DermaDefault")
    local textW, textH = surface.GetTextSize(label)

    local w = math.min(textW, parentW)
    local h = textH

    imgui.Draw(function()
        surface.SetTextColor(255, 255, 255)
        surface.SetTextPos(x, y)
        surface.DrawText(label)
    end)

    imgui.ContentAdd(w, h)
end

function imgui.Checkbox(label, checked)
    local x, y = imgui.GetCursor()

    local boxSize = 16
    local boxSpacing = 4

    surface.SetFont("DermaDefault")
    local textW, textH = surface.GetTextSize(label)

    local isHovering = imgui.MouseInRect(x, y, boxSize, boxSize)
    local hasClicked = isHovering and imgui.HasClicked()

    if isHovering then
        input.SetCursorType("hand")
    end

    if hasClicked then
        checked = not checked
    end

    imgui.Draw(function()
        surface.SetDrawColor(50, 50, 50)
        surface.DrawRect(x, y, boxSize, boxSize)

        surface.SetDrawColor(255, 255, 255)
        surface.DrawOutlinedRect(x, y, boxSize, boxSize)

        if checked then
            surface.SetDrawColor(100, 255, 100)
            surface.DrawRect(x + 4, y + 4, boxSize - 8, boxSize - 8)
        end

        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x + boxSize + boxSpacing, y + (boxSize / 2) - (textH / 2))
        surface.DrawText(label)
    end)

    imgui.ContentAdd(boxSize + boxSpacing + textW, boxSize)

    return checked
end

function imgui.SliderInternal(label, minValue, maxValue, valueFormat, value)
    local parentW, parentH = imgui.GetLayout()
    local x, y = imgui.GetCursor()

    local sliderHeight = 6
    local textSpacing = 4
    local valueText = ""

    if valueFormat == IMGUI_SLIDER_FORMAT_ABS then
        valueText = string.format("%i", value)
    elseif valueFormat == IMGUI_SLIDER_FORMAT_DEC then
        valueText = string.format("%.1f", value)
    end

    surface.SetFont("DermaDefault")
    local labelTextW, labelTextH = surface.GetTextSize(label)
    local valueTextW, valueTextH = surface.GetTextSize(valueText)

    local w = parentW
    local h = sliderHeight + math.max(labelTextH, valueTextH) + textSpacing

    local isHovering = imgui.MouseInRect(x, y, w, h)
    local isPressing = isHovering and imgui.IsPressing()

    if isHovering then
        input.SetCursorType("hand")
    end
    
    if isPressing then
        local decPlaces = 1

        if valueFormat == IMGUI_SLIDER_FORMAT_ABS then
            decPlaces = 1
        elseif valueFormat == IMGUI_SLIDER_FORMAT_DEC then
            decPlaces = 2
        end

        local mouseX = imgui.GetMouseX()
        local relativeX = mouseX - x
        local perc = math.Round(relativeX / w, decPlaces)
        local finalValue = minValue + (maxValue - minValue) * perc

        value = finalValue
    end

    local valuePerc = (value - minValue) / (maxValue - minValue)

    imgui.Draw(function()
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x, y)
        surface.DrawText(label)

        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x + w - valueTextW, y)
        surface.DrawText(valueText)

        surface.SetDrawColor(100, 175, 100)
        surface.DrawRect(x, y + h - sliderHeight, w, sliderHeight)

        surface.SetDrawColor(100, 255, 100)
        surface.DrawRect(x, y + h - sliderHeight, valuePerc * w, sliderHeight)
    end)

    imgui.ContentAdd(w, h)

    return value
end

function imgui.SliderInt(label, minValue, maxValue, value)
    return imgui.SliderInternal(label, minValue, maxValue, IMGUI_SLIDER_FORMAT_ABS, value)
end

function imgui.SliderDecimal(label, minValue, maxValue, value)
    return imgui.SliderInternal(label, minValue, maxValue, IMGUI_SLIDER_FORMAT_DEC, value)
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

function imgui.GetMouseX()
    return CurrentContext.MouseX
end

function imgui.HasClicked()
    return CurrentContext.LeftPressed
end

function imgui.IsPressing()
    return CurrentContext.LeftPressing
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

    local x = active.x
    local y = active.y

    local cursorX = active.cursorX
    local cursorY = active.cursorY

    local filledW = cursorX - x
    local filledH = cursorY - y
    
    local w = active.w
    local h = active.h

    local paddingLeft = active.paddingLeft or 0
    local paddingTop = active.paddingTop or 0
    local paddingRight = active.paddingRight or 0
    local paddingBottom = active.paddingBottom or 0

    return w - (paddingRight + paddingLeft + filledW), h - (paddingBottom + paddingTop + filledH)
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
        -- active.sameLineHeightLast = h
        active.sameLineHeightMax = math.max(active.sameLineHeightMax, h)
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
    active.sameLineCursorX = active.cursorX
    active.sameLineCursorY = active.cursorY
end

function imgui.NewLine()
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    local paddingBottom = active.paddingBottom or 0

    if active.sameLine then
        active.cursorX = active.sameLineCursorX
        active.cursorY = active.sameLineCursorY + active.sameLineHeightMax + paddingBottom
    else
        active.cursorX = active.x
        active.cursorY = active.y + active.sameLineHeightMax + paddingBottom
    end

    active.sameLine = false
    active.sameLineHeightMax = 0
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
        sameLineHeightMax = 0
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
        surface.SetDrawColor(80, 80, 80)--, 100)
        surface.DrawRect(currentCanvas.x, currentCanvas.y, currentCanvas.w, currentCanvas.h)
    end)

    imgui.Draw(function()
        -- render.SetStencilScissorRect(currentCanvas.x, currentCanvas.y, currentCanvas.x + currentCanvas.w, currentCanvas.y + currentCanvas.h, true)
        render.SetScissorRect(currentCanvas.x, currentCanvas.y, currentCanvas.x + currentCanvas.w, currentCanvas.y + currentCanvas.h, true)
    end)

    for i = 1, #currentCanvas.drawQueue do
        imgui.Draw(currentCanvas.drawQueue[i])
    end

    imgui.Draw(function()
        -- render.SetStencilScissorRect(0, 0, 0, 0, false)
        render.SetScissorRect(0, 0, 0, 0, false)
    end)

    imgui.ContentAdd(currentCanvas.w, currentCanvas.h)
end

function imgui.BeginWindow(title, x, y, w, h)
    if w == IMGUI_SIZE_CONTENT then
        w = CurrentContext.MaxWidth
    end

    if h == IMGUI_SIZE_CONTENT then
        h = CurrentContext.MaxHeight
    end

    if x == IMGUI_POS_CENTER then
        x = CurrentContext.MaxWidth / 2 - w / 2
    end 
    
    if y == IMGUI_POS_CENTER then
        y = CurrentContext.MaxHeight / 2 - h / 2
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
        sameLineHeightMax = 0
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
    CurrentContext.MaxWidth = ScrW()
    CurrentContext.MaxHeight = ScrH()
end

function imgui.ContextEnd()
    if not ContextStack then return end

    ContextStack:Pop()
    CurrentContext = ContextStack:Top()
end
imgui = {}

IMGUI_POS_CENTER = -1
IMGUI_SIZE_CONTENT = -1

IMGUI_SLIDER_FORMAT_ABS = 0
IMGUI_SLIDER_FORMAT_DEC = 1

local ContextStack = util.Stack()
local CurrentContext = false

function imgui.LayoutCalculateWidth(numWidgets)
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    local paddingLeft = active.paddingLeft or 0
    local paddingRight = active.paddingTop or 0

    local layoutW, layoutH = imgui.GetLayout()
    local availableWidth = layoutW - paddingLeft - paddingRight
    local totalSpacing = (numWidgets - 1)
    local cellWidth = (availableWidth - totalSpacing) / numWidgets

    return math.floor(cellWidth)
end

function imgui.LayoutCalculateHeight(numWidgets)
    local window = CurrentContext.Window
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    local paddingTop = active.paddingTop or 0
    local paddingBottom = active.paddingBottom or 0

    local layoutW, layoutH = imgui.GetLayout()
    local availableHeight = layoutH - paddingTop - paddingBottom
    local totalSpacing = (numWidgets - 1)
    local cellHeight = (availableHeight - totalSpacing) / numWidgets

    return math.floor(cellHeight)
end

function imgui.VerticalSpacer(h)
    local parentW, parentH = imgui.GetLayout()

    if h == IMGUI_SIZE_CONTENT then
        h = parentH
    end

    imgui.ContentAdd(0, h)
end

function imgui.HorizontalSpacer(w)
    local parentW, parentH = imgui.GetLayout()

    if w == IMGUI_SIZE_CONTENT then
        w = parentW
    end

    imgui.ContentAdd(w, 0)
end

function imgui.VerticalScroll(scrollWidth, inCanvas, canvas)
    if not canvas then return end
    if not canvas.scrollable then return end

    local x, y = imgui.GetCursor()
    local canvasHeight = canvas.h

    local mouseWheelDelta = imgui.GetMouseWheel()
    local isHovering = imgui.MouseInRect(x, y, scrollWidth, canvasHeight)
    local scrollHeight = canvas.scrollHeight or 0
    local canScroll = (scrollHeight > 0)

    if inCanvas and not isHovering then
        isHovering = imgui.MouseInRect(canvas.x, canvas.y, canvas.w, canvas.h)
    end

    local scrollPerc = math.abs(canvas.scrollY / scrollHeight)
    local contentRatio = canvasHeight / (scrollHeight + canvasHeight)
    local barHeight = math.max(contentRatio * canvasHeight, 10)
    local barY = scrollPerc * (canvasHeight - barHeight)

    if scrollPerc == 1 then barY = barY + 1 end
	
    if canScroll and isHovering then
        canvas.scrollY = math.Clamp(canvas.scrollY + mouseWheelDelta * barHeight * 0.1, -scrollHeight, 0)
    end

    imgui.Draw(function()
        surface.SetDrawColor(70, 70, 70)
        surface.DrawRect(x, y, scrollWidth, canvasHeight)

        if isHovering then
            surface.SetDrawColor(200, 200, 200, 140)
        else
            surface.SetDrawColor(140, 140, 140, 140)
        end
        
        surface.DrawRect(x, y + barY, scrollWidth, barHeight)
    end)

    imgui.ContentAdd(scrollWidth, canvasHeight)

    return canvas.scrollY
end

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

        surface.SetDrawColor(75, 150, 75)
        surface.DrawRect(x, y + h - sliderHeight, w, sliderHeight)

        surface.SetDrawColor(100, 255, 100)
        surface.DrawRect(x, y + h - sliderHeight, valuePerc * w, sliderHeight)
    end)

    imgui.ContentAdd(w, h)

    return value
end

function imgui.SliderAbsolute(label, minValue, maxValue, value)
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
    if not window then return end

    local active = window
    local canvas = window.currentCanvas
    if canvas then active = canvas end

    local mx = imgui.GetMouseX()
    local my = imgui.GetMouseY()

    local withinRect = mx >= x and mx <= x + w and my >= y and my <= y + h
    local withinClip = mx >= active.x and mx <= active.x + active.w and my >= active.y and my <= active.y + active.h
    
    return withinRect and withinClip
end

function imgui.GetMouseX()
    return CurrentContext.MouseX or 0
end

function imgui.GetMouseY()
    return CurrentContext.MouseY or 0
end

function imgui.GetMouseWheel()
    return CurrentContext.MouseWheel or 0
end

function imgui.HasClicked()
    return CurrentContext.LeftPressed or false
end

function imgui.IsPressing()
    return CurrentContext.LeftPressing or false
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

    local cursorX = x + paddingLeft
    local cursorY = y + paddingTop 

    if canvas and canvas.scrollable then
        cursorY = cursorY + canvas.scrollY
    end

    return cursorX, cursorY
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
        active.sameLineHeightMax = math.max(active.sameLineHeightMax, h)
    else
        active.cursorX = active.x
        active.cursorY = active.cursorY + h + paddingBottom
    end

    if canvas and canvas.scrollable then
        local canvasH = canvas.h
        local filledH = canvas.cursorY - canvas.y

        canvas.scrollHeight = math.max(filledH - canvasH, 0)
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

function imgui.BeginGroup(w, h, scroll)
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
        sameLineHeightMax = 0,
    }

    if scroll != nil then
        canvas.scrollable = true
        canvas.scrollY = scroll
    end

    window.canvasStack:Push(canvas)
    window.currentCanvas = window.canvasStack:Top()

    return canvas
end

function imgui.EndGroup(noDraw)
    local window = CurrentContext.Window
    if not window then return end

    local currentCanvas = window.canvasStack:Pop()
    local previousCanvas = window.canvasStack:Top()
    if not currentCanvas then return end

    local x = currentCanvas.x
    local y = currentCanvas.y
    local w = currentCanvas.w
    local h = currentCanvas.h

    local paddingLeft = currentCanvas.paddingLeft or 0
    local paddingTop = currentCanvas.paddingTop or 0
    local paddingRight = currentCanvas.paddingRight or 0
    local paddingBottom = currentCanvas.paddingBottom or 0

    window.currentCanvas = previousCanvas

    if not noDraw then
        imgui.Draw(function()
            surface.SetDrawColor(80, 80, 80)
            surface.DrawRect(x, y, w, h)
        end)
    end
    
    imgui.Draw(function()
        render.SetScissorRect(
            x + paddingLeft,
            y + paddingTop,
            x + (w - paddingRight),
            y + (h - paddingBottom),
            true
        )
    end)

    for i = 1, #currentCanvas.drawQueue do
        imgui.Draw(currentCanvas.drawQueue[i])
    end

    imgui.Draw(function()
        render.SetScissorRect(0, 0, 0, 0, false)
    end)

    imgui.ContentAdd(w, h)
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

    CurrentContext.Window = nil
    CurrentContext.MaxWidth = ScrW()
    CurrentContext.MaxHeight = ScrH()
end

function imgui.Context3D2D(ctx)
    ContextStack:Push(ctx)
    CurrentContext = ContextStack:Top()

    CurrentContext.Window = nil
    CurrentContext.MaxWidth = 512
    CurrentContext.MaxHeight = 512
end

function imgui.PushInput()
    CurrentContext.MouseX, CurrentContext.MouseY = input.GetCursorPos()
    CurrentContext.MouseWheel = input.GetMouseWheel()

    CurrentContext.PreviousLeftPressing = (CurrentContext.LeftPressing or false)
    CurrentContext.LeftPressing = input.IsMouseDown(MOUSE_LEFT)
    CurrentContext.LeftPressed = (CurrentContext.LeftPressing and not CurrentContext.PreviousLeftPressing)

    CurrentContext.PreviousRightPressing = (CurrentContext.RightPressing or false)
    CurrentContext.RightPressing = input.IsMouseDown(MOUSE_RIGHT)
    CurrentContext.RightPressed = (CurrentContext.RightPressing and not CurrentContext.PreviousRightPressing)
end

function imgui.PushInput3D(x, y, leftClick)
    CurrentContext.MouseX = x
    CurrentContext.MouseY = y
    CurrentContext.MouseWheel = 0

    CurrentContext.PreviousLeftPressing = (CurrentContext.LeftPressing or false)
    CurrentContext.LeftPressing = leftClick
    CurrentContext.LeftPressed = (CurrentContext.LeftPressing and not CurrentContext.PreviousLeftPressing)

    CurrentContext.PreviousRightPressing = false
    CurrentContext.RightPressing = false
    CurrentContext.RightPressed = false
end

function imgui.ContextEnd()
    if not ContextStack then return end

    ContextStack:Pop()
    CurrentContext = ContextStack:Top()
end
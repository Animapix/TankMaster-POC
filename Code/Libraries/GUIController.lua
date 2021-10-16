local controls = {}

addControl = function(control)
    table.insert(controls,control)
end

removeControl = function(other)
    for i,control in pairs(controls) do
        if control == other then 
            table.remove(controls, i)
            return
        end
    end
end

updateGUI = function(dt)
    for __,control in pairs(controls) do
        control.update(dt)
    end
end

drawGUI = function()
    for __,control in pairs(controls) do
        control.draw()
    end
end

unloadGUI = function()
    controls = {}
end


function newControl(pX,pY)
    local control = {}

    control.x = pX or 0
    control.y = pY or 0
    control.visible = true
    control.parent = nil
    control.chidrens = {}

    control.addChild = function(child)
        child.parent = control
        table.insert(control.chidrens,child)
    end

    control.getRelativePosition = function()
        return control.getRelativeX(),control.getRelativeY()
    end

    control.getRelativeX = function()
        return control.parent ~= nil and control.x + control.parent.getRelativeX() or control.x
    end

    control.getRelativeY = function()
        return control.parent ~= nil and control.y + control.parent.getRelativeY() or control.y
    end

    control.update = function(dt)
        control.updateChildrens(dt)
    end

    control.updateChildrens = function(dt)
        for id,child in pairs(control.chidrens) do
            child.update(dt)
        end
    end

    control.draw = function()
        control.drawChildrens()
    end

    control.drawChildrens = function()
        for id,child in pairs(control.chidrens) do
            child.draw()
        end
    end

    return control
end

function newPanel(pX,pY,pWidth,pHeight,pColor,pOutlineColor)
    local panel = newControl(pX,pY)

    panel.width = pWidth or 0
    panel.height = pHeight or 0
    panel.color = pColor or {0.5,0.5,0.5,1}
    panel.outLineColor = pOutlineColor or {1,1,1,1}
    panel.image = nil
    panel.isHover = false
    panel.events = {}

    panel.setImage = function(pImage)
        panel.image = pImage
        panel.width  = pImage:getWidth()
        panel.height = pImage:getHeight()
    end

    panel.setEvent = function(pEventType, pFunction)
        panel.events[pEventType] = pFunction
    end

    panel.updatePanel = function(dt)
        local x,y = love.mouse.getX() /2, love.mouse.getY() /2 --love.graphics.inverseTransformPoint( love.mouse.getPosition() )
        if x > panel.getRelativeX() and x < panel.getRelativeX() + panel.width and
        y > panel.getRelativeY() and y < panel.getRelativeY() + panel.height then
            if panel.isHover == false then
                panel.isHover = true
                if panel.events["hover"] ~= nil then
                    panel.events["hover"]("begin")
                end
            end
        else
            if panel.isHover == true then
                panel.isHover = false
                if panel.events["hover"] ~= nil then
                    panel.events["hover"]("end")
                end
            end
        end
    end

    panel.update = function(dt)
        if panel.visible == false then return end
        panel.updatePanel()
        panel.updateChildrens()
    end

    panel.drawPanel = function()
        love.graphics.push()
        love.graphics.translate( panel.getRelativePosition())

        if panel.image == nil then
            love.graphics.setColor(panel.color)
            love.graphics.rectangle("fill",0,0,panel.width,panel.height)
            
            if panel.outLineColor ~= nil then
                love.graphics.setColor(panel.outLineColor)
                love.graphics.rectangle("line",0,0,panel.width,panel.height)
            end
            love.graphics.setColor(1,1,1,1)
        else
            love.graphics.draw(panel.image,0,0)
        end

        love.graphics.pop()
    end

    panel.draw = function()
        if panel.visible == false then return end
        panel.drawPanel()   
        panel.drawChildrens()
    end

    return panel
end

function newLabel(pX,pY,pWidth,pHeight,pText,pFont,pAlignH,pAlignV)
    local label = newPanel(pX,pY,pWidth,pHeight)

    label.text = pText
    label.Font = pFont
    label.textWidth = pFont:getWidth(pText)
    label.textHeight = pFont:getHeight(pText)
    label.textColor = nil
    label.alignH = pAlignH or "center"
    label.alignV = pAlignV or "center"

    label.drawLabel = function()
        love.graphics.push()
        love.graphics.translate(label.getRelativePosition())
        local defaultfont = love.graphics.getFont()
        love.graphics.setFont(label.Font)
        
        if label.textColor ~= nil then
            love.graphics.setColor(label.textColor)
        end

        local x = 0
        local y = 0
        if label.alignH == "center" then
            x = (label.width  - label.textWidth) / 2
        elseif label.alignH == "right" then
            x = label.width  - label.textWidth
        end
        if label.alignV == "center" then
            y = (label.height  - label.textHeight) / 2
        elseif label.alignV == "bottom" then
            y = label.height  - label.textHeight
        end

        love.graphics.print(label.text, x, y)
        love.graphics.setColor(1,1,1,1)
        love.graphics.setFont(defaultfont)
        love.graphics.pop()
    end

    label.draw = function()
        label.drawLabel()
        label.drawChildrens()
    end
    
    label.setText = function(value)
        label.text = value
        label.textWidth = pFont:getWidth(label.text)
        label.textHeight = pFont:getHeight(label.text)
    end

    return label
end

function newButton(pX,pY,pWidth,pHeight,pText,pFont)
    local button = newLabel(pX,pY,pWidth,pHeight,pText,pFont)
    button.defaultImage = nil
    button.hoverImage = nil
    button.pressedImage = nil
    button.isPressed = false
    button.oldButtonState = false
    
    button.updateButton = function(dt)
        if button.isHover and love.mouse.isDown(1) and
            button.isPressed == false and
            button.oldButtonState == false then
            button.isPressed = true
            if button.events["pressed"] ~= nil then
                button.events["pressed"]("begin")
            end
        else
            if button.isPressed == true and love.mouse.isDown(1) == false then
                button.isPressed = false
                if button.events["pressed"] ~= nil then
                    button.events["pressed"]("end")
                end
            end
        end
        button.oldButtonState = love.mouse.isDown(1)
    end

    button.update = function(dt)
        button.updatePanel(dt)
        button.updateButton(dt)
        button.updateChildrens(dt)
    end

    button.drawButton = function()
        if button.isPressed then
            button.image = button.pressedImage
        elseif button.isHover then
            button.image = button.hoverImage
        else
            button.image = button.defaultImage
        end
        button.drawPanel()
        button.drawLabel()
    end

    button.draw = function()
        button.drawButton()
        button.drawChildrens()
    end

    button.setImage = function(pImage, pHoverImage, pPressedImage)
        button.image = pImage
        button.defaultImage = pImage
        button.hoverImage  = pHoverImage
        button.pressedImage = pPressedImage
        button.width  = pImage:getWidth()
        button.height = pImage:getHeight()
    end

    return button
end

function newCheckBox(pX,pY,pWidth,pHeight)
    local checkBox = newPanel(pX,pY,pWidth,pHeight)
    checkBox.defaultImage = nil
    checkBox.pressedImage = nil
    checkBox.isPressed = false
    checkBox.oldButtonState = false
    
    function checkBox:setState(pState)
        checkBox.isPressed = pState
    end

    checkBox.updateCheckBox = function(dt)
        if checkBox.isHover and love.mouse.isDown(1) and
            checkBox.isPressed == false and
            checkBox.oldButtonState == false then
            checkBox.isPressed = true
            if checkBox.events["pressed"] ~= nil then
                checkBox.events["pressed"]("on")
            end
        elseif checkBox.isHover and love.mouse.isDown(1) and
            checkBox.isPressed == true and
            checkBox.oldButtonState == false then
                checkBox.isPressed = false
                if checkBox.events["pressed"] ~= nil then
                    checkBox.events["pressed"]("off")
                end
        end
        checkBox.oldButtonState = love.mouse.isDown(1)
    end

    checkBox.update = function(dt)
        checkBox.updatePanel(dt)
        checkBox.updateCheckBox(dt)
        checkBox.updateChildrens(dt)
    end

    checkBox.drawCheckBox = function()
        if checkBox.isPressed then
            checkBox.image = checkBox.pressedImage
        else
            checkBox.image = checkBox.defaultImage
        end
        checkBox.drawPanel()
    end

    checkBox.draw = function()
        checkBox.drawCheckBox()
        checkBox.drawChildrens()
    end

    checkBox.setImage = function(pImage, pPressedImage)
        checkBox.image = pImage
        checkBox.defaultImage = pImage
        checkBox.pressedImage = pPressedImage
        checkBox.width  = pImage:getWidth()
        checkBox.height = pImage:getHeight()
    end

    return checkBox
end

function newProgressBar(pX,pY,pWidth,pHeight,pMax)
    local progressBar = newPanel(pX,pY,pWidth,pHeight)
    
    progressBar.max = pMax
    progressBar.value = pMax
    progressBar.barImage = nil

    progressBar.setValue = function(pValue)
        if pValue >= 0 and pValue <= progressBar.max then
            progressBar.value = pValue
        else
            print("ProgressBar.setValue - out of range")
        end
    end

    progressBar.drawProgressBar = function()
        progressBar.drawPanel()
        
        love.graphics.push()
        love.graphics.translate(progressBar.getRelativePosition())

        local barSize = progressBar.width * (progressBar.value / progressBar.max)
        
        if progressBar.barImage ~= nil then
            local barQuad = love.graphics.newQuad(0, 0,barSize, progressBar.height, progressBar.width, progressBar.height)
            love.graphics.draw(progressBar.barImage, barQuad, 0, 0)
        else
            love.graphics.rectangle("fill",0 , 0 , barSize, progressBar.height)
        end

        love.graphics.pop()
    end

    progressBar.draw = function()
        progressBar.drawProgressBar()
        progressBar.drawChildrens()
    end

    progressBar.setImage = function(pImage, pBarImage)
        progressBar.image = pImage
        progressBar.barImage = pBarImage
        progressBar.width  = pImage:getWidth()
        progressBar.height = pImage:getHeight()
    end

    return progressBar
end
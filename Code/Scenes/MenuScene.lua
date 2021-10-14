
local scene = newScene("menu")

scene.load = function()
    local fontTitle = love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 20)
    local font = love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 8)
    
    local panel = newPanel(300,150,200,150)

    local label = newLabel(0,50,200,40,"TANK MASTER",fontTitle)
    label.color = { 1,1,1,0.7 }
    panel.addChild(label)

    local button = newButton(50,105,100,15,"PLAY",font)
    button.setEvent("pressed", scene.onGameButtonPressed)
    panel.addChild(button)


    newTween(panel,"y",-200,150,0.8,tweenTypes.quarticOut)
    newTween(label,"y",label.y,10,0.8,tweenTypes.quarticInOut, 0.2)
    newTween(button,"y",button.y,75,0.8,tweenTypes.quarticInOut, 0.2)

    addControl(panel)
end

scene.onGameButtonPressed = function(pState)
    if pState == "end" then
        changeScene("game")
    end
end 

scene.update = function(dt)
    updateGUI(dt)
    updateTweening(dt)
end

scene.draw = function()
    drawGUI()
end

scene.mousePressed = function(pX,pY,pBtn)
end

scene.unload = function()
    unloadGUI()
end
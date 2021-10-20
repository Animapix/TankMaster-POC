require("Props.GUI.MainMenu")

local scene = newScene("menu")
local cursor
local background

scene.load = function()
    
    local mainMenu = newMainMenu()
    mainMenu.onPlayBtnPressed = function()
        mainMenu.hide()
        scene.fadeOut("game")
    end
    cursor = love.graphics.newImage("Assets/Images/HUD/Cursor.png")
    background = love.graphics.newImage("Assets/Images/Divers/Arena.png")
    mainMenu.show()
    newTween(scene,"opacity",0,1,0.5,tweenTypes.sinusoidalOut)
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
    scene.canvas = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.setCanvas(scene.canvas)
        local gameWidth,gameHeight = love.graphics.inverseTransformPoint(love.graphics.getDimensions())
        love.graphics.draw(background,-background:getWidth()/2 + gameWidth/2,-background:getHeight()/2 + gameHeight/2)
        drawGUI()
        local x,y = love.graphics.inverseTransformPoint( love.mouse.getPosition())
    love.graphics.draw(cursor, x - cursor:getWidth()/2, y - cursor:getHeight()/2 )
    love.graphics.setCanvas()

    love.graphics.setColor(1,1,1,scene.opacity)
    love.graphics.draw(scene.canvas, 0, 0, 0, 0.5, 0.5)
    love.graphics.setColor(1,1,1,1)
end

scene.mousePressed = function(pX,pY,pBtn)
end

scene.unload = function()
    unloadGUI()
end

scene.fadeOut = function(next)
    local tween = newTween(scene,"opacity",1.0,0,0.5,tweenTypes.sinusoidalIn)
    tween.onFinsish = function()
        changeScene(next)
    end
end
require("Props.Doors")
require("Props.Tank")
require("Props.Trail")
require("Props.Enemy")
require("Props.Gem")

require("Props.GUI.LifeBar")
require("Props.GUI.ScoreLabel")
require("Props.GUI.PauseMenu")
require("Props.GUI.GameOverMenu")
require("Props.GUI.HUD")

local scene = newScene("game")
local camera = require("Libraries.Utils.Camera")

local tank

local bounds
local doors = {}
local sceneState = "start"

local level = 1
local waves = 5
local spawnTimer = 1

-- Gui controls
local pauseMenu
local gameOverMenu
local HUD

local outArrowSprite

local music

scene.load = function()

    addNewSpritesLayer("floor")
    addNewSpritesLayer("trails")
    addNewSpritesLayer("shadows")
    addNewSpritesLayer("doors")
    addNewSpritesLayer("walls")
    addNewSpritesLayer("gems")
    addNewSpritesLayer("tank")
    addNewSpritesLayer("enemies")
    addNewSpritesLayer("bullets")
    addNewSpritesLayer("particles")
    addNewSpritesLayer("topWalls")

    bounds = { x = 400, y = 225 , width = 740 , height = 390 }
    scene.canvasPosition = newVector()


    newRectangleCollider(bounds.x + bounds.width/2 + 10, bounds.y, 20, 100, "door")
    
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/PlaceHolders/Floor.png"), "floor")
    outArrowSprite = newSprite(bounds.x + bounds.width / 2 - 40,bounds.y,love.graphics.newImage("Assets/Images/HUD/Arrow.png"), "floor")
    outArrowSprite.opacity = 0.0
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/PlaceHolders/Walls.png"), "walls")
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/Images/Arena/Doors bottom.png"), "walls")
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/Images/Arena/Doors top.png"), "topWalls")

    doors.top = newDoors(bounds.x,bounds.y - bounds.height / 2 - 5.5, 0)
    doors.bottom = newDoors(bounds.x,bounds.y + bounds.height / 2 + 5.5, 180)
    doors.left = newDoors(bounds.x - bounds.width/2 - 5.5, bounds.y, -90)
    doors.right = newDoors(bounds.x + bounds.width/2 + 5.5, bounds.y, 90)
    doors.left.open()

    tank = newTank(bounds.x - bounds.width/2 - 100,bounds.y, bounds)
    tank.canOutOfBounds = true
    sceneState = "start"

    --Setup GUI
    HUD = newHUD()

    pauseMenu = newPauseMenu()
    pauseMenu.onResumeBtnPressed = function()
        sceneState = "game"
        pauseMenu.hide()
    end
    pauseMenu.onMainMenuBtnPressed = function()
        pauseMenu.hide()
        scene.fadeOut("menu")
    end

    gameOverMenu = newGameOverMenu()
    gameOverMenu.onMainMenuBtnPressed = function()
        gameOverMenu.hide()
        scene.fadeOut("menu")
    end

    level = 1
    waves = 5
    spawnTimer = 1

    music = love.audio.newSource("Assets/Musics/The3amAssociation_-_Ben_Apres_Rien .wav", "stream")
    music:setLooping( true )
    music:setVolume(0.1 * musicsLevel)
    music:play()

    newTween(scene,"opacity",0,1,0.5,tweenTypes.sinusoidalOut)
end

scene.update = function(dt)

    if sceneState == "start" then ---------------------- Start ------------------------
        scene.updateStart(dt)
    elseif sceneState == "game" then ---------------------- Game -----------------------
        scene.updateGame(dt)
    elseif sceneState == "end" then ---------------------- End of round ------------------------
        scene.updateEnd(dt)
    elseif sceneState == "goOut" then ---------------------- TANK GO OUT ------------------------
        scene.updateGoOut(dt)
    end

    scene.updateHUD(dt) 
    updateGUI(dt)
    updateTweening(dt)
    camera.update(dt,newVector(400,300))
end

scene.updateHUD = function(dt)
    HUD.lifeBar.value = tank.life
    HUD.pointsLabel.setScore(tank.score)
end

scene.updateStart = function(dt)
    -- move tank forward to center of arena
    if tank.position.x < bounds.x - 60 then
        tank.moveForward(dt)
    else
        tank.canOutOfBounds = false
        sceneState = "game"
        doors.left.close()
    end
    scene.updateTankAim()

    updateCollisions(dt)
    updateSprites(dt)
end

scene.updateGame = function(dt)
    scene.updateTankControls(dt)
    scene.updateTankAim()
    if love.mouse.isDown(2) then
        tank.secondaryShot()
    end
    scene.updateEnemiesSpawn(dt)

    if waves <= 0 and #getSprites("enemy") == 0 then
        sceneState = "end"
        doors.right.open()
        newTween(outArrowSprite,"opacity",outArrowSprite.opacity,1.0,0.8,tweenTypes.quarticIn)
        --outArrowSprite.visible = true
    end

    if tank.life <= 0 then
        sceneState = "pause"
        gameOverMenu.show()
    end

    updateCollisions(dt)
    updateSprites(dt)
end

scene.updateEnd = function(dt)
    -- wait for tank go out to right door
    tank.collideRightDoor = function()
        sceneState = "goOut"
        tank.canOutOfBounds = true
        newTween(outArrowSprite,"opacity",outArrowSprite.opacity,0.0,0.8,tweenTypes.quarticOut)
        --outArrowSprite.visible = false
        
        local gems = getSprites("gem")
        for __,gem in ipairs(gems) do
            gem.remove = true
            gem.collider.remove = true
        end

    end
    scene.updateTankControls(dt)
    scene.updateTankAim()
    updateCollisions(dt)
    updateSprites(dt)
end

scene.updateGoOut = function(dt)
    local tankAngle = math.deg(tank.rotation)%360
        -- move forward if tank is facing the door
        if tankAngle < 45 or tankAngle > 315 then
            tank.moveForward(dt)
        end

        -- turn tank to go right
        if tankAngle < 180 and tankAngle > 0 then
            tank.turnLeft(dt)
        elseif tankAngle >= 180 and tankAngle > 0 then
            tank.turnRight(dt)
        end
        scene.updateTankAim()
        -- reset tank when he was out of screen
        if tank.position.x > bounds.x + bounds.width / 2 + 50 then

            tank.reset(bounds.x - bounds.width/2 - 200,bounds.y)
            tank.canOutOfBounds = true
            level = level + 1 
            waves = 5
            spawnTimer = 1
            
            doors.right.close()

            local tween = newTween(scene,"canvasPosition.x",0,-scene.canvas:getWidth()/2,0.7,tweenTypes.quarticInOut)
            --Play sound
            local wooshSound = love.audio.newSource("Assets/Sounds/Power_Wooshes.wav", "static") 
            wooshSound:setVolume(0.4 * soundsLevel)
            wooshSound:play()
            tween.onFinsish = function()
                doors.left.open()
                sceneState = "start"
            end

        end
        updateCollisions(dt)
        updateSprites(dt)
end

scene.updateEnemiesSpawn = function(dt)
    if waves <= 0  then
        return
    end
    spawnTimer = spawnTimer - dt
    if spawnTimer > 0 then return end
    spawnTimer = 5

    local amountOfEnemies = level * 5

    waves = waves - 1
    
    local spawnDoors = { "top", "left", "right", "bottom" }
    local numberOfDoors = love.math.random(1,4)

    for i = 1, numberOfDoors do
        local randomDoor = love.math.random(1,#spawnDoors)
        scene.spawnEnemies(amountOfEnemies/numberOfDoors, spawnDoors[randomDoor])
        table.remove(spawnDoors,randomDoor)
    end
    
end

scene.spawnEnemies = function(pQuantity, pSide)
    
    if pSide == "left" then
        for i=0, pQuantity do
            local x = math.floor(i / 4) * -20 + bounds.x - bounds.width/2 - 50 + love.math.random(-5,5)
            local y = i%4 * -20 + bounds.y + 30    + love.math.random(-5,5)
            local enemy = newEnemy(x,y,tank,bounds)
            enemy.velocity = newVector(enemy.speed,0)
            doors.left.open()
            doors.left.closeWithDelay(pQuantity/4/2 + 0.5)
        end
    elseif pSide == "right" then
        for i=0, pQuantity do
            local x = math.floor(i / 4) * 20 + bounds.x + bounds.width/2 + 50 + love.math.random(-5,5)
            local y = i%4 * -20 + bounds.y + 30    + love.math.random(-5,5)
            local enemy = newEnemy(x,y,tank,bounds)
            enemy.velocity = newVector(-enemy.speed,0)
            doors.right.open()
            doors.right.closeWithDelay(pQuantity/4/2 + 0.5)
        end
    elseif pSide == "top" then
        for i=0, pQuantity do
            local x = i%4 * -20 + bounds.x + 30 + love.math.random(-5,5)
            local y = math.floor(i / 4) * -20 + bounds.y - bounds.height/2 - 50 + love.math.random(-5,5)
            local enemy = newEnemy(x,y,tank,bounds)
            enemy.velocity = newVector(0,enemy.speed)
            doors.top.open()
            doors.top.closeWithDelay(pQuantity/4/2 + 0.5)
        end
    elseif pSide == "bottom" then
        for i=0, pQuantity do
            local x = i%4 * -20 + bounds.x + 30    --+ love.math.random(-5,5)
            local y = math.floor(i / 4) * 20 + bounds.y + bounds.height/2 + 50 --+ love.math.random(-5,5)
            local enemy = newEnemy(x,y,tank,bounds)
            enemy.velocity = newVector(0,-enemy.speed)
            doors.bottom.open()
            doors.bottom.closeWithDelay(pQuantity/4/2 + 0.5)
        end
    end
end

scene.updateTankAim = function()
    local mousePosition =  newVector(love.graphics.inverseTransformPoint( love.mouse.getPosition()) )
    tank.aim(mousePosition)
end

scene.updateTankControls = function(dt)
    -- Tank controls
    if love.keyboard.isDown("z") then tank.moveForward(dt) end
    if love.keyboard.isDown("s") then tank.moveBackward(dt) end
    if love.keyboard.isDown("d") then tank.turnRight(dt) end
    if love.keyboard.isDown("q") then tank.turnLeft(dt) end
end

scene.draw = function()
    scene.canvas = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.setCanvas(scene.canvas)

        love.graphics.push()
            love.graphics.translate(math.floor(camera.x),math.floor(camera.y))
            drawSprites()
        love.graphics.pop()

    love.graphics.setCanvas()


    local guiCanvas = love.graphics.newCanvas(love.graphics.getDimensions())
    love.graphics.setCanvas(guiCanvas)
    drawGUI()
    love.graphics.setCanvas()


    love.graphics.setColor(1,1,1,scene.opacity)
    love.graphics.draw(scene.canvas, scene.canvasPosition.x, 0, 0, 0.5, 0.5)
    love.graphics.draw(scene.canvas, scene.canvasPosition.x + scene.canvas:getWidth()/2, 0, 0, 0.5, 0.5)
    love.graphics.draw(guiCanvas,0, 0, 0, 0.5, 0.5)
    love.graphics.setColor(1,1,1,1)
    
end

scene.mousePressed = function(pX,pY,pBtn)
    if pBtn == 1 and sceneState == "game" then
        tank.shot()
    end
end

scene.keyPressed = function(pKey)
    if pKey == "escape" and sceneState == "game" then
        pauseMenu.show()
        sceneState = "pause"
    elseif pKey == "escape" and sceneState == "pause" then
        pauseMenu.hide()
        sceneState = "game"
    end
end

scene.unload = function()
    unloadColliders()
    unloadSprites()
    unloadGUI()
    music:stop()
end

scene.fadeOut = function(next)
    local tween = newTween(scene,"opacity",1.0,0,0.5,tweenTypes.sinusoidalIn)
    tween.onFinsish = function()
        changeScene(next)
    end
end
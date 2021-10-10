require("Props.Tank")
require("Props.Enemy")

local scene = newScene("game")
local tank

local bounds
local doors
local sceneState = "start"

local level = 1
local waves = 5

scene.load = function()
    
    addNewSpritesLayer("floor")
    addNewSpritesLayer("walls")
    addNewSpritesLayer("tank")
    addNewSpritesLayer("enemies")
    addNewSpritesLayer("bullets")
    addNewSpritesLayer("topWalls")

    bounds = { x = 400, y = 225 , width = 740 , height = 390 }
    
    local doors = {
        left = newRectangleCollider(bounds.x - bounds.width/2 - 10, bounds.y, 20, 100, "door"),
        right = newRectangleCollider(bounds.x + bounds.width/2 + 10, bounds.y, 20, 100, "door"),
        top = newRectangleCollider(bounds.x, bounds.y - bounds.height / 2 - 10, 100,20, "door"),
        bottom = newRectangleCollider(bounds.x, bounds.y + bounds.height / 2 + 10, 100,20, "door"),
    }
    
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/PlaceHolders/Floor.png"), "floor")
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/PlaceHolders/Walls.png"), "walls")
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/PlaceHolders/DoorsTop.png"), "walls")
    newSprite(bounds.x,bounds.y,love.graphics.newImage("Assets/PlaceHolders/DoorsBottom.png"), "topWalls")


    tank = newTank(bounds.x - bounds.width/2 - 100,bounds.y, bounds)
    tank.canOutOfBounds = true
    sceneState = "start"

end

scene.update = function(dt)

    if sceneState == "start" then ---------------------- Start ------------------------
        
        -- move tank forward to center of arena
        if tank.position.x < bounds.x - 60 then
            tank.moveForward(dt)
        else
            tank.canOutOfBounds = false
            sceneState = "game"
        end
        scene.updateTankAim()

    elseif sceneState == "game" then ---------------------- Game ------------------------

        scene.updateTankControls(dt)
        scene.updateTankAim()
        if love.mouse.isDown(2) then
            tank.secondaryShot()
        end
        scene.updateEnemiesSpawn(dt)

        if waves <= 0 and #getSprites("enemy") == 0 then
            sceneState = "end"
            level = level + 1 
            waves = 5
        end
        
    elseif sceneState == "end" then ---------------------- End of round ------------------------

        -- wait for tank go out to right door
        tank.collideRightDoor = function()
            sceneState = "goOut"
            tank.canOutOfBounds = true
        end
        scene.updateTankControls(dt)
        scene.updateTankAim()
    
    elseif sceneState == "goOut" then ---------------------- TANK GO OUT ------------------------

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
            tank.reset(bounds.x - bounds.width/2 - 100,bounds.y)
            tank.canOutOfBounds = true
            sceneState = "start"
        end

    end
    
    updateCollisions(dt)
    updateSprites(dt)

end

local spn = 1

scene.updateEnemiesSpawn = function(dt)
    if waves <= 0  then
        return
    end
    spn = spn - dt
    if spn > 0 then return end
    spn = 5

    local amountOfEnemies = level * 10

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
        end
    elseif pSide == "right" then
        for i=0, pQuantity do
            local x = math.floor(i / 4) * 20 + bounds.x + bounds.width/2 + 50 + love.math.random(-5,5)
            local y = i%4 * -20 + bounds.y + 30    + love.math.random(-5,5)
            local enemy = newEnemy(x,y,tank,bounds)
            enemy.velocity = newVector(-enemy.speed,0)
        end
    elseif pSide == "top" then
        for i=0, pQuantity do
            local x = i%4 * -20 + bounds.x + 30 + love.math.random(-5,5)
            local y = math.floor(i / 4) * -20 + bounds.y - bounds.height/2 - 50 + love.math.random(-5,5)
            local enemy = newEnemy(x,y,tank,bounds)
            enemy.velocity = newVector(0,enemy.speed)
        end
    elseif pSide == "bottom" then
        for i=0, pQuantity do
            local x = i%4 * -20 + bounds.x + 30    --+ love.math.random(-5,5)
            local y = math.floor(i / 4) * 20 + bounds.y + bounds.height/2 + 50 --+ love.math.random(-5,5)
            local enemy = newEnemy(x,y,tank,bounds)
            enemy.velocity = newVector(0,-enemy.speed)
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
    drawSprites()

    love.graphics.setColor(0,1,0)
    --love.graphics.rectangle("line", bounds.x - bounds.width/2, bounds.y - bounds.height/2, bounds.width, bounds.height)
    --drawColliders()
    love.graphics.setColor(1,1,1)
end

scene.mousePressed = function(pX,pY,pBtn)
    if pBtn == 1 and sceneState == "game" then
        tank.shot()
    end
end

scene.keyPressed = function(pKey)
end

scene.unload = function()
    unloadColliders()
end
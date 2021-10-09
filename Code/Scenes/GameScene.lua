require("Props.Tank")
require("Props.Enemy")

local scene = newScene("game")
local tank

local bounds
local doors

local sceneState = "start"

scene.load = function()
    
    addNewSpritesLayer("floor")
    addNewSpritesLayer("walls")
    addNewSpritesLayer("tank")
    addNewSpritesLayer("enemies")
    addNewSpritesLayer("bullets")
    addNewSpritesLayer("topWalls")

    bounds = { x = 400, y = 225 , width = 740 , height = 390 }
    
    local doors = {
        left = newRectangleCollider(bounds.x - bounds.width/2 - 10, bounds.y, 20, 100, "leftDoor"),
        right = newRectangleCollider(bounds.x + bounds.width/2 + 10, bounds.y, 20, 100, "rightDoor"),
        top = newRectangleCollider(bounds.x, bounds.y - bounds.height / 2 - 10, 100,20, "topDoor"),
        bottom = newRectangleCollider(bounds.x, bounds.y + bounds.height / 2 + 10, 100,20, "bottomDoor"),
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
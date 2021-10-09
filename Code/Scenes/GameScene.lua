require("Props.Tank")

local scene = newScene("game")
local tank

local bounds
local doors

scene.load = function()
    
    addNewSpritesLayer("floor")
    addNewSpritesLayer("walls")
    addNewSpritesLayer("tank")
    addNewSpritesLayer("bullets")
    addNewSpritesLayer("topWalls")

    bounds = { x = 390, y = 215 , width = 740 , height = 390 }
    
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


    tank = newTank(bounds.x,bounds.y, bounds)

end

scene.update = function(dt)
    scene.updateTankControls(dt)
    scene.updateTankAim()
    if love.mouse.isDown(2) then
        tank.secondaryShot()
    end

    updateSprites(dt)
    updateCollisions(dt)
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

    --love.graphics.setColor(0,1,0)
    --love.graphics.rectangle("line", bounds.x - bounds.width/2, bounds.y - bounds.height/2, bounds.width, bounds.height)
    --drawColliders()
    --love.graphics.setColor(1,1,1)
end

scene.mousePressed = function(pX,pY,pBtn)
    if pBtn == 1 then
        tank.shot()
    end
end

scene.keyPressed = function(pKey)
end

scene.unload = function()
    unloadColliders()
end
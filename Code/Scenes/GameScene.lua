require("Tank")

local scene = newScene("game")
local tank

local bounds
local doors

scene.load = function()
    
    addNewSpritesLayer("floor")
    addNewSpritesLayer("tank")

    bounds = { x = 400, y = 225 , width = 750, height = 400 }
    
    local doors = {
        left = newRectangleCollider(bounds.x - bounds.width/2 - 10, bounds.y, 20, 100, "leftDoor"),
        right = newRectangleCollider(bounds.x + bounds.width/2 + 10, bounds.y, 20, 100, "rightDoor"),
        top = newRectangleCollider(bounds.x, bounds.y - bounds.height / 2 - 10, 100,20, "topDoor"),
        bottom = newRectangleCollider(bounds.x, bounds.y + bounds.height / 2 + 10, 100,20, "bottomDoor"),
    }

    tank = newTank(200,200)

end

scene.update = function(dt)
    scene.updateTankControls(dt)
    scene.updateTankAim()
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

    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("line", bounds.x - bounds.width/2, bounds.y - bounds.height/2, bounds.width, bounds.height)
    drawColliders()
    love.graphics.setColor(1,1,1)
end

scene.mousePressed = function(pX,pY,pBtn)
end

scene.keyPressed = function(pKey)
end

scene.unload = function()
    unloadColliders()
end
require("Tank")

local scene = newScene("game")
local tank

scene.load = function()
    addNewSpritesLayer("floor")
    addNewSpritesLayer("tank")

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
    drawColliders()
end

scene.mousePressed = function(pX,pY,pBtn)
end

scene.keyPressed = function(pKey)
end

scene.unload = function()
    unloadColliders()
end
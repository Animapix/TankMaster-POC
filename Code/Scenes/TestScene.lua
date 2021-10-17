
local scene = newScene("test")
local sprite
local sprite2

scene.load = function()
    addNewSpritesLayer("sprite")
    sprite = newSprite(100,225,love.graphics.newImage("Assets/Images/Tank/Chassis.png"),"sprite")
    sprite2 = newSprite(200,225,love.graphics.newImage("Assets/Images/Tank/Chassis.png"),"sprite")
    sprite.blinking = true
end



scene.update = function(dt)
    updateSprites(dt)
end

scene.draw = function()
    drawSprites()
end

scene.unload = function()
end



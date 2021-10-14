
local scene = newScene("test")
local sprite

scene.load = function()
    addNewSpritesLayer("sprite")
    sprite = newSprite(100,225,love.graphics.newImage("Assets/Images/Tank/Chassis.png"),"sprite")
    newTween(sprite,"position.x",100,400,3.0,tweenTypes.sinusoidalOut)

end



scene.update = function(dt)
    updateSprites(dt)
    updateTweening(dt)
end

scene.draw = function()
    drawSprites()
end

scene.unload = function()
end



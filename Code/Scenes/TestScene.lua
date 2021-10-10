
local scene = newScene("test")

scene.load = function()
    addNewSpritesLayer("particles")
    
end

scene.update = function(dt)
    updateSprites(dt)
end

scene.draw = function()
    drawSprites()
end

scene.mousePressed = function(pX,pY,pBtn)
    local x,y = love.graphics.inverseTransformPoint( pX,pY)
    local emitter = newParticlesEmitter(x,y,love.graphics.newImage("Assets/PlaceHolders/Sparkle.png"), 0.01 ,"particles")
    emitter.particlesAmount = 300
    emitter.particleLifeTime = 0.1
    emitter.particleLifetimeRandomF = 0.5
    emitter.particleSpeed = 500
    emitter.particleSpeedRandomF = 0.8
    emitter.partickeSize = 1
    emitter.partickeSizeRandomF = 0.2
    emitter.angle = math.pi / 5 
    emitter.rotation = - (math.pi / 5) / 2 + math.rad(190)
end

scene.unload = function()
end



local gemImage = love.graphics.newImage("Assets/Images/Divers/Gem.png")
local notificationSound = love.audio.newSource("Assets/Sounds/retro-notification.wav", "static") 
local sparkleImage = love.graphics.newImage("Assets/Images/Divers/GemParticles.png")

function newGem(pX,pY)

    local gem = newSprite(pX,pY,gemImage, "gems")
    gem.tag = "gem"
    gem.splitH = 4
    gem.frameRate = 10
    gem.collider = newCircleCollider(0,0,100,"gem")

    gem.isCollected = false
    gem.target = nil
    gem.amount = 150
    gem.lifeTime = 5

    notificationSound:setVolume(0.3 * soundsLevel)
    gem.startBlinking(2,0.1,3)

    gem.update = function(dt)
        
        if gem.target ~= nil then
            gem.position = gem.position + gem.position.dir(gem.target.position) * dt * 350
        end

        gem.lifeTime = gem.lifeTime - dt
        if gem.lifeTime <= 0 then
            gem.remove = true
            gem.collider.remove = true
            gem.removeAnimation()
        end

        gem.updatePosition(dt)
        gem.updateChildrens(dt)
        gem.updateAnimation(dt)
    end

    gem.collider.collide = function(pOther)
        if  pOther.tag ~= "tank" then return end
        if not gem.isCollected then
            gem.isCollected = true
            gem.target = pOther
            gem.collider.radius = 5
        else
            gem.target.parent.addToScore(gem.amount)
            gem.collider.remove = true
            gem.remove = true
            gem.removeAnimation()
            notificationSound:stop()
            notificationSound:play()
        end
    end

    gem.removeAnimation = function()
        
        local emitter = newParticlesEmitter(gem.position.x,gem.position.y,sparkleImage, 0.01 ,"particles")
        emitter.particlesAmount = 1000
        emitter.particleLifeTime = 0.1
        emitter.particleLifetimeRandomF = 0.5
        emitter.particleSpeed = 200
        emitter.particleSpeedRandomF = 0.8
        emitter.partickeSize = 2
        emitter.partickeSizeRandomF = 0.2
    end

    return gem
end

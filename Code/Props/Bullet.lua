local explosiveBulletImage = love.graphics.newImage("Assets/PlaceHolders/Bullet.png")
local rifleBulletImage = love.graphics.newImage("Assets/PlaceHolders/BulletRifle.png")
local sparkleImage = love.graphics.newImage("Assets/PlaceHolders/Sparkle.png")

local shotSound = love.audio.newSource("Assets/Sounds/Explosion_Far.wav", "static") 

function newBullet(pFirePosition, pDirection, pSpeed, pBounds, pImage, pTargetTag)
    local bullet = newSprite(pFirePosition.x,pFirePosition.y,pImage, "bullets")
    
    bullet.targetTag = pTargetTag
    bullet.tag = "bullet"
    bullet.bounds = pBounds
    bullet.speed = pSpeed
    bullet.velocity = pDirection.normalize() * bullet.speed
    bullet.rotation = newVector().angle(bullet.velocity)

    bullet.update = function(dt)
       
        bullet.updatePosition(dt)
        bullet.updateChildrens(dt)

        if bullet.isOutOfBounds(bullet.bounds) then
            bullet.remove = true
            bullet.collider.remove = true
        end
    end

    bullet.isOutOfBounds = function(bounds)
        return bullet.collider.position.x - bullet.collider.radius < pBounds.x - pBounds.width/2 or 
            bullet.collider.position.y - bullet.collider.radius < pBounds.y - pBounds.height/2 or 
            bullet.collider.position.x + bullet.collider.radius > pBounds.width/2 + pBounds.x or 
            bullet.collider.position.y + bullet.collider.radius > pBounds.height/2 + pBounds.y
    end

    return bullet
end

function newExplosiveBullet(pFirePosition, pDirection, pSpeed, pBounds, pTargetTag)
    local bullet = newBullet(pFirePosition, pDirection, pSpeed, pBounds, explosiveBulletImage, pTargetTag)

    bullet.collider = newCircleCollider(0,0,3)

    bullet.update = function(dt)
       
        bullet.updatePosition(dt)
        bullet.updateChildrens(dt)

        if bullet.isOutOfBounds(bullet.bounds) then
            bullet.remove = true
            bullet.collider.remove = true
            local expl = newSprite(bullet.position.x,bullet.position.y,love.graphics.newImage("Assets/Images/Explosions/Explosion_2.png"),"bullets")
            expl.splitH = 8
            expl.frameRate = 30
            expl.loop = false
            expl.removeAtEnd = true
            newExplosion(bullet.position.x,bullet.position.y,nil,0.2,10,50,bullet.targetTag, "bullets")
            --Play sound
            shotSound:stop()
            shotSound:setVolume(0.1 * soundsLevel)
            shotSound:play()
            statsExplosivesBulletMised()
        end
    end

    bullet.collider.collide = function(other)
        if other.tag == bullet.targetTag then
            bullet.remove = true
            bullet.collider.remove = true
            local expl = newSprite(bullet.position.x,bullet.position.y,love.graphics.newImage("Assets/Images/Explosions/Explosion_2.png"),"bullets")
            expl.splitH = 8
            expl.frameRate = 30
            expl.loop = false
            expl.removeAtEnd = true
            newExplosion(bullet.position.x,bullet.position.y,nil,0.2,10,50,bullet.targetTag, "bullets")
            --Play sound
            shotSound:stop()
            shotSound:setVolume(0.1 * soundsLevel)
            shotSound:play()
        end
    end

    return bullet
end

function newRifleBullet(pFirePosition, pDirection, pSpeed, pBounds, pTargetTag)
    local bullet = newBullet(pFirePosition, pDirection, pSpeed, pBounds, rifleBulletImage, pTargetTag)

    bullet.collider = newCircleCollider(0,0,1)
    bullet.damageAmount = 50

    bullet.update = function(dt)
       
        bullet.updatePosition(dt)
        bullet.updateChildrens(dt)

        if bullet.isOutOfBounds(bullet.bounds) then
            bullet.remove = true
            bullet.collider.remove = true
            bullet.spawnSparkles()
            statsRifleBulletMised()
        end
    end

    bullet.collider.collide = function(other)
        if other.tag == bullet.targetTag then
            bullet.remove = true
            bullet.collider.remove = true
            other.parent.takeDamages(bullet.damageAmount)
            bullet.spawnSparkles()
        end
    end

    bullet.spawnSparkles = function()
        local emitter = newParticlesEmitter(bullet.position.x,bullet.position.y,sparkleImage, 0.01 ,"particles")
        emitter.particlesAmount = 1000
        emitter.particleLifeTime = 0.1
        emitter.particleLifetimeRandomF = 0.5
        emitter.particleSpeed = 500
        emitter.particleSpeedRandomF = 0.8
        emitter.partickeSize = 1
        emitter.partickeSizeRandomF = 0.2
        emitter.angle = math.pi / 3 
        emitter.rotation = bullet.rotation - math.pi
    end

    return bullet
end


function newExplosion(pX,pY,pImage,pLife, pDamagesAmount,pRange,pTarget,pLayer)
    local explosion = newSprite(pX,pY,pImage,pLayer)

    explosion.lifeTime = pLife
    explosion.collider = newCircleCollider(pX,pY,pRange,"explosion")
    explosion.targetTag = pTarget
    explosion.damagesAmount = pDamagesAmount
    require("Libraries.Utils.Camera").startShake(0.2,200)

    explosion.update = function(dt)
        explosion.lifeTime = explosion.lifeTime - dt
        if explosion.lifeTime <= 0 then
            explosion.remove = true
            explosion.collider.remove = true
        end
        --print("update explosion")
    end

    explosion.collider.collide = function(other)
        if other.tag == explosion.targetTag  then
            other.parent.takeDamages(explosion.damagesAmount)
        end
    end

    return explosion
end
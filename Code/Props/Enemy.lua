local shotSound = love.audio.newSource("Assets/Sounds/Explosion_Far.wav", "static") 

function newEnemy(pX,pY,pTarget, pBounds)
    local enemy = newSpriteNode(pX, pY,"enemies")
    enemy.collider = newCircleCollider(pX,pY,8,"enemy",enemy)

    enemy.shadow = newSprite(0,0,love.graphics.newImage("Assets/Images/Drone/Shadow.png"))
    enemy.shadow.opacity = 0.2
    enemy.addChild(enemy.shadow)

    enemy.chassis = newSprite(0,0,love.graphics.newImage("Assets/Images/Drone/Drone.png"))
    enemy.propeller1 = newSprite(-8.25,-8.25,love.graphics.newImage("Assets/Images/Drone/PropellerR.png"))
    enemy.propeller2 = newSprite(8.25,-8.25,love.graphics.newImage("Assets/Images/Drone/PropellerL.png"))
    enemy.propeller3 = newSprite(-8.25,8.25,love.graphics.newImage("Assets/Images/Drone/PropellerR.png"))
    enemy.propeller4 = newSprite(8.25,8.25,love.graphics.newImage("Assets/Images/Drone/PropellerL.png"))

    enemy.propeller1.rotation = math.rad(love.math.random(0,360))
    enemy.propeller2.rotation = math.rad(love.math.random(0,360))
    enemy.propeller3.rotation = math.rad(love.math.random(0,360))
    enemy.propeller4.rotation = math.rad(love.math.random(0,360))

    enemy.addChild(enemy.propeller1)
    enemy.addChild(enemy.propeller2)
    enemy.addChild(enemy.propeller3)
    enemy.addChild(enemy.propeller4)

    enemy.addChild(enemy.chassis)

    enemy.tag = "enemy"
    enemy.target = pTarget
    enemy.life = 100
    enemy.speed = love.math.random(60,75)
    enemy.seed = love.math.random(1,5000)
    enemy.bounds = pBounds
    enemy.state = "spawn"

    enemy.update = function(dt)
        if enemy.state == "spawn" then
            local dir = enemy.position.dir(enemy.target.position)
            enemy.rotation = - math.atan2(dir.x,dir.y) + math.rad(90)
            if enemy.isInBounds(enemy.bounds) then
                enemy.state = "attack"
            end
        elseif enemy.state == "attack" then
            if enemy.target ~= nil then
                enemy.seed = enemy.seed + dt / 10
                local noiseX = love.math.noise(enemy.position.x / 100 + enemy.seed) - 0.5
                local noiseY = love.math.noise(enemy.position.y / 100 + enemy.seed) - 0.5
                local noiseVector = newVector(noiseX,noiseY) * 100

                local dir = enemy.position.dir(enemy.target.position)
                enemy.velocity = dir * enemy.speed
                enemy.velocity = enemy.velocity + noiseVector
                enemy.rotation = - math.atan2(dir.x,dir.y) + math.rad(90)
            end
            enemy.isOutOfBounds(enemy.bounds)
        end
        
        enemy.propeller1.rotation = enemy.propeller1.rotation + dt * 50
        enemy.propeller2.rotation = enemy.propeller2.rotation - dt * 50
        enemy.propeller3.rotation = enemy.propeller3.rotation + dt * 50
        enemy.propeller4.rotation = enemy.propeller4.rotation - dt * 50

        enemy.updatePosition(dt)
        enemy.updateChildrens(dt)
    end

    enemy.takeDamages = function(amount)
        enemy.life = enemy.life - amount
        if enemy.life <= 0 then
            enemy.remove = true
            enemy.shadow.remove = true
            enemy.collider.remove = true
            local expl = newSprite(enemy.position.x,enemy.position.y,love.graphics.newImage("Assets/Images/Explosions/Explosion_1.png"),"bullets")
            expl.splitH = 8
            expl.frameRate = 30
            expl.loop = false
            expl.removeAtEnd = true

            local sparkleImage = love.graphics.newImage("Assets/Images/Divers/DroneParticles.png")
            local emitter = newParticlesEmitter(enemy.position.x,enemy.position.y,sparkleImage, 0.01 ,"enemies")
            emitter.particlesAmount = 2000
            emitter.particleLifeTime = 0.3
            emitter.particleLifetimeRandomF = 0.5
            emitter.particleSpeed = 100
            emitter.particleSpeedRandomF = 0.8
            emitter.partickeSize = 1
            emitter.partickeSizeRandomF = 0.5

            --Play sound
            shotSound:stop()
            shotSound:setVolume(0.2 * soundsLevel)
            shotSound:play()
            require("Libraries.Utils.Camera").startShake(0.1,20)
            newGem(enemy.position.x,enemy.position.y)
            statsEnemyKilled()
        end
        --print("enemy take "..amount.." damages, enemy's life = "..enemy.life)
    end

    enemy.collider.collide = function(other)
        if other.tag == "tank" then
            enemy.collider.resolveCollision(other)
            other.parent.takeDamages(10)
        end
    end

    enemy.isOutOfBounds = function(bounds)
        if enemy.collider.position.x - enemy.collider.radius < bounds.x - bounds.width/2 then
            enemy.collider.position.x = bounds.x - bounds.width/2 + enemy.collider.radius
        elseif enemy.collider.position.x + enemy.collider.radius > bounds.width/2 + bounds.x then
            enemy.collider.position.x = bounds.width/2 + bounds.x - enemy.collider.radius
        end

        if enemy.collider.position.y - enemy.collider.radius < bounds.y - bounds.height/2 then
            enemy.collider.position.y = bounds.y - bounds.height/2 + enemy.collider.radius
        elseif enemy.collider.position.y + enemy.collider.radius > bounds.height/2 + bounds.y then
            enemy.collider.position.y = bounds.height/2 + bounds.y - enemy.collider.radius
        end

        enemy.position = enemy.collider.position
    end

    enemy.isInBounds = function(bounds)
        return enemy.position.x - enemy.collider.radius > bounds.x - bounds.width/2 and
            enemy.position.y - enemy.collider.radius > bounds.y - bounds.height/2 and
            enemy.position.x + enemy.collider.radius < bounds.x + bounds.width/2 and
            enemy.position.y + enemy.collider.radius < bounds.y + bounds.height/2
    end

    return enemy
end
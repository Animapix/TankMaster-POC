require("Props.Bullet")

local shotSound = love.audio.newSource("Assets/Sounds/Explosion_Fast.wav", "static") 
local smallShotSound = love.audio.newSource("Assets/Sounds/Small_Gun_Shot.wav", "static") 

function newTank(pX,pY,pBounds)
    local tank = newSpriteNode(pX, pY, "tank")

    tank.tag = "tank"
    tank.bounds = pBounds
    tank.collider = newCircleCollider(0,0,20,"tank", tank)
    tank.canOutOfBounds = false
    tank.collideRightDoor = nil
    tank.collider.collide = function(pOther)
        if pOther.tag == "door" and tank.collideRightDoor ~= nil and tank.position.x > tank.bounds.x  + 100 then 
            tank.collideRightDoor()
        end
    end

    tank.shadow = newSprite(0,0,love.graphics.newImage("Assets/Images/Tank/Shadow.png"), "shadows")

    tank.tracksSound = love.audio.newSource("Assets/Sounds/tracks.wav", "stream")
    tank.tracksSound:setLooping( true )
    tank.tracksSound:play()
    tank.tracksSound:setVolume(0)

    tank.trackR = newSprite(0,12,love.graphics.newImage("Assets/Images/Tank/Tracks.png"))
    tank.trackR.splitV = 5
    tank.addChild(tank.trackR)
    tank.trackL = newSprite(0,-12,love.graphics.newImage("Assets/Images/Tank/Tracks.png"))
    tank.trackL.splitV = 5
    tank.addChild(tank.trackL)

    tank.chassis = newSprite(0,0,love.graphics.newImage("Assets/Images/Tank/Chassis.png"))
    tank.addChild(tank.chassis)

    tank.turret = newSprite(0,0,love.graphics.newImage("Assets/Images/Tank/turret.png"))
    tank.addChild(tank.turret)

    tank.trailL = newTrail(0,12,"trails")
    tank.addChild(tank.trailL)
    tank.trailR = newTrail(0,-12,"trails")
    tank.addChild(tank.trailR)
    

    tank.turret.barrel = newSpriteNode(32,0)
    tank.turret.barrel.visible  = false
    tank.turret.addChild(tank.turret.barrel)
    tank.turret.barrelRight = newSpriteNode(4,11)
    tank.turret.barrelRight.visible  = false
    tank.turret.addChild(tank.turret.barrelRight)
    tank.turret.barrelLeft = newSpriteNode(4,-11)
    tank.turret.barrelLeft.visible  = false
    tank.turret.addChild(tank.turret.barrelLeft)

    tank.rifleRate = 0.1
    tank.rifleTimer = 0
    tank.bulletRate = 1.0
    tank.bulletTimer = 0

    tank.throttleCmd = 0
    tank.steeringCmd = 0

    tank.life = 500
    tank.speed = 250

    tank.invincibleTimer = 0
    tank.invincibleDuration = 0.1

    tank.score = 0

    tank.update = function(dt)

        -- shots timer update
        tank.rifleTimer = tank.rifleTimer - dt
        if tank.rifleTimer <= 0 then
            tank.rifleTimer = 0
        end
        tank.bulletTimer = tank.bulletTimer - dt
        if tank.bulletTimer <= 0 then
            tank.bulletTimer = 0
        end

        -- throtle friction compute
        if tank.throttleCmd > 0.01 then tank.throttleCmd = tank.throttleCmd - dt * 2
        elseif tank.throttleCmd < -0.01 then tank.throttleCmd = tank.throttleCmd + dt * 2
        else tank.throttleCmd = 0 end

        -- steering friction compute
        if tank.steeringCmd > 0.01 then tank.steeringCmd = tank.steeringCmd - dt * 2
        elseif tank.steeringCmd < -0.01 then tank.steeringCmd = tank.steeringCmd + dt * 2
        else tank.steeringCmd = 0 end
        
        --tank velocity compute
        tank.rotationVelocity = tank.steeringCmd * math.rad(180)
        local dir = newVector(math.cos(tank.rotation),math.sin(tank.rotation))
        tank.velocity = dir * tank.throttleCmd * tank.speed

        -- update tank timers
        tank.invincibleTimer = tank.invincibleTimer - dt
        if tank.invincibleTimer <= 0 then 
            tank.invincibleTimer = 0
        end 

        --Adjust tracks animation speed
        tank.trackL.frameRate = (tank.throttleCmd + tank.steeringCmd * 1.5) * 35
        tank.trackR.frameRate = (tank.throttleCmd - tank.steeringCmd * 1.5) * 35

        --Adjust tracks sound
        tank.tracksSound:setVolume(math.max(math.abs(tank.throttleCmd), math.abs(tank.steeringCmd)) * 0.5 * soundsLevel)

        tank.updatePosition(dt)
        tank.updateChildrens(dt)
        tank.isOutOfBounds(tank.bounds)

        tank.shadow.position = tank.position
    end

    tank.reset = function(pX,pY)
        tank.position = newVector(pX,pY)
        tank.throttleCmd = 0
        tank.steeringCmd = 0
        tank.velocity = newVector()
        tank.rotation = 0
        tank.collideRightDoor = nil
    end

    tank.addToScore = function(amount)
        tank.score = tank.score + amount
    end

    tank.moveForward = function(dt)
        tank.throttleCmd = tank.throttleCmd + dt * 3
        if tank.throttleCmd > 1 then tank.throttleCmd = 1 end
    end

    tank.moveBackward = function(dt)
        tank.throttleCmd = tank.throttleCmd - dt * 3
        if tank.throttleCmd < -1 then tank.throttleCmd = -1 end
    end

    tank.turnRight = function(dt)
        tank.steeringCmd = tank.steeringCmd + dt * 6
        if tank.steeringCmd > 1 then tank.steeringCmd = 1 end
    end

    tank.turnLeft = function(dt)
        tank.steeringCmd = tank.steeringCmd - dt * 6
        if tank.steeringCmd < -1 then tank.steeringCmd = -1 end
    end

    tank.aim = function(target)
        local angle = tank.position.angle(target)
        tank.turret.rotation = angle - tank.rotation
    end

    tank.takeDamages = function(amount)

        if tank.invincibleTimer > 0 then
            return
        end
        tank.invincibleTimer = tank.invincibleDuration
        tank.startBlinking(tank.invincibleDuration, 0.1)
        tank.life = tank.life - amount
        if tank.life <= 0 then
            tank.tracksSound:stop()
        end
        --print("tank take "..amount.." damages, tank's life = "..tank.life)
    end

    tank.shot = function()
        if tank.bulletTimer == 0 then
            --Play sound
            shotSound:stop()
            shotSound:setVolume(0.1 * soundsLevel)
            shotSound:play()
            local direction = newVector(math.cos(tank.turret.getRelativeRotation()),math.sin(tank.turret.getRelativeRotation()))
            local bullet = newExplosiveBullet(tank.turret.barrel.getRelativePosition(), direction, 800, tank.bounds, "enemy")
            --bullet.velocity = bullet.velocity + tank.velocity
            tank.bulletTimer = tank.bulletRate
            require("Libraries.Utils.Camera").startShake(0.1,100)
            statsExplosivesBulletFired()
        end
    end

    tank.secondaryShot = function()
        if tank.rifleTimer == 0 then
            --Play sound
            smallShotSound:stop()
            smallShotSound:setVolume(0.13 * soundsLevel)
            smallShotSound:play()

            local direction = newVector(math.cos(tank.turret.getRelativeRotation()),math.sin(tank.turret.getRelativeRotation()))
            local bulletLeft = newRifleBullet(tank.turret.barrelLeft.getRelativePosition(), direction, 1000, tank.bounds, "enemy")
            local bulletRight = newRifleBullet(tank.turret.barrelRight.getRelativePosition(), direction, 1000, tank.bounds, "enemy")
            tank.rifleTimer = tank.rifleRate

            --bulletLeft.velocity = bulletLeft.velocity + tank.velocity
            --bulletRight.velocity = bulletRight.velocity + tank.velocity

            require("Libraries.Utils.Camera").startShake(0.1,10)
            statsRifleBulletFired()
            statsRifleBulletFired()
        end
    end

    tank.isOutOfBounds = function(bounds)
        if tank.canOutOfBounds then return end
        if tank.collider.position.x - tank.collider.radius < bounds.x - bounds.width/2 then
            tank.collider.position.x = bounds.x - bounds.width/2 + tank.collider.radius
        elseif tank.collider.position.x + tank.collider.radius > bounds.width/2 + bounds.x then
            tank.collider.position.x = bounds.width/2 + bounds.x - tank.collider.radius
        end

        if tank.collider.position.y - tank.collider.radius < bounds.y - bounds.height/2 then
            tank.collider.position.y = bounds.y - bounds.height/2 + tank.collider.radius
        elseif tank.collider.position.y + tank.collider.radius > bounds.height/2 + bounds.y then
            tank.collider.position.y = bounds.height/2 + bounds.y - tank.collider.radius
        end
        tank.position = tank.collider.position
    end

    return tank
end
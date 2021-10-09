require("Props.Bullet")

function newTank(pX,pY,pBounds)
    local tank = newSpriteNode(pX, pY, "tank")

    tank.bounds = pBounds
    tank.collider = newCircleCollider(0,0,20, tank)
    tank.canOutOfBounds = false
    tank.collideRightDoor = nil
    tank.collider.collide = function(pOther)
        if pOther.tag == "rightDoor" and tank.collideRightDoor ~= nil then 
            tank.collideRightDoor()
        end
    end

    tank.chassis = newSprite(0,0,love.graphics.newImage("Assets/PlaceHolders/Tank.png"))
    tank.addChild(tank.chassis)

    tank.turret = newSprite(0,0,love.graphics.newImage("Assets/PlaceHolders/turret.png"))
    tank.addChild(tank.turret)

    tank.turret.barrel = newSpriteNode(32,0)
    tank.turret.addChild(tank.turret.barrel)
    tank.turret.barrelRight = newSpriteNode(45,10)
    tank.turret.addChild(tank.turret.barrelRight)
    tank.turret.barrelLeft = newSpriteNode(45,-10)
    tank.turret.addChild(tank.turret.barrelLeft)

    tank.rifleRate = 0.15
    tank.rifleTimer = 0
    tank.bulletRate = 1.0
    tank.bulletTimer = 0

    tank.throttleCmd = 0
    tank.steeringCmd = 0

    tank.life = 500
    tank.speed = 250

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

        tank.updatePosition(dt)
        tank.updateChildrens(dt)
        tank.isOutOfBounds(tank.bounds)
    end

    tank.reset = function(pX,pY)
        tank.position = newVector(pX,pY)
        tank.throttleCmd = 0
        tank.steeringCmd = 0
        tank.velocity = newVector()
        tank.rotation = 0
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

    tank.shot = function()
        if tank.bulletTimer == 0 then
            local direction = newVector(math.cos(tank.turret.getRelativeRotation()),math.sin(tank.turret.getRelativeRotation()))
            local bullet = newExplosiveBullet(tank.turret.barrel.getRelativePosition(), direction, 800, tank.bounds, "enemy")
            tank.bulletTimer = tank.bulletRate
        end
    end

    tank.secondaryShot = function()
        if tank.rifleTimer == 0 then
            local direction = newVector(math.cos(tank.turret.getRelativeRotation()),math.sin(tank.turret.getRelativeRotation()))
            local bulletLeft = newRifleBullet(tank.turret.barrelLeft.getRelativePosition(), direction, 1500, tank.bounds, "enemy")
            local bulletRight = newRifleBullet(tank.turret.barrelRight.getRelativePosition(), direction, 1500, tank.bounds, "enemy")
            tank.rifleTimer = tank.rifleRate
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
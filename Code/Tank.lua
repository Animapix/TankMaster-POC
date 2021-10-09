function newTank(pX,pY,pBounds)
    local tank = newSpriteNode(pX, pY, "tank")

    tank.bounds = pBounds
    tank.collider = newCircleCollider(0,0,20)
    tank.collider.collide = function(pOther)
        print(pOther.tag)
    end


    tank.chassis = newSprite(0,0,love.graphics.newImage("Assets/PlaceHolders/Tank.png"))
    tank.addChild(tank.chassis)

    tank.turret = newSprite(0,0,love.graphics.newImage("Assets/PlaceHolders/turret.png"))
    tank.addChild(tank.turret)

    tank.throttleCmd = 0
    tank.steeringCmd = 0

    tank.life = 500
    tank.speed = 250

    tank.update = function(dt)
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

    tank.isOutOfBounds = function(bounds)

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
function newTank(pX,pY)
    local tank = newSpriteNode(pX, pY, "tank")

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

    return tank
end
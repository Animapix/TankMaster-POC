function newDoors(pX,pY, pAngle)
    local doors = newSpriteNode(pX,pY,"doors")
    doors.left = newSprite(0,0,love.graphics.newImage("Assets/Images/Arena/Door left.png"))
    doors.right = newSprite(0,0,love.graphics.newImage("Assets/Images/Arena/Door right.png"))
    doors.addChild(doors.left)
    doors.addChild(doors.right)
    doors.rotation = math.rad(pAngle)

    doors.move = 0
    doors.speed = 120
    doors.isOpen = false

    doors.closeTimer = 0
    doors.isDelayed = false

    doors.update = function(dt)
        
        if doors.move ~= 0 then
            doors.left.position.x = doors.left.position.x - dt * doors.move * doors.speed
            doors.right.position.x = doors.right.position.x + dt * doors.move * doors.speed
        end
        

        if doors.move > 0 and doors.left.position.x <= -60 then
            doors.move = 0
            doors.left.position.x = -60
            doors.right.position.x = 60
        elseif doors.move < 0 and doors.left.position.x >= 0 then
            doors.move = 0
            doors.left.position.x = 0
            doors.right.position.x = 0
        end

        

        doors.closeTimer = doors.closeTimer - dt
        if doors.closeTimer <= 0 and doors.isOpen and doors.isDelayed then
            doors.isDelayed = false
            doors.close()
        end

        doors.updatePosition(dt)
        doors.updateChildrens(dt)
    end

    doors.draw = function()
        local size = 136
        local pos = newVector(love.graphics.transformPoint(doors.position.x - size/2,doors.position.y - size/2))
        

        love.graphics.setScissor(pos.x,pos.y,love.graphics.transformPoint(size,size))
        doors.drawChildrens()
        love.graphics.setScissor()

        --love.graphics.rectangle("line", pos.x/2,pos.y/2,size,size)
    end

    doors.open = function()
        doors.move = 1
        doors.isOpen = true
    end

    doors.close = function()
        doors.move = -1
        doors.isOpen = false
    end

    doors.closeWithDelay = function(delay)
        doors.closeTimer = delay
        doors.isDelayed = true
    end

    return doors
end
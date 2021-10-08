local colliders = {}

updateCollisions = function(dt)
    for __,collider in ipairs(colliders) do
        for __,other in ipairs(colliders) do
            if collider ~= other and collider.collide ~= nil then
                if collider.isCollideWith(other) then
                    collider.collide(other)
                end
            end
        end
    end
end

drawColliders = function()
    for __,collider in pairs(colliders) do
        collider.draw()
    end
end

unloadColliders = function()
    colliders = {}
end

newCollider = function(pX, pY, pTag)
    local collider = {}

    collider.tag = pTag
    collider.position = newVector(pX,pY)

    collider.collide = nil

    collider.draw = function()
        love.graphics.points(collider.position.x,collider.position.y)
    end

    table.insert(colliders,collider)
    return collider
end


newCircleCollider = function(pX, pY, pRadius, pTag)
    local collider = newCollider(pX, pY, pTag)

    collider.type = "circle"
    collider.radius = pRadius

    collider.draw = function()
        love.graphics.circle("line", collider.position.x, collider.position.y, collider.radius)
    end

    collider.isCollideWith = function(pOther)
        if pOther.type == "circle" then
            return collider.isCollideWithCircle(pOther)
        elseif pOther.type == "rectangle" then
            return pOther.isCollideWithCircle(collider)
        end
    end

    collider.isCollideWithCircle = function(pOther)
        return collider.position.distance(pOther.position) < collider.radius + pOther.radius
    end

    return collider
end

newRectangleCollider = function(pX, pY, pWidth, pHeight, pTag)
    local collider = newCollider(pX, pY, pTag)

    collider.type = "rectangle"
    collider.width = pWidth
    collider.height = pHeight

    collider.draw = function()
        love.graphics.rectangle("line", collider.position.x - collider.width / 2, collider.position.y - collider.height / 2, collider.width, collider.height)
    end

    collider.isCollideWith = function(pOther)
        
        if pOther.type == "circle" then
            return collider.isCollideWithCircle(pOther)
        elseif pOther.type == "rectangle" then
            return collider.isCollideWithRectangle(pOther)
        end
    end

    collider.isCollideWithCircle = function(pOther)
        local testX = pOther.position.x
        local testY = pOther.position.y

        if (pOther.position.x < collider.position.x - collider.width / 2) then 
            testX = collider.position.x - collider.width / 2
        elseif (pOther.position.x > collider.position.x + collider.width / 2) then 
            testX = collider.position.x + collider.width / 2
        end

        if (pOther.position.y < collider.position.y - collider.height / 2) then 
            testY = collider.position.y - collider.height / 2
        elseif (pOther.position.y > collider.position.y + collider.height / 2) then 
            testY = collider.position.y + collider.height / 2
        end

        local distX = pOther.position.x - testX
        local distY = pOther.position.y - testY

        local distance = math.sqrt( (distX * distX) + (distY * distY) )

        if distance <= pOther.radius then
            return true
        end

        return false -- collider.position.distance(pOther.position) < collider.radius + pOther.radius
    end

    collider.isCollideWithRectangle = function(pOther)
        return collider.position.x + collider.width / 2 >= pOther.position.x - pOther.width / 2 and
            collider.position.x - collider.width / 2 <= pOther.position.x + pOther.width / 2 and
            collider.position.y + collider.height / 2 >= pOther.position.y - pOther.height / 2 and
            collider.position.y - collider.height / 2  <= pOther.position.y + pOther.height / 2
    end

    return collider
end
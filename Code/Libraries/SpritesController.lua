local layers = {}

addNewSpritesLayer = function(pName)
    table.insert(layers, {
        name = pName,
        sprites = {}
    })
end

updateSprites = function(dt)
    for __,layer in ipairs(layers) do
        for __,sprite in ipairs(layer.sprites) do
            sprite.update(dt)
        end
    end
end

drawSprites = function()
    for __,layer in ipairs(layers) do
        for __,sprite in ipairs(layer.sprites) do
            sprite.draw()
        end
    end
end

unloadSprites = function()
    layers = {}
end

getSpritesLayer = function(pName)
    for __,layer in ipairs(layers) do
        if layer.name == pName then 
            return layer 
        end
    end
    return nil
end

newSpriteNode = function(pX, pY, pLayer)
    local node = {}

    node.position = newVector(pX,pY)
    node.velocity = newVector()
    node.rotation = 0
    node.rotationVelocity = 0
    node.childrens = {}
    node.parent = nil
    node.remove = false

    node.addChild = function(pChild)
        pChild.parent = node
        table.insert(node.childrens,pChild)
    end

    node.updatePosition = function(dt)
        node.position = node.position + node.velocity * dt
        node.rotation = node.rotation + node.rotationVelocity * dt
    end

    node.update = function(dt)
        node.updatePosition(dt)
        node.updateChildrens(dt)
    end

    node.updateChildrens = function(dt)
        for __,child in ipairs(node.childrens) do
            child.update(dt)
        end
    end

    node.draw = function()
        love.graphics.circle("fill", node.getRelativeX(), node.getRelativeY(), 1)
        node.drawChildrens()
    end

    node.drawChildrens = function()
        for __,child in ipairs(node.childrens) do
            child.draw()
        end
    end

    node.getRelativePosition = function()
        return newVector(node.getRelativeX(),node.getRelativeY())
    end

    node.getRelativeX = function()
        if node.parent ~= nil then
            return node.parent.getRelativeX() + node.position.norm() * math.cos(node.parent.getRelativeRotation() + math.atan2(node.position.y,node.position.x))
        else
            return node.position.x
        end
    end

    node.getRelativeY = function()
        if node.parent ~= nil then
            return node.parent.getRelativeY() + node.position.norm() * math.sin(node.parent.getRelativeRotation() +  math.atan2(node.position.y,node.position.x))
        else
            return node.position.y
        end
    end

    node.getRelativeRotation = function()
        return node.parent ~= nil and node.rotation + node.parent.getRelativeRotation() or node.rotation
    end

    local layer = getSpritesLayer(pLayer)
    if layer ~= nil then
        table.insert(layer.sprites, node)
    end

    return node
end

newSprite = function(pX, pY, pImage, pLayer)
    local sprite = newSpriteNode(pX, pY, pLayer)

    sprite.image = pImage

    sprite.draw = function()
        if sprite.image == nil then return end
        love.graphics.push()
        love.graphics.translate(sprite.getRelativeX(),sprite.getRelativeY())
        love.graphics.rotate(sprite.getRelativeRotation())
        love.graphics.draw(sprite.image,0,0,0,1,1,sprite.image:getWidth() / 2,sprite.image:getHeight() / 2)
        love.graphics.pop()
        sprite.drawChildrens()
    end

    return sprite
end
local layers = {}
local spritesCounter = 0

addNewSpritesLayer = function(pName, pModulate, pBlend)
    table.insert(layers, {
        name = pName,
        modulate = pModulate or {1,1,1,1},
        blend = pBlend or { "alpha", nil } ,
        sprites = {}
    })
end

updateSprites = function(dt)
    spritesCounter = 0
    for __,layer in ipairs(layers) do
        for __,sprite in ipairs(layer.sprites) do
            spritesCounter = spritesCounter + 1
            sprite.update(dt)
        end

        for i = #layer.sprites, 1, -1 do
            if layer.sprites[i].remove then
                table.remove(layer.sprites,i)
                spritesCounter = spritesCounter - 1
            end
        end
    end
end

drawSprites = function()
    for __,layer in ipairs(layers) do
        love.graphics.setColor(layer.modulate)
        love.graphics.setBlendMode(layer.blend[1], layer.blend[2])
        for __,sprite in ipairs(layer.sprites) do
            sprite.draw()
        end
        love.graphics.setColor(1,1,1)
        love.graphics.setBlendMode("alpha")
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

getSprites = function(pTag)
    local sprt = {}
    for __,layer in ipairs(layers) do
        for __,sprite in ipairs(layer.sprites) do
            if pTag ~= nil and sprite.tag ~= nil then
                if sprite.tag == pTag then
                    table.insert(sprt,sprite)
                end
            elseif pTag == nil then
                table.insert(sprt,sprite)
            end
        end 
    end
    return sprt
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
    node.collider = nil

    node.addChild = function(pChild)
        pChild.parent = node
        table.insert(node.childrens,pChild)
    end

    node.updatePosition = function(dt)
        node.position = node.position + node.velocity * dt
        node.rotation = node.rotation + node.rotationVelocity * dt
        if node.collider ~= nil then
            node.collider.position = node.position
        end
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
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
    node.opacity = 1
    node.visible = true

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
        if node.parent ~= nil then
            love.graphics.setColor(1,1,1,node.parent.opacity)
        else
            love.graphics.setColor(1,1,1,node.opacity)
        end
        if not node.visible then return end
        love.graphics.circle("fill", node.getRelativeX(), node.getRelativeY(), 1)
        love.graphics.setColor(1,1,1,1)
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

    sprite.frame = 1
    sprite.frameRate = 0
    sprite.splitH = 1
    sprite.splitV = 1
    sprite.loop = true

    sprite.draw = function()
        if sprite.parent ~= nil then
            love.graphics.setColor(1,1,1,sprite.parent.opacity)
        else
            love.graphics.setColor(1,1,1,sprite.opacity)
        end
        if not sprite.visible then return end
        if sprite.image == nil then return end

        local quad = sprite.getQuad(math.floor(sprite.frame))

        love.graphics.push()
        love.graphics.translate(sprite.getRelativeX(),sprite.getRelativeY())
        love.graphics.rotate(sprite.getRelativeRotation())
        love.graphics.draw(sprite.image,quad, 0, 0,0,sprite.scale,sprite.scale, sprite.image:getWidth()/2 / sprite.splitH, sprite.image:getHeight() /2/ sprite.splitV)
        love.graphics.pop()
        love.graphics.setColor(1,1,1,1)
        sprite.drawChildrens()
    end

    sprite.update = function(dt)
        sprite.updatePosition(dt)
        sprite.updateAnimation(dt)
        sprite.updateChildrens(dt)
    end

    sprite.updateAnimation = function(dt)
        sprite.frame = sprite.frame + dt * sprite.frameRate
        if sprite.frame >= sprite.splitH * sprite.splitV then 
            sprite.frame = 1 end
        if sprite.frame < 1 then 
            sprite.frame = sprite.splitH * sprite.splitV - 1 
        end
    end

    sprite.getQuad = function(frame)
        local row = math.ceil(frame/sprite.splitH)
        local column = frame - row * sprite.splitH + sprite.splitH
        local width = sprite.image:getWidth() / sprite.splitH
        local height = sprite.image:getHeight() / sprite.splitV
    
        local x = (column - 1) * width
        local y = (row - 1) * height
    
        return love.graphics.newQuad(x,y,width,height,sprite.image:getWidth(),sprite.image:getHeight())
    end

    return sprite
end

newParticlesEmitter = function(pX,pY,pImage,lifeTime, pLayer)
    local emitter = newSpriteNode(pX,pY,pLayer)

    emitter.layer = pLayer
    emitter.angle = math.pi * 2
    emitter.lifeTime = lifeTime or -1
    emitter.particleImage = pImage
    emitter.particlesAmount = 500

    emitter.particleLifeTime = 0.5
    emitter.particleLifetimeRandomF = 0
    emitter.particleSpeed = 100
    emitter.particleSpeedRandomF = 0
    emitter.partickeSize = 1
    emitter.partickeSizeRandomF = 0
    emitter.particleGravity = 0
    emitter.particleGravityRandomF = 0

    emitter.update = function(dt)
        
        for i= 1, emitter.particlesAmount * dt do
            local particle = newParticle(emitter.position.x,emitter.position.y,emitter.particleImage,emitter.layer)
            local angle = love.math.random() * emitter.angle + emitter.rotation - emitter.angle / 2
            particle.velocity = newVector(math.cos(angle),math.sin(angle)) * randomFact(emitter.particleSpeed,emitter.particleSpeedRandomF)
            particle.life = randomFact(emitter.particleLifeTime, emitter.particleLifetimeRandomF)
            particle.size = randomFact(emitter.partickeSize, emitter.partickeSizeRandomF)
            particle.gravity = randomFact(emitter.particleGravity, emitter.particleGravityRandomF)
        end

        if emitter.lifeTime ~= -1 then
            emitter.lifeTime = emitter.lifeTime - dt
            if emitter.lifeTime <= 0 then
                emitter.remove = true
            end
        end

        emitter.updatePosition(dt)
        emitter.updateChildrens(dt)
    end

    return emitter    
end

newParticle = function(pX,pY, pImage ,pLayer)
    local particle = newSpriteNode(pX,pY,pLayer)

    particle.life = 1
    particle.gravity = 0
    particle.size = 1
    particle.image = pImage

    particle.update = function(dt)

        particle.life = particle.life - dt
        
        if particle.life <= 0 then
            particle.remove = true
        end

        if particle.life < 0.8 / 2 then
            particle.opacity = particle.opacity - dt
        end
        
        particle.velocity.y = particle.velocity.y + dt * particle.gravity
        particle.rotation = math.atan2( particle.velocity.y,  particle.velocity.x);

        particle.updatePosition(dt)
        particle.updateChildrens(dt)
    end

    particle.draw = function()
        if particle.parent ~= nil then
            love.graphics.setColor(1,1,1,particle.parent.opacity)
        else
            love.graphics.setColor(1,1,1,particle.opacity)
        end
        if not particle.visible then return end
            local width = particle.image:getWidth()
            local height = particle.image:getHeight()
            love.graphics.draw(particle.image,particle.getRelativeX(), particle.getRelativeY(),particle.getRelativeRotation(),particle.size,particle.size,width/2, height/2 )
        if particle.image ~= nil then
        else
            love.graphics.circle("fill", particle.getRelativeX(), particle.getRelativeY(), particle.size)
        end
        
        love.graphics.setColor(1,1,1,1)
        particle.drawChildrens()
    end

    return particle
end
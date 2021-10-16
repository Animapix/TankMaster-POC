local gemImage = love.graphics.newImage("Assets/Images/Divers/Gem.png")
local notificationSound = love.audio.newSource("Assets/Sounds/retro-notification.wav", "static") 

function newGem(pX,pY)
    
    local gem = newSprite(pX,pY,gemImage, "gems")
    gem.splitH = 4
    gem.frameRate = 10
    gem.collider = newCircleCollider(0,0,100,"gem")

    gem.isCollected = false
    gem.target = nil
    gem.amount = 150
    gem.lifeTime = 5

    notificationSound:setVolume(0.3 * soundsLevel)

    gem.update = function(dt)
        
        if gem.target ~= nil then
            gem.position = gem.position + gem.position.dir(gem.target.position) * dt * 350
        end

        gem.lifeTime = gem.lifeTime - dt
        if gem.lifeTime <= 0 then
            gem.remove = true
            gem.collider.remove = true
        end

        gem.updatePosition(dt)
        gem.updateChildrens(dt)
        gem.updateAnimation(dt)
    end

    gem.collider.collide = function(pOther)
        if  pOther.tag ~= "tank" then return end
        if not gem.isCollected then
            gem.isCollected = true
            gem.target = pOther
            gem.collider.radius = 5
        else
            gem.target.parent.addToScore(gem.amount)
            gem.collider.remove = true
            gem.remove = true
            notificationSound:stop()
            notificationSound:play()
        end
    end

    return gem
end

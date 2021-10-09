local explosiveBulletImage = love.graphics.newImage("Assets/PlaceHolders/Bullet.png")
local rifleBulletImage = love.graphics.newImage("Assets/PlaceHolders/BulletRifle.png")

function newBullet(pFirePosition, pDirection, pSpeed, pBounds, pImage)
    local bullet = newSprite(pFirePosition.x,pFirePosition.y,pImage, "bullets")
    
    bullet.tag = "bullet"
    bullet.bounds = pBounds
    bullet.speed = pSpeed
    bullet.velocity = pDirection.normalize() * bullet.speed
    bullet.rotation = newVector().angle(bullet.velocity)

    bullet.update = function(dt)
       
        bullet.updatePosition(dt)
        bullet.updateChildrens(dt)

        if bullet.isOutOfBounds(bullet.bounds) then
            bullet.remove = true
            bullet.collider.remove = true
        end
    end

    bullet.isOutOfBounds = function(bounds)
        return bullet.collider.position.x - bullet.collider.radius < pBounds.x - pBounds.width/2 or 
            bullet.collider.position.y - bullet.collider.radius < pBounds.y - pBounds.height/2 or 
            bullet.collider.position.x + bullet.collider.radius > pBounds.width/2 + pBounds.x or 
            bullet.collider.position.y + bullet.collider.radius > pBounds.height/2 + pBounds.y
    end

    return bullet
end

function newExplosiveBullet(pFirePosition, pDirection, pSpeed, pBounds)
    local bullet = newBullet(pFirePosition, pDirection, pSpeed, pBounds, explosiveBulletImage)

    bullet.collider = newCircleCollider(0,0,3)

    bullet.update = function(dt)
       
        bullet.updatePosition(dt)
        bullet.updateChildrens(dt)

        if bullet.isOutOfBounds(bullet.bounds) then
            bullet.remove = true
            bullet.collider.remove = true
            print("Explosion")
        end
    end

    return bullet
end

function newRifleBullet(pFirePosition, pDirection, pSpeed, pBounds)
    local bullet = newBullet(pFirePosition, pDirection, pSpeed, pBounds, rifleBulletImage)

    bullet.collider = newCircleCollider(0,0,1)

    bullet.update = function(dt)
       
        bullet.updatePosition(dt)
        bullet.updateChildrens(dt)

        if bullet.isOutOfBounds(bullet.bounds) then
            bullet.remove = true
            bullet.collider.remove = true
        end
    end

    return bullet
end
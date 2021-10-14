local camera = newVector()

    camera.width = love.graphics.getWidth()
    camera.height = love.graphics.getHeight()

    camera.shakeDuration = -1
    camera.shakeMagnitude = 0

    camera.update = function(dt, target)
        if target == nil then return end
        local shake = newVector()
        if camera.shakeDuration > 0 then
            camera.shakeDuration = camera.shakeDuration - dt
            shake.x = love.math.random(-camera.shakeMagnitude,camera.shakeMagnitude)
            shake.y = love.math.random(-camera.shakeMagnitude,camera.shakeMagnitude)
        end
        local position = target - newVector(camera.width/2,camera.height/2) - shake
        camera.lerp(position ,0.01)
    end

    camera.setPosition = function(pX,pY)
        camera.x = pX - camera.width / 2 
        camera.y = pY - camera.height / 2 
    end

    camera.startShake = function(duration,magnitude)
        
        camera.shakeDuration = duration or 1
        camera.shakeMagnitude = magnitude or 300
    end

return camera
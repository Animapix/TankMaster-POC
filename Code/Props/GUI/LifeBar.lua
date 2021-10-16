function newLifeBar(pX,pY,pWidth,pHeight, pMax)
    local lifeBar = newPanel(pX,pY,pWidth,pHeight)

    lifeBar.max = pMax
    lifeBar.value = pMax
    lifeBar.segmentImage = love.graphics.newImage("Assets/Images/HUD/LifeBar/Segment.png")
    lifeBar.image = love.graphics.newImage("Assets/Images/HUD/LifeBar/Outline.png")
    lifeBar.colors = { {0.7,0.9,1}, {1,0.75,0.35} , {1,0.4,0.4} }


    lifeBar.drawlifeBar = function()
        
        local numberOfSegment = 36 * lifeBar.value / lifeBar.max

        
        love.graphics.setColor(lifeBar.colors[1])
        if lifeBar.value / lifeBar.max < 0.5 then
            love.graphics.setColor(lifeBar.colors[2])
        end
        if lifeBar.value / lifeBar.max < 0.2 then
            love.graphics.setColor(lifeBar.colors[3])
        end

        lifeBar.drawPanel()
        
        love.graphics.push()
        love.graphics.translate(lifeBar.getRelativePosition())        
        love.graphics.translate(5,18)

        for seg = 1, numberOfSegment do
            
            --[[love.graphics.setColor(lifeBar.colors[1])
            if seg < 35 * 0.5 then
                love.graphics.setColor(lifeBar.colors[2])
            end
            if seg < 35 * 0.2 then
                love.graphics.setColor(lifeBar.colors[3])
            end]]

            love.graphics.translate(5 ,0)
            love.graphics.draw(lifeBar.segmentImage, lifeBar.segmentImage:getWidth() / 2 ,lifeBar.segmentImage:getHeight() / 2,0,1,1, lifeBar.segmentImage:getWidth(), lifeBar.segmentImage:getHeight())
        end

        love.graphics.pop()

        love.graphics.setColor(1,1,1)
    end

    lifeBar.draw = function()
        lifeBar.drawlifeBar()
        lifeBar.drawChildrens()
    end

    return lifeBar
end
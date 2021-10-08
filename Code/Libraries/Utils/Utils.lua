require("Libraries.Utils.Vector")

function newGridTexture(pWidth,pHeight,pColumns,pRows,pMode,pDarkColor,pLightColor)
    local canvas = love.graphics.newCanvas(pWidth,pHeight)
    love.graphics.setCanvas(canvas)
    if pDarkColor == nil then pDarkColor = {0.3,0.3,0.3,1.0} end
    if pLightColor == nil then pLightColor = {0.5,0.5,0.5,1.0} end
    
    if pMode == "lines" then
        for x = 0, pWidth, pWidth / pColumns do
            love.graphics.line(x,0,x,pHeight)
        end
        for y = 0, pHeight, pHeight / pRows do
            love.graphics.line(0,y,pWidth,y)
        end
    elseif pMode == "chess" then
        local i = 0
        for x = 0, pWidth, pWidth / pColumns do
            for y = 0, pHeight, pHeight / pRows do
                if i%2 == 0 then love.graphics.setColor(pDarkColor)
                else love.graphics.setColor(pLightColor) end
                love.graphics.rectangle("fill",x,y,pWidth / pColumns,pHeight / pRows)
                i = i + 1
            end
        end
        love.graphics.setColor(1,1,1,1)
    end

    love.graphics.setCanvas()
    return canvas
end

function drawFps(pX, pY, pWidth, pHeight, pMax)
    local fps = love.timer.getFPS( )
    local barSize = pWidth * (fps / pMax)

    love.graphics.push()
    love.graphics.translate(pX,pY)
    
    if fps >= 60 then love.graphics.setColor(0.3,0.8,0)
    elseif fps >= 30 then love.graphics.setColor(1,0.5,0) else
        love.graphics.setColor(1,0,0)
    end
    love.graphics.rectangle("fill",0 , 0 , barSize, pHeight)
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line",0 , 0 , pWidth, pHeight)

    love.graphics.setColor(0,0,0)
    love.graphics.print(fps.." fps", 5 + 1,pHeight / 2 - 8 + 1 )
    love.graphics.setColor(1,1,1)
    love.graphics.print(fps.." fps", 5,pHeight / 2 - 8 )

    love.graphics.pop()
end
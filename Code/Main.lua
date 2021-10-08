require("Libraries.ScenesController")

function love.load()
    love.window.setMode(1600,900)
    changeScene("menu")
end

function love.update(dt)
    updateCurrentScene(dt)
end

function love.draw()
    drawCurrentScene(dt)
end

function love.mousepressed(pX, pY, pBtn)
    mousePressed(pX, pY, pBtn)
end

function love.keypressed(pKey)
    keyPressed(pKey)
end
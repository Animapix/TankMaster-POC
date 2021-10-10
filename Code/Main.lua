require("Libraries.Utils.Utils")
require("Libraries.GUIController")
require("Libraries.ScenesController")
require("Libraries.CollisionsController")
require("Libraries.SpritesController")

require("Scenes.MenuScene")
require("Scenes.GameScene")
require("Scenes.TestScene")

love.graphics.setDefaultFilter("nearest")

function love.load()
    love.window.setMode(1600,900)
    changeScene("game")
end

function love.update(dt)
    updateCurrentScene(dt)
end

function love.draw()
    love.graphics.scale(2,2)
    drawCurrentScene(dt)
end

function love.mousepressed(pX, pY, pBtn)
    mousePressed(pX, pY, pBtn)
end

function love.keypressed(pKey)
    keyPressed(pKey)
end
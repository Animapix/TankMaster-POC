require("Libraries.Utils.Utils")
require("Libraries.GUIController")
require("Libraries.ScenesController")
require("Libraries.CollisionsController")
require("Libraries.SpritesController")
require("Libraries.Tweening")

require("Scenes.MenuScene")
require("Scenes.GameScene")
require("Scenes.TestScene")

love.graphics.setDefaultFilter("nearest")

soundsLevel = 0.2
musicsLevel = 0.1

function love.load()
    love.window.setMode(1600,900,{ resizable = false, vsync = true, centered = true})
    love.window.setTitle("TankMaster")
    changeScene("test")
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
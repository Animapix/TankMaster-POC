local scenes = {}
local currentScene = nil

changeScene = function(pSceneLabel)
    if currentScene ~= nil then currentScene.unload() end
    currentScene = scenes[pSceneLabel]
    if currentScene ~= nil then currentScene.load() end
end

updateCurrentScene = function(dt)
    if currentScene ~= nil then currentScene.update(dt) end
end

drawCurrentScene = function(dt)
    if currentScene ~= nil then currentScene.draw(dt) end
end

mousePressed = function(pX,pY,pBtn)
    if currentScene ~= nil then currentScene.mousePressed(pX,pY,pBtn) end
end

keyPressed = function(pKey)
    if currentScene ~= nil then currentScene.keyPressed(pKey) end
end

newScene = function(pLabel)
    local scene = {}
    scene.canvas = nil
    scene.opacity = 0

    scene.load = function()
    end

    scene.update = function(dt)
    end

    scene.draw = function()
    end

    scene.mousePressed = function(pX,pY,pBtn)
    end

    scene.keyPressed = function(pKey)
    end

    scene.unload = function()
    end

    scenes[pLabel] = scene
    return scene
end

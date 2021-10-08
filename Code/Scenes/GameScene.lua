local scene = newScene("game")


scene.load = function()

end

scene.update = function(dt)
    updateCollisions()
end

scene.draw = function()
    drawColliders()
end

scene.mousePressed = function(pX,pY,pBtn)
end

scene.keyPressed = function(pKey)
end

scene.unload = function()
    unloadColliders()
end
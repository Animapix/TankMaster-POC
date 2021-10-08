local scene = newScene("game")


scene.load = function()
    addNewSpritesLayer("Floor")

    mainNode = newSprite(100, 100, love.graphics.newImage("Assets/PlaceHolders/Tank.png"), "Floor")
    mainNode.addChild( newSpriteNode( 20,  20) )
    mainNode.addChild( newSpriteNode(-20,  20) )
    mainNode.addChild( newSpriteNode(-20, -20) )
    mainNode.addChild( newSpriteNode( 20, -20) )
end

scene.update = function(dt)
    mainNode.rotation = mainNode.rotation + dt
    updateSprites(dt)
    updateCollisions(dt)
end

scene.draw = function()
    drawSprites()
    drawColliders()
end

scene.mousePressed = function(pX,pY,pBtn)
end

scene.keyPressed = function(pKey)
end

scene.unload = function()
    unloadColliders()
end
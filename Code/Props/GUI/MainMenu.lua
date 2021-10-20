function newMainMenu()   
    local menu = {}
    
    menu.panel = newPanel(200,0,0,0)
    menu.panel.setImage(love.graphics.newImage("Assets/Images/HUD/Panel_400x300.png"))
    
    -- Setup title
    menu.title = newLabel(0,40,400,40,"TANK MASTER",love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 28))
    menu.panel.addChild(menu.title)

    -- Setup Play button
    menu.resumeBtn = newButton(100,125,100,15,"PLAY",love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 14))
    menu.resumeBtn.setEvent("pressed", function(pState)
        if pState == "end" then
            menu.onPlayBtnPressed()
        end
    end )
    menu.resumeBtn.setImage(
        love.graphics.newImage("Assets/Images/HUD/BTN_NORM.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_HOVER.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_PRESSED.png")
    )
    menu.panel.addChild(menu.resumeBtn)

    -- Setup Quit button
    menu.quitBtn = newButton(100,175,100,15,"QUIT",love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 14))
    menu.quitBtn.setEvent("pressed", function(pState)
        if pState == "end" then
            love.event.quit() 
        end
    end )
    menu.quitBtn.setImage(
        love.graphics.newImage("Assets/Images/HUD/BTN_NORM.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_HOVER.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_PRESSED.png")
    )
    menu.panel.addChild(menu.quitBtn)

    

    menu.panel.visible = false
    addControl(menu.panel)

    menu.show = function()
        stopTweens()
        menu.panel.visible = true
        newTween(menu.panel,"y",menu.panel.y,75,0.8,tweenTypes.quarticOut)
    end
    
    menu.hide = function()
        stopTweens()
        local tween = newTween(menu.panel,"y",menu.panel.y,-300,0.8,tweenTypes.quarticOut)
        tween.onFinsish = function()
            menu.panel.visible = false
        end
    end

    menu.onPlayBtnPressed = function()
        print("Main menu")
    end

    return menu
end
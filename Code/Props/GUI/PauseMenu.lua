function newPauseMenu()   
    local menu = {}


    menu.panel = newPanel(200,-300,0,0)
    menu.panel.setImage(love.graphics.newImage("Assets/Images/HUD/Panel_400x300.png"))

    -- Setup title
    menu.title = newLabel(0,40,400,40,"PAUSE",love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 28))
    menu.panel.addChild(menu.title)

    -- Setup Resume button
    menu.resumeBtn = newButton(100,125,100,15,"RESUME",love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 14))
    menu.resumeBtn.setEvent("pressed", function(pState)
        if pState == "end" then
            menu.onResumeBtnPressed()
        end
    end )
    menu.resumeBtn.setImage(
        love.graphics.newImage("Assets/Images/HUD/BTN_NORM.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_HOVER.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_PRESSED.png")
    )
    menu.panel.addChild(menu.resumeBtn)


    -- Setup main menu button
    menu.mainMenuBtn = newButton(100,175,100,15,"MENU",love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 14))
    menu.mainMenuBtn.setEvent("pressed", function(pState)
        if pState == "end" then
            menu.onMainMenuBtnPressed()
        end
    end )
    menu.mainMenuBtn.setImage(
        love.graphics.newImage("Assets/Images/HUD/BTN_NORM.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_HOVER.png"),
        love.graphics.newImage("Assets/Images/HUD/BTN_PRESSED.png")
    )
    menu.panel.addChild(menu.mainMenuBtn)

    menu.panel.visible = false
    addControl(menu.panel)

    menu.show = function()
        stopTweens()
        --sceneState = "pause"
        menu.panel.visible = true
        newTween(menu.panel,"y",menu.panel.y,75,0.8,tweenTypes.quarticOut)
    end
    
    menu.hide = function()
        stopTweens()
        --sceneState = "game"
        local tween = newTween(menu.panel,"y",menu.panel.y,-300,0.8,tweenTypes.quarticOut)
        tween.onFinsish = function()
            menu.panel.visible = false
        end
    end

    menu.onResumeBtnPressed = function()
        print("Resume")
    end

    menu.onMainMenuBtnPressed = function()
        print("Main menu")
    end

    return menu
end
function newGameOverMenu()   
    local menu = {}

    menu.titleFont = love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 28)
    menu.btnFont = love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 14)

    menu.panel = newPanel(200,-300,0,0)
    menu.panel.setImage(love.graphics.newImage("Assets/Images/HUD/Panel_400x300.png"))

    -- Setup title
    menu.title = newLabel(0,40,400,40,"GAME OVER",menu.titleFont)
    menu.panel.addChild(menu.title)


    -- Setup main menu button
    menu.mainMenuBtn = newButton(100,225,100,15,"MENU",menu.btnFont)
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

    menu.level = newLabel(80,80,320,40,"Level: 0",menu.btnFont)
    menu.level.alignH = "left"
    menu.panel.addChild(menu.level)

    menu.points = newLabel(80,100,320,40,"Points: 0",menu.btnFont)
    menu.points.alignH = "left"
    menu.panel.addChild(menu.points)

    menu.accuracy = newLabel(80,120,320,40,"Accuracy: 0%",menu.btnFont)
    menu.accuracy.alignH = "left"
    menu.panel.addChild(menu.accuracy)

    menu.killedEnemies = newLabel(80,140,320,40,"Enemies killed: 0",menu.btnFont)
    menu.killedEnemies.alignH = "left"
    menu.panel.addChild(menu.killedEnemies)


    menu.panel.visible = false
    addControl(menu.panel)

    menu.show = function()
        stopTweens()
        --sceneState = "pause"
        menu.panel.visible = true
        newTween(menu.panel,"y",menu.panel.y,75,0.8,tweenTypes.quarticOut)

        menu.accuracy.setText("Accuracy: "..math.floor(getAccuracy() * 100).."%")
        menu.killedEnemies.setText("enemies killed: "..getEnemiesKilled())
    end
    
    menu.hide = function()
        stopTweens()
        --sceneState = "game"
        local tween = newTween(menu.panel,"y",menu.panel.y,-300,0.8,tweenTypes.quarticOut)
        tween.onFinsish = function()
            menu.panel.visible = false
        end
    end

    menu.onMainMenuBtnPressed = function()
        print("Main menu")
    end

    return menu
end
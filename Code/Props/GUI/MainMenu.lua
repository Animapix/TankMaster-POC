function newMainMenu()   
    local menu = {}

    menu.titleFont = love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 28)
    menu.btnFont = love.graphics.newFont("Assets/Fonts/kenvector_future_thin.ttf", 14)

    menu.panel = newPanel(200,0,0,0)
    menu.panel.setImage(love.graphics.newImage("Assets/Images/HUD/Panel_400x300.png"))
    
    -- Setup title
    menu.title = newLabel(0,40,400,40,"TANK MASTER",menu.titleFont)
    menu.panel.addChild(menu.title)

    -- Setup Resume button
    menu.resumeBtn = newButton(100,180,100,15,"PLAY",menu.btnFont)
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
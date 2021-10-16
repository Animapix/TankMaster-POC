function newHUD()
    local HUD = {}

    HUD.font = love.graphics.newFont("Assets/Fonts/retro_computer_personal_use.ttf", 14)

    HUD.panel = newControl(0,0)

    HUD.lifeBar = newLifeBar(5,-50,300,20,500)
    HUD.panel.addChild(HUD.lifeBar)

    HUD.pointsLabel = newScoreLabel(600,-45)
    HUD.panel.addChild(HUD.pointsLabel)

    addControl(HUD.panel)

    newTween(HUD.lifeBar,"y",HUD.lifeBar.y,5,0.8,tweenTypes.quarticOut,0.1)
    newTween(HUD.pointsLabel,"y",HUD.pointsLabel.y,5,0.8,tweenTypes.quarticOut,0.2)
    

    return HUD
end
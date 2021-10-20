

function newScoreLabel(pX,pY)
    local scoreLabel = newPanel(pX,pY,pWidth,pHeight)
    scoreLabel.setImage(love.graphics.newImage("Assets/Images/HUD/LifeBar/Outline.png"))

    scoreLabel.label = newLabel(0,-2,scoreLabel.width,scoreLabel.height,"000000000000",love.graphics.newFont("Assets/Fonts/retro_computer_personal_use.ttf", 14))
    scoreLabel.addChild(scoreLabel.label)

    scoreLabel.totalDigits = 12
    scoreLabel.score = 0

    scoreLabel.update = function(dt)
        local scoreString = scoreLabel.formatScore(scoreLabel.score,scoreLabel.totalDigits)
        scoreLabel.label.setText(scoreString)
    end

    scoreLabel.addScore = function(amount)
        scoreLabel.score = scoreLabel.score + amount
    end

    scoreLabel.subScore = function(amount)
        scoreLabel.score = scoreLabel.score - amount
    end

    scoreLabel.formatScore = function(score, totalDigits)
        if type(score) ~= "number" then return end
        local str = tostring(score)
        local n = string.len(str)
        for i=0,scoreLabel.totalDigits - n do
            str = "0"..str
        end
        return str
    end

    return scoreLabel
end

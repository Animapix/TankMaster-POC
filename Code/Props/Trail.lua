local trailMarkImg = love.graphics.newImage("Assets/Images/Tank/TrailMark.png")

function newTrail(pX,pY,pLayer)
    local trail = newSpriteNode(pX,pY)

    trail.previousPosition = trail.getRelativePosition()
    trail.distance = 0
    trail.stepSize = 5
    trail.marks = {}

    trail.update = function(dt)
        local distance = trail.previousPosition.distance(trail.getRelativePosition())
        trail.distance = trail.distance + distance
        if trail.distance > trail.stepSize then
            trail.newMark()
            trail.distance = 0
        end

        for i= #trail.marks, 1, -1 do
            local mark = trail.marks[i]
            mark.distance = mark.distance + distance
            mark.opacity = 1 - mark.distance/500
            if mark.distance >= 500 then
                mark.remove = true
                table.remove(trail.marks,i)
            end
        end

        trail.previousPosition = trail.getRelativePosition()
    end

    trail.newMark = function()
        local mark = newSprite(trail.getRelativeX(),trail.getRelativeY(),trailMarkImg,pLayer)
        mark.rotation = trail.getRelativeRotation()
        mark.distance = 0
        table.insert(trail.marks,mark)
    end

    return trail
end
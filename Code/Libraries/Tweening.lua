tweenTypes = {}

tweenTypes.linear = "linear"

tweenTypes.quadraticIn      = "easeInQuad"
tweenTypes.quadraticOut     = "easeOutQuad"
tweenTypes.quadraticInOut   = "easeInOutQuad"

tweenTypes.cubicIn          = "easeInCubic"
tweenTypes.cubicOut         = "easeOutCubic"
tweenTypes.cubicInOut       = "easeInOutCubic"

tweenTypes.quarticIn = "easeInQuart"
tweenTypes.quarticOut = "easeOutQuart"
tweenTypes.quarticInOut = "easeInOutQuart"

tweenTypes.quinticIn = "easeInQuint"
tweenTypes.quinticOut = "easeOutQuint"
tweenTypes.quinticInOut = "easeInOutQuint"

tweenTypes.sinusoidalIn = "easeInSine"
tweenTypes.sinusoidalOut = "easeOutSine"
tweenTypes.sinusoidalInOut = "easeInOutSine"

tweenTypes.exponentialIn = "easeInExpo"
tweenTypes.exponentialOut = "easeOutExpo"
tweenTypes.exponentialInOut = "easeInOutExpo"

tweenTypes.circularIn = "easeInCirc"
tweenTypes.circularOut = "easeOutCirc"
tweenTypes.circularInOut = "easeInOutCirc"


local tweens = {}



function updateTweening(dt)
    for __,tween in pairs(tweens) do
        tween.update(dt)
    end

    for i=#tweens, 1, -1 do
        if tweens[i].remove then
            table.remove(tweens,i)
        end
    end
end

function stopTweens()
    for i=#tweens, 1, -1 do
        table.remove(tweens,i)
    end
end

 
function newTween(pTarget, pKey, pStartValue, pEndValue, pDuration, pType, pDelay)
    local tween = {}

    tween.target = pTarget 
    tween.targetKey = pKey
    tween.startValue = pStartValue
    tween.endValue = pEndValue - pStartValue
    tween.duration = pDuration
    tween.type = pType
    tween.delay = pDelay or 0
    
    tween.time = 0
    tween.onFinsish = nil
    tween.remove = false

    setValue(tween.target, tween.targetKey, pStartValue)

    tween.update = function(dt)
        
        if tween.delay > 0 then
            tween.delay = tween.delay - dt
            return
        end

        if tween.time <= tween.duration then
            tween.time = tween.time + dt
            local value = tween[tween.type](tween.time,tween.startValue,tween.endValue,tween.duration)
            setValue(tween.target, tween.targetKey, value) -- Utils function to set value in composed table
        else
            setValue(tween.target, tween.targetKey, tween.endValue +  tween.startValue)
            if tween.onFinsish ~= nil then tween.onFinsish() end
            tween.remove = true
        end
    end

    tween.linear = function(t, b, c, d)
        return c*t/d + b
    end

    tween.easeInQuad = function(t, b, c, d)
        t = t/d
        return c*t*t + b
    end

    tween.easeOutQuad = function(t, b, c, d)
        t = t/d
	    return -c * t*(t-2) + b
    end

    tween.easeInOutQuad = function(t, b, c, d)
        t =  t / (d / 2)
	    if t < 1 then return c/2*t*t + b end
	    t = t - 1
	    return -c/2 * (t*(t-2) - 1) + b
    end

    tween.easeInCubic = function(t, b, c, d)
        t = t/d
	    return c*t*t*t + b
    end

    tween.easeOutCubic = function(t, b, c, d)
        t = t/d
	    t = t - 1
	    return c*(t*t*t + 1) + b
    end

    tween.easeInOutCubic = function(t, b, c, d)
        t =  t / (d / 2)
        if t < 1 then return c/2*t*t*t + b end
	    t = t - 2
	    return c/2*(t*t*t + 2) + b
    end

    tween.easeInQuart = function(t, b, c, d)
        t = t/d
	    return c*t*t*t*t + b
    end

    tween.easeOutQuart = function(t, b, c, d)
        t = t/d
	    t = t-1
	    return -c * (t*t*t*t - 1) + b
    end

    tween.easeInOutQuart = function(t, b, c, d)
        t =  t / (d / 2)
        if t < 1 then return c/2*t*t*t*t + b end
        t = t-2
        return -c/2 * (t*t*t*t - 2) + b
    end

    tween.easeInQuint = function(t, b, c, d)
        t = t/d
	    return c*t*t*t*t*t + b
    end

    tween.easeOutQuint = function(t, b, c, d)
        t = t/d
	    t = t-1
	    return c*(t*t*t*t*t + 1) + b
    end

    tween.easeInOutQuint = function(t, b, c, d)
        t =  t / (d / 2)
        if t < 1 then return c/2*t*t*t*t*t + b end
        t = t-2
        return c/2*(t*t*t*t*t + 2) + b
    end

    tween.easeInSine = function(t, b, c, d)
        return -c * math.cos(t/d * (math.pi/2)) + c + b
    end

    tween.easeOutSine = function(t, b, c, d)
        return c * math.sin(t/d * (math.pi/2)) + b
    end

    tween.easeInOutSine = function(t, b, c, d)
        return -c/2 * (math.cos(math.pi*t/d) - 1) + b
    end

    tween.easeInExpo = function(t, b, c, d)
        return c * math.pow( 2, 10 * (t/d - 1) ) + b
    end

    tween.easeOutExpo = function(t, b, c, d)
        return c * ( -math.pow( 2, -10 * t/d ) + 1 ) + b
    end

    tween.easeInOutExpo = function(t, b, c, d)
        t =  t / (d / 2)
        if t < 1 then return c/2 * math.pow( 2, 10 * (t - 1) ) + b end 
        t = t - 1
        return c/2 * ( -math.pow( 2, -10 * t) + 2 ) + b
    end

    tween.easeInCirc = function(t, b, c, d)
        t = t/d
	    return -c * (math.sqrt(1 - t*t) - 1) + b
    end

    tween.easeOutCirc = function(t, b, c, d)
        t = t/d
	    t = t-1
	    return c * math.sqrt(1 - t*t) + b
    end

    tween.easeInOutCirc = function(t, b, c, d)
        t =  t / (d / 2)
        if t < 1 then return -c/2 * (math.sqrt(1 - t*t) - 1) + b end
        t = t-2
        return c/2 * (math.sqrt(1 - t*t) + 1) + b
    end

    table.insert(tweens,tween)
    return tween
end
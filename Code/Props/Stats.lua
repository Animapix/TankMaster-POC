
local enemiesKilled          = 0
local rifleBulletsFired      = 0
local rifleBulletsMised      = 0
local explosivesBulletsFired = 0
local explosivesBulletsMised = 0

function statsEnemyKilled()
    enemiesKilled = enemiesKilled + 1
end

function statsRifleBulletFired()
    rifleBulletsFired = rifleBulletsFired + 1
end

function statsExplosivesBulletFired()
    explosivesBulletsFired = explosivesBulletsFired + 1
end

function statsRifleBulletMised()
    rifleBulletsMised = rifleBulletsMised + 1
end

function statsExplosivesBulletMised()
    explosivesBulletsMised = explosivesBulletsMised + 1
end

function getRifleAccuracy()
    return  (rifleBulletsFired - rifleBulletsMised) / rifleBulletsFired
end

function getExplosiveAccuracy()
    return  (explosivesBulletsFired - explosivesBulletsMised) / explosivesBulletsFired
end

function getAccuracy()
    return ((rifleBulletsFired - rifleBulletsMised) + (explosivesBulletsFired - explosivesBulletsMised)) / (rifleBulletsFired +  explosivesBulletsFired)
end

function getEnemiesKilled()
    return enemiesKilled
end

function statsReset()
    enemiesKilled          = 0
    rifleBulletsFired      = 0
    rifleBulletsMised      = 0
    explosivesBulletsFired = 0
    explosivesBulletsMised = 0
end

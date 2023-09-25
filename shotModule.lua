local shotModule = {}

local MathMod = require("utilMath")
local SettingsMod = require("settings")
local Tank = require("tank")
local EnemyMod = require("enemyModule")
local ExplodeMod = require("explodeModule")
local MiningMod = require("miningModule")

shotModule.listShots = nil

--utils pour les missiles
local LIMIT_COUNTER_SINUSOIDE = 0.2
local CONST_DEVIATION = 25

shotModule.LST_SOUNDS_SHOT = {}
shotModule.LST_SOUNDS_SHOT[1] = love.audio.newSource("sounds/shot_1.wav", "static")
shotModule.LST_SOUNDS_SHOT[2] = love.audio.newSource("sounds/shot_2.wav", "static")

local LST_SHOT_RANGE = {}
LST_SHOT_RANGE[1] = 300
LST_SHOT_RANGE[2] = 450

local LST_BUL_SPD_PLAYER = {}
LST_BUL_SPD_PLAYER[1] = 600
LST_BUL_SPD_PLAYER[2] = 400

local LST_BUL_SPEED_ENEMY = {}
LST_BUL_SPEED_ENEMY[1] = 800
LST_BUL_SPEED_ENEMY[2] = 700
LST_BUL_SPEED_ENEMY[3] = 600

function shotModule.load()
  shotModule.listShots = {}
end

function Shoot(pXShooter, pYShooter, pAngle, pSpeed, pType, pTeam)
  local s = {}
  s.x = pXShooter
  s.y = pYShooter
  s.angle = pAngle
  s.speed = pSpeed
  s.type = pType
  s.team = pTeam
  s.isDeletable = false
  s.isExplode = false

  if s.team == "ally" then
    s.image = love.graphics.newImage("images/myBullet" .. tostring(s.type) .. ".png")
  elseif s.team == "enemy" then
    s.image = love.graphics.newImage("images/enemyBullet" .. tostring(s.type) .. ".png")
  end

  s.w = s.image:getWidth()
  s.h = s.image:getHeight()

  --différence missiles/obus simples
  if s.type == 3 then
    s.explodeType = "missile"
    local rnd = math.random(0, 1)
    if rnd == 0 then
      s.deviateUp = false
      s.deviateCounter = -LIMIT_COUNTER_SINUSOIDE / 2
    else
      s.deviateUp = true
      s.deviateCounter = LIMIT_COUNTER_SINUSOIDE / 2
    end
  elseif s.type == 1 or s.type == 2 then
    s.explodeType = "simple"
    s.distTraveled = 0
  end

  table.insert(shotModule.listShots, s)
end

function shotModule.update(dt)
  --tirs du joueur
  if love.mouse.isDown(1) and Tank.timerShot1 <= 0 then
    --love.audio.stop(ShotMod.LST_SOUNDS_SHOT[1])
    --love.audio.play(ShotMod.LST_SOUNDS_SHOT[1])
    Tank.timerShot1 = Tank.RATES_SHOTS[1]
    Shoot(Tank.x, Tank.y, Tank.angleBarrel, LST_BUL_SPD_PLAYER[1], 1, "ally")
  elseif love.mouse.isDown(2) and Tank.timerShot2 <= 0 then
    Tank.timerShot2 = Tank.RATES_SHOTS[2]
    --love.audio.stop(ShotMod.LST_SOUNDS_SHOT[2])
    --love.audio.play(ShotMod.LST_SOUNDS_SHOT[2])
    Shoot(Tank.x, Tank.y, Tank.angleBarrel, LST_BUL_SPD_PLAYER[2], 2, "ally")
  end

  --tirs des ennemis
  for n = 1, #EnemyMod.listEnemies do
    local e = EnemyMod.listEnemies[n]
    if e.isShooting and Tank.isDead == false then
      e.isShooting = false
      local x = e.x + math.cos(math.rad(e.angleBarrel)) * EnemyMod.BARREL_WIDTH
      local y = e.y + math.sin(math.rad(e.angleBarrel)) * EnemyMod.BARREL_WIDTH
      Shoot(x, y, e.angleBarrel, LST_BUL_SPEED_ENEMY[e.type], e.type, "enemy")
    end
  end

  --update des tirs
  for n = 1, #shotModule.listShots do
    local s = shotModule.listShots[n]

    if s.type == 3 then
      --On dévie le tir dans un sens ou dans l'autre (sinusoïdale)
      if s.deviateUp then
        s.angle = s.angle + dt * CONST_DEVIATION
        s.deviateCounter = s.deviateCounter + dt
      else
        s.angle = s.angle - dt * CONST_DEVIATION
        s.deviateCounter = s.deviateCounter - dt
      end

      if s.deviateCounter >= LIMIT_COUNTER_SINUSOIDE then
        s.deviateUp = false
      elseif s.deviateCounter <= -LIMIT_COUNTER_SINUSOIDE then
        s.deviateUp = true
      end
    end

    --Avancée des tirs
    local oldX = s.x
    local oldY = s.y
    local vx = math.cos(math.rad(s.angle)) * s.speed
    local vy = math.sin(math.rad(s.angle)) * s.speed

    s.x = s.x + vx * dt
    s.y = s.y + vy * dt

    --Collision des tirs avec les ennemis ou le joueur
    if s.team == "enemy" then
      local isCollide =
        MathMod.verifyCollideGeneral(s.x, s.y, s.w, s.h, Tank.x, Tank.y, Tank.widthTank, Tank.heightTank)
      if isCollide then
        s.isDeletable = true
        Tank.hurts(s.type)
        if s.type == 3 then
          ExplodeMod.createExplode(s.x, s.y, 0.1, "missile")
        else
          ExplodeMod.createExplode(s.x, s.y, 0.1, "simple")
        end
      end
    elseif s.team == "ally" then
      for n = 1, #EnemyMod.listEnemies do
        local e = EnemyMod.listEnemies[n]
        local isCollide =
          MathMod.verifyCollideGeneral(s.x, s.y, s.w, s.h, e.x, e.y, EnemyMod.TANK_WIDTH, EnemyMod.TANK_HEIGHT)
        if isCollide then
          s.isDeletable = true
          e.hp = e.hp - s.type
          ExplodeMod.createExplode(s.x, s.y, 0.1, "simple")
        end
      end
    end

    --Collision avec les sites de minage
    for n = 1, #MiningMod.listSites do 
      local site = MiningMod.listSites[n]
      isCollide = MathMod.verifyCollideGeneral(
        s.x, s.y, s.w, s.h,
        site.x, site.y, MiningMod.mineW, MiningMod.mineH
      )
  
      if isCollide then
        s.isDeletable = true
        s.isExplode = true
        break
      end
    end

    --distance parcourue des tirs
    if s.type == 1 or s.type == 2 then
      s.distTraveled = s.distTraveled + (MathMod.absoluteDistance(oldX, oldY, s.x, s.y))
      if s.distTraveled >= LST_SHOT_RANGE[s.type] then
        s.isDeletable = true
        s.isExplode = true
      end
    end

    --Sors de l'écran
    local isCollideBorder = MathMod.verifyCollideScreenBorders(s, SettingsMod.screenW, SettingsMod.screenH, "outside")

    if isCollideBorder then
      s.isDeletable = true
    end
  end

  --Suppression des tirs
  for n = #shotModule.listShots, 1, -1 do
    local s = shotModule.listShots[n]
    if s.isDeletable then
      --Si le tir a touché on le fait exploser
      if s.isExplode then
        local timer = math.random(5, 20) / 100
        ExplodeMod.createExplode(s.x, s.y, timer, s.explodeType)
      end
      table.remove(shotModule.listShots, n)
    end
  end
end

function shotModule.draw()
  if #shotModule.listShots > 0 then
    for n = 1, #shotModule.listShots do
      local s = shotModule.listShots[n]
      love.graphics.draw(s.image, s.x, s.y, math.rad(s.angle), 1, 1, s.image:getWidth() / 2, s.image:getHeight() / 2)
    end
  end
end

return shotModule

local shotModule = {}

local MathMod = require("utilMath")
local SettingsMod = require("settings")
local Tank = require("tank")
local UpMod = require("upgrade")
local EnemyMod = require("enemyModule")
local ExplodeMod = require("explodeModule")
local MiningMod = require("miningModule")

shotModule.listShots = nil

--utils pour les missiles
local LIMIT_COUNTER_SINUSOIDE = 0.2
local CONST_DEVIATION = 25

shotModule.LST_IMGS_SHOTS_ALLY = {}
for n = 1, 3 do
  shotModule.LST_IMGS_SHOTS_ALLY[n] = love.graphics.newImage("images/myBullet" .. tostring(n) .. ".png")
end

shotModule.LST_IMGS_SHOTS_ENEMY = {}
for n = 1, 3 do
  shotModule.LST_IMGS_SHOTS_ENEMY[n] = love.graphics.newImage("images/enemyBullet" .. tostring(n) .. ".png")
end

local LST_SHOT_RANGE = {}
LST_SHOT_RANGE[1] = 275
LST_SHOT_RANGE[2] = 400
LST_SHOT_RANGE[3] = 500

local LST_BUL_SPD_PLAYER = {}
LST_BUL_SPD_PLAYER[1] = 600
LST_BUL_SPD_PLAYER[2] = 400
LST_BUL_SPD_PLAYER[3] = 400

local LST_BUL_SPEED_ENEMY = {}
LST_BUL_SPEED_ENEMY[1] = 750
LST_BUL_SPEED_ENEMY[2] = 650
LST_BUL_SPEED_ENEMY[3] = 550

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
  s.soundShot = love.audio.newSource("sounds/shot_" .. tostring(pType) .. ".wav", "static")
  s.soundExplode = love.audio.newSource("sounds/explodeShot.wav", "static")

  if s.team == "ally" then
    s.image = shotModule.LST_IMGS_SHOTS_ALLY[s.type]
    local bonusSpd = UpMod.listBul[pType][2].bonus
    s.speed = pSpeed + bonusSpd
  elseif s.team == "enemy" then
    s.image = shotModule.LST_IMGS_SHOTS_ENEMY[s.type]
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
  s.soundShot:play()
  table.insert(shotModule.listShots, s)
end

function shotModule.update(dt)
  --tirs du joueur
  local mouseX, mouseY = love.mouse.getPosition()
  --On controle le x de la souris par rapport au panneau d'upgrades
  if mouseX <= SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER then
    local idWeapon = Tank.currentWeapon
    if love.mouse.isDown(1) then
      if Tank.timersShots[idWeapon] <= 0 then
        Tank.timersShots[idWeapon] = Tank.RATES_SHOTS[idWeapon]
        Shoot(Tank.x, Tank.y, Tank.angleBarrel, LST_BUL_SPD_PLAYER[idWeapon], idWeapon, "ally")
      end
    end
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
      --Les missiles ennemis serpentent
      if s.team == "enemy" then
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
      --elseif s.team == "ally" then
      --Les missiles alliés poursuivent une cible
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
        MathMod.verifyCollideGeneral(s.x, s.y, s.w / 2, s.h / 2, Tank.x, Tank.y, Tank.widthTank, Tank.heightTank)
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
          MathMod.verifyCollideGeneral(s.x, s.y, s.w / 2, s.h / 2, e.x, e.y, EnemyMod.TANK_WIDTH, EnemyMod.TANK_HEIGHT)
        if isCollide and s.isDeletable == false then
          s.isDeletable = true
          local bonusDamage = UpMod.listBul[s.type][1].bonus
          e.hp = e.hp - s.type - bonusDamage
          if e.hp < 0 then
            e.hp = 0
          end
          ExplodeMod.createExplode(s.x, s.y, 0.1, "simple")
        end
      end
    end

    --Collision avec les sites de minage
    for n = 1, #MiningMod.listSites do
      local site = MiningMod.listSites[n]
      isCollide =
        MathMod.verifyCollideGeneral(s.x, s.y, s.w / 2, s.h / 2, site.x, site.y, MiningMod.mineW, MiningMod.mineH)

      if isCollide then
        s.isDeletable = true
        s.isExplode = true
        break
      end
    end

    --distance parcourue des tirs
    if s.type == 1 or s.type == 2 then
      s.distTraveled = s.distTraveled + (MathMod.absoluteDistance(oldX, oldY, s.x, s.y))
      local bonusRange = UpMod.listBul[s.type][4].bonus
      if s.distTraveled >= LST_SHOT_RANGE[s.type] + bonusRange then
        s.isDeletable = true
        s.isExplode = true
      end
    end

    --Sors de l'écran
    local isCollideBorder =
      MathMod.verifyCollideScreenBorders(
      s,
      SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER,
      SettingsMod.screenH,
      "outside"
    )

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
        s.soundExplode:play()
      end
      if s.type == 3 then
        s.soundShot:stop()
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

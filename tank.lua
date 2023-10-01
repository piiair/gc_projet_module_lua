local tank = {}

local SettingsMod = require("settings")
local MathMod = require("utilMath")
local GoldMod = require("gold")
local EnemyMod = require("enemyModule")
local MiningMod = require("miningModule")
local ExplodeMod = require("explodeModule")

tank.RATES_SHOTS = {}
tank.RATES_SHOTS[1] = 0.75
tank.RATES_SHOTS[2] = 3.5
tank.RATES_SHOTS[3] = 5.5

--Fixe
tank.imageTank = love.graphics.newImage("images/tank.png")
tank.imageBarrel = love.graphics.newImage("images/barrel.png")
tank.widthTank = tank.imageTank:getWidth()
tank.heightTank = tank.imageTank:getHeight()
tank.widthBarrel = tank.imageBarrel:getWidth()
tank.heightBarrel = tank.imageBarrel:getHeight()

local sndCollectGold = love.audio.newSource("sounds/collectgold.wav", "static")
local sndExplodeTank = love.audio.newSource("sounds/explodeTank.wav", "static")
local sndCollide = love.audio.newSource("sounds/collision.wav", "static")

local MouseX, MouseY

--Variable
function tank.reset()
  tank.hpMax = 0
  tank.x = 0
  tank.y = 0
  tank.angleTank = 0
  tank.angleBarrel = 0
  tank.rotationSpeedTank = 0
  tank.rotationSpeedBarrel = 0
  tank.velocity = 0
  tank.velocityMax = 0
  tank.inertiaCap = 0
  tank.hpMax = 0
  tank.hp = 0
  tank.timersShots = {}
  tank.goldStock = 0
  tank.currentWeapon = 0
  tank.engineIsOn = false
  tank.gameOver = false
  tank.isDead = false

  SPACE_K_PRESSED = false
  canHeal = true
end

local function resetPosIfCollide(pIsCollide, pX, pY)
  if pIsCollide then
    tank.x = pX
    tank.y = pY
    sndCollide:play()
  end
end

local function VerifyCollideWithEntities(pOldPosX, pOldPosY)
  --Collision avec les bords
  if tank.x < 0 + (tank.widthTank / 2) then
    tank.x = 0 + (tank.widthTank / 2)
  elseif tank.x > SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER - (tank.widthTank / 2) then
    tank.x = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER - (tank.widthTank / 2)
  end

  if tank.y < 0 + (tank.heightTank / 2) then
    tank.y = 0 + (tank.heightTank / 2)
  elseif tank.y > SettingsMod.screenH - (tank.heightTank / 2) then
    tank.y = SettingsMod.screenH - (tank.heightTank / 2)
  end

  --Collision avec les autres tank
  for n = 1, #EnemyMod.listEnemies do
    local e = EnemyMod.listEnemies[n]
    if e.type < 4 then
      local isCollideWithAnEnemy =
        MathMod.verifyCollideGeneral(
        tank.x,
        tank.y,
        tank.widthTank,
        tank.heightTank,
        e.x,
        e.y,
        tank.widthTank,
        tank.heightTank
      )
      resetPosIfCollide(isCollideWithAnEnemy, pOldPosX, pOldPosY)
    end
  end

  --Collision avec les sites de minage
  for n = 1, #MiningMod.listSites do
    local s = MiningMod.listSites[n]
    local isCollide =
      MathMod.verifyCollideGeneral(
      tank.x,
      tank.y,
      tank.widthTank / 2,
      tank.heightTank / 2,
      s.x,
      s.y,
      MiningMod.mineW,
      MiningMod.mineH
    )
    resetPosIfCollide(isCollide, pOldPosX, pOldPosY)
  end

  --Collision avec les pièce d'or
  for n = 1, #GoldMod.listCoin do
    local c = GoldMod.listCoin[n]
    local isCollide = MathMod.verifyCollideGeneral(tank.x, tank.y, tank.widthTank, tank.heightTank, c.x, c.y, c.w, c.h)
    if isCollide then
      c.isDeletable = true
      tank.goldStock = tank.goldStock + 1
      sndCollectGold:stop()
      sndCollectGold:play()
    end
  end
end

function tank.hurts(pDammage)
  if tank.isDead == false then
    tank.hp = tank.hp - pDammage
    if tank.hp <= 0 then
      tank.hp = 0
      tank.isDead = true
      ExplodeMod.createMultiExplode(tank.x, tank.y, tank.widthTank, tank.heightTank)
      sndExplodeTank:play()
    end
  end
end

local function Heal()
  canHeal = false
  if tank.goldStock > 0 and tank.hp < tank.hpMax then
    tank.goldStock = tank.goldStock - 1
    tank.hp = tank.hp + 1
  end
end

function tank.load()
  tank.x = SettingsMod.screenW / 2
  tank.y = SettingsMod.screenH / 2
  tank.angleTank = 270
  tank.angleBarrel = 270
  tank.rotationSpeedTank = 200
  tank.rotationSpeedBarrel = 100
  tank.velocity = 0
  tank.velocityMax = 1.25
  tank.inertiaCap = 0.75
  tank.hpMax = 10
  tank.hp = tank.hpMax
  tank.timersShots = {}
  for n = 1, 3 do
    tank.timersShots[n] = 0.2
  end
  tank.goldStock = 0
  tank.currentWeapon = 1
  tank.engineIsOn = false
  tank.gameOver = false

  MouseX, MouseY = love.mouse.getPosition()
  tank.isDead = false
end

function tank.update(dt)
  if tank.hp > 0 then
    --timers tirs du tank
    for n = 1, #tank.timersShots do
      if tank.timersShots[n] > 0 then
        tank.timersShots[n] = tank.timersShots[n] - dt
      end
    end

    --rotation du tank
    if love.keyboard.isDown("q") then
      tank.angleTank = tank.angleTank - (tank.rotationSpeedTank * dt)
      tank.angleBarrel = tank.angleBarrel - (tank.rotationSpeedTank * dt)

      if tank.angleTank < 0 then
        tank.angleTank = 360 - tank.angleTank
      end
      if tank.angleBarrel < 0 then
        tank.angleBarrel = 360 - tank.angleBarrel
      end
    end

    if love.keyboard.isDown("d") then
      tank.angleTank = tank.angleTank + (tank.rotationSpeedTank * dt)
      tank.angleBarrel = tank.angleBarrel + (tank.rotationSpeedTank * dt)

      if tank.angleTank > 360 then
        tank.angleTank = tank.angleTank - 360
      end
      if tank.angleBarrel > 360 then
        tank.angleBarrel = tank.angleBarrel - 360
      end
    end

    --rotation du canon
    MouseX, MouseY = love.mouse.getPosition()
    tank.angleBarrel = MathMod.getAngle(tank.x, tank.y, MouseX, MouseY, "degAbsolute")

    --avancée du tank
    local oldPosX = tank.x
    local oldPosY = tank.y
    local forceX, forceY
    if love.keyboard.isDown("z") then
      --tank.engineIsOn = true
      if tank.velocity < tank.velocityMax then
        tank.velocity = tank.velocity + dt
      end
      if tank.velocity > tank.velocityMax then
        tank.velocity = tank.velocityMax
      end
    else
      --tank.engineIsOn = false
      if tank.velocity > 0 then
        tank.velocity = tank.velocity - dt
      end
      if tank.velocity < 0 then
        tank.velocity = 0
      end
    end

    local angleRadian = math.rad(tank.angleTank)
    forceX = math.cos(angleRadian) * (tank.velocity)
    forceY = math.sin(angleRadian) * (tank.velocity)
    tank.x = tank.x + forceX
    tank.y = tank.y + forceY

    --On vérifie toutes les collisions
    VerifyCollideWithEntities(oldPosX, oldPosY)
  else
    tank.isDead = true
  end

  --tank.gameOver
  if tank.isDead and #ExplodeMod.listExplodes == 0 then
    tank.gameOver = true
  end
end

function tank.draw()
  --dessin du tank
  if tank.isDead == false then
    love.graphics.draw(
      tank.imageTank,
      tank.x,
      tank.y,
      math.rad(tank.angleTank),
      1,
      1,
      tank.widthTank / 2,
      tank.heightTank / 2
    )

    --dessin du canon
    love.graphics.draw(tank.imageBarrel, tank.x, tank.y, math.rad(tank.angleBarrel), 1, 1, 5, tank.heightBarrel / 2)

    --test variables
    love.graphics.print(tostring(tank.currentWeapon))
  end
end

function tank.keypressed(key)
  if tank.hp > 0 then
    if key == "s" then
      tank.currentWeapon = tank.currentWeapon + 1
      if tank.currentWeapon > 3 then
        tank.currentWeapon = 1
      end
    end

    if key == "space" then
      Heal()
    end
  end
end

return tank

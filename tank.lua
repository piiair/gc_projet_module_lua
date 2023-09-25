local tank = {}

local SettingsMod = require("settings")
local MathMod = require("utilMath")
local EnemyMod = require("enemyModule")
local MiningMod = require("miningModule")
local ExplodeMod = require("explodeModule")

tank.RATES_SHOTS = {}
tank.RATES_SHOTS[1] = 0.5
tank.RATES_SHOTS[2] = 3

--Fixe
tank.imageTank = love.graphics.newImage("images/tank.png")
tank.imageBarrel = love.graphics.newImage("images/barrel.png")
tank.widthTank = tank.imageTank:getWidth()
tank.heightTank = tank.imageTank:getHeight()
tank.widthBarrel = tank.imageBarrel:getWidth()
tank.heightBarrel = tank.imageBarrel:getHeight()

--Variable 
tank.isDead = nil
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
  tank.timerShot = 0
  tank.score = 0
  tank.engineIsOn = false
  tank.gameOver = false
  tank.isDead = false
end

local function resetPosIfCollide(pIsCollide, pX, pY)
  if pIsCollide then
    tank.x = pX
    tank.y = pY
  end
end

local function VerifyCollideWithEntities(pOldPosX, pOldPosY)
  --Collision avec les bords
  if tank.x < 0 + (tank.widthTank / 2) then
    tank.x = 0 + (tank.widthTank / 2)
  elseif tank.x > SettingsMod.screenW - (tank.widthTank / 2) then
    tank.x = SettingsMod.screenW - (tank.widthTank / 2)
  end

  if tank.y < 0 + (tank.heightTank / 2) then
    tank.y = 0 + (tank.heightTank / 2)
  elseif tank.y > SettingsMod.screenH - (tank.heightTank / 2) then
    tank.y = SettingsMod.screenH - (tank.heightTank / 2)
  end

  --Collision avec les autres tank
  for n = 1, #EnemyMod.listEnemies do
    local e = EnemyMod.listEnemies[n]
    local isCollideWithAnEnemy = MathMod.verifyCollideGeneral(
      tank.x, tank.y, tank.widthTank, tank.heightTank,
      e.x, e.y, tank.widthTank, tank.heightTank
    )
    resetPosIfCollide(isCollideWithAnEnemy, pOldPosX, pOldPosY)
  end
  
  --Collision avec les sites de minage
  for n = 1, #MiningMod.listSites do 
    local s = MiningMod.listSites[n]
    local isCollide = MathMod.verifyCollideGeneral(
      tank.x, tank.y, tank.widthTank, tank.heightTank,
      s.x, s.y, MiningMod.mineW, MiningMod.mineH
    )
    resetPosIfCollide(isCollide, pOldPosX, pOldPosY)
  end
end

function tank.hurts(pDammage)
  if tank.isDead == false then
    tank.hp = tank.hp - pDammage
    if tank.hp <= 0 then
      tank.hp = 0
      tank.isDead = true
      ExplodeMod.createMultiExplode(tank.x, tank.y, tank.widthTank, tank.heightTank)
    end
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
  tank.timerShot1 = tank.RATES_SHOTS[1]
  tank.timerShot2 = tank.RATES_SHOTS[2]
  tank.score = 0
  tank.engineIsOn = false
  tank.gameOver = false

  MouseX, MouseY = love.mouse.getPosition()
  tank.isDead = false
end

function tank.update(dt)
  if tank.hp > 0 then
    --tirs du tank
    if tank.timerShot1 > 0 then
      tank.timerShot1 = tank.timerShot1 - dt
    end
    if tank.timerShot2 > 0 then
      tank.timerShot2 = tank.timerShot2 - dt
    end

    --rotation du tank + canon
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
    love.graphics.draw( tank.imageTank, tank.x, tank.y, 
    math.rad(tank.angleTank), 1, 1, tank.widthTank / 2, tank.heightTank / 2)

    --dessin du canon
    love.graphics.draw(tank.imageBarrel, tank.x, tank.y, 
    math.rad(tank.angleBarrel), 1, 1, 5, tank.heightBarrel / 2)
  end
end

return tank
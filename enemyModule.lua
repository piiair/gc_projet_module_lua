local enemyModule = {}

local SettingsMod = require("settings")
local MathMod = require("utilMath")
local GoldMod = require("gold")
local MiningMod = require("miningModule")
local ExplodeModule = require("explodeModule")
local DepositMod = require("deposit")

local LIST_IMG_TANKS = {}
LIST_IMG_TANKS[1] = love.graphics.newImage("images/enemyTank1.png")
LIST_IMG_TANKS[2] = love.graphics.newImage("images/enemyTank2.png")
LIST_IMG_TANKS[3] = love.graphics.newImage("images/enemyTank3.png")
LIST_IMG_TANKS[4] = love.graphics.newImage("images/drone.png")

local LIST_IMG_BARREL = {}
LIST_IMG_BARREL[1] = love.graphics.newImage("images/enemyBarrel1.png")
LIST_IMG_BARREL[2] = love.graphics.newImage("images/enemyBarrel2.png")
LIST_IMG_BARREL[3] = love.graphics.newImage("images/enemyBarrel3.png")

enemyModule.TANK_WIDTH = LIST_IMG_TANKS[1]:getWidth()
enemyModule.TANK_HEIGHT = LIST_IMG_TANKS[1]:getHeight()
enemyModule.BARREL_WIDTH = LIST_IMG_BARREL[1]:getWidth()

local sndExplodeTank = love.audio.newSource("sounds/explodeTank.wav", "static")

local LIST_SPD_ENEMIES = {}
LIST_SPD_ENEMIES[1] = 100
LIST_SPD_ENEMIES[2] = 125
LIST_SPD_ENEMIES[3] = 50
LIST_SPD_ENEMIES[4] = 150

local LIST_HP_ENEMIES = {}
LIST_HP_ENEMIES[1] = 2
LIST_HP_ENEMIES[2] = 4
LIST_HP_ENEMIES[3] = 6
LIST_HP_ENEMIES[4] = 2

local LIST_DIST_DETEC = {}
LIST_DIST_DETEC[1] = 325
LIST_DIST_DETEC[2] = 375
LIST_DIST_DETEC[3] = 725

local LIST_COEF_DIST_SHOOT = {}
LIST_COEF_DIST_SHOOT[1] = 0.75
LIST_COEF_DIST_SHOOT[2] = 0.5
LIST_COEF_DIST_SHOOT[3] = 0.85

local LIST_ANGLE_DETEC = {}
LIST_ANGLE_DETEC[1] = 60
LIST_ANGLE_DETEC[2] = 70
LIST_ANGLE_DETEC[3] = 80

local LIST_TIMER_MOVE = {}
LIST_TIMER_MOVE[1] = 0.5
LIST_TIMER_MOVE[2] = 1
LIST_TIMER_MOVE[3] = 2
LIST_TIMER_MOVE[4] = 0.15

local LIST_TIMER_SHOT = {}
LIST_TIMER_SHOT[1] = 1.25
LIST_TIMER_SHOT[2] = 0.75
LIST_TIMER_SHOT[3] = 3

local LIST_RATE_OF_FIRE = {}
LIST_RATE_OF_FIRE[3] = 0.75

local LIST_MAGAZINE = {}
LIST_MAGAZINE[3] = 3

enemyModule.ENEMIES_PER_LEVEL = {}
enemyModule.ENEMIES_PER_LEVEL[1] = 10

local SPD_ROTA_TANK = 100
local SPD_ROTA_BARREL = 125
local TIMER_MOVE = 0.5
local TIMER_RADAR = 0.25
local TIMER_EXTRACT = 1.25
local TIMER_RUNDOWN = 1
local BASE_HP = 2

enemyModule.FULL_STOCK_ENERGY = 4

--Spawn
local TIMER_SPAWN_TANK_REF = 5
local TIMER_SPAWN_DRONE_REF = 5
local timerSpawn = nil
local timerSpawnDrone = nil

local LIST_SPAWN = {}

--machine à états
local STATE_SPAWN = "spawn"
local STATE_NULL = "null"
local STATE_RADAR = "radar"
local STATE_CHASE = "chase"
local STATE_CHANGEDIR = "chd"
local STATE_MOVE = "move"
local STATE_SHOOT = "shoot"
local STATE_TARGET = "target"
local STATE_MINE = "mine"
local STATE_RUNDOWN = "runDown"

local countEnemy = nil
enemyModule.enemiesStock = nil
enemyModule.listEnemies = nil
enemyModule.listDeadIds = nil
enemyModule.playerVictory = nil
enemyModule.scorePlayer = nil

function enemyModule.reset()
  timerSpawn = nil
  timerSpawnDrone = nil
  countEnemy = nil
  enemyModule.enemiesStock = nil
  enemyModule.listEnemies = nil
  enemyModule.listDeadIds = nil
  enemyModule.playerVictory = nil
  enemyModule.scorePlayer = nil
end

local function loadSpawns()
  local W = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER
  local H = SettingsMod.screenH

  local spawn1 = {}
  spawn1.x = 0
  spawn1.y = H - (H / 4)
  spawn1.angle = 0

  local spawn2 = {}
  spawn2.x = 0
  spawn2.y = H / 4
  spawn2.angle = 0

  local spawn3 = {}
  spawn3.x = W / 3
  spawn3.y = 0
  spawn3.angle = 90

  local spawn4 = {}
  spawn4.x = W - (W / 3)
  spawn4.y = 0
  spawn4.angle = 90

  local spawn5 = {}
  spawn5.x = W
  spawn5.y = H / 4
  spawn5.angle = 180

  local spawn6 = {}
  spawn6.x = W
  spawn6.y = H - (H / 4)
  spawn6.angle = 180

  local spawn7 = {}
  spawn7.x = W - (W / 3)
  spawn7.y = H
  spawn7.angle = 270

  local spawn8 = {}
  spawn8.x = W / 3
  spawn8.y = H
  spawn8.angle = 270

  table.insert(LIST_SPAWN, spawn1)
  table.insert(LIST_SPAWN, spawn2)
  table.insert(LIST_SPAWN, spawn3)
  table.insert(LIST_SPAWN, spawn4)
  table.insert(LIST_SPAWN, spawn5)
  table.insert(LIST_SPAWN, spawn6)
  table.insert(LIST_SPAWN, spawn7)
  table.insert(LIST_SPAWN, spawn8)
end

function enemyModule.load()
  enemyModule.listEnemies = {}
  enemyModule.listDeadIds = {}
  countEnemy = 0
  enemyModule.enemiesStock = enemyModule.ENEMIES_PER_LEVEL[1]
  timerSpawn = 1.5
  timerSpawnDrone = 0
  enemyModule.scorePlayer = 0
  enemyModule.playerVictory = false
  loadSpawns()
  DepositMod.loadDepositSites()
end

local function TargetCloserSpot(pDroneX, pDroneY, pSpotType)
  local iCloser = 1
  local distCloser

  if pSpotType == "mine" then
    for n = 2, #MiningMod.listSites do
      local ref = MiningMod.listSites[iCloser]
      distCloser = MathMod.absoluteDistance(pDroneX, pDroneY, ref.x, ref.y)
      local s = MiningMod.listSites[n]
      local distNew = MathMod.absoluteDistance(pDroneX, pDroneY, s.x, s.y)
      if distNew < distCloser then
        iCloser = n
      end
    end

  elseif pSpotType == "deposit" then
    for n = 2, #DepositMod.LIST_DEPOSIT_SITES do 
      local ref = DepositMod.LIST_DEPOSIT_SITES[iCloser]
      distCloser = MathMod.absoluteDistance(pDroneX, pDroneY, ref.x, ref.y)
      local d = DepositMod.LIST_DEPOSIT_SITES[n]
      local distNew = MathMod.absoluteDistance(pDroneX, pDroneY, d.x, d.y)
      if distNew < distCloser then
        iCloser = n
      end
    end
  end

  return iCloser
end

local function CreateEnemySkeleton(pType)
  local currentSpawn = LIST_SPAWN[math.random(1, 8)]

  local skeleton = {}
  skeleton.id = countEnemy
  skeleton.x = currentSpawn.x
  skeleton.y = currentSpawn.y
  skeleton.angleBody = currentSpawn.angle
  skeleton.type = pType
  skeleton.state = STATE_SPAWN
  skeleton.hpMax = LIST_HP_ENEMIES[pType]
  skeleton.hp = skeleton.hpMax
  skeleton.newDirectionAngle = 0
  skeleton.newRotationTimer = 0
  skeleton.timerMove = TIMER_MOVE
  skeleton.timerRadar = TIMER_RADAR
  skeleton.imgBody = LIST_IMG_TANKS[pType]
  skeleton.w = skeleton.imgBody:getWidth()
  skeleton.h = skeleton.imgBody:getHeight()
  return skeleton
end

local function CreateEnemy(pType)
  countEnemy = countEnemy + 1
  local e = CreateEnemySkeleton(pType)
  
  if e.type >= 1 and e.type <= 3 then
    e.angleBarrel = e.angleBody
    e.counterCollide = 0
    e.timerShot = 0
    e.isShooting = false
    if e.type == 1 or e.type == 2 then
      e.typeExplode = "simple"
    elseif e.type == 3 then
      e.magazine = 3
      e.rateOfFire = LIST_RATE_OF_FIRE[e.type]
      e.typeExplode = "missile"
    end
  elseif e.type == 4 then
    e.isEmpty = true
    e.timerExtract = TIMER_EXTRACT
    e.timerRunDown = TIMER_RUNDOWN
    e.stockEnergy = 0
    e.isTaskFinished = false
  end

  table.insert(enemyModule.listEnemies, e)
end

local function PlayerIsInDetectionArea(pEnemyX, pEnemyY, pEnemyAngle, pEnemyType, pPlayerX, pPlayerY)
  local isInArea = false
  local distPlayer = MathMod.absoluteDistance(pEnemyX, pEnemyY, pPlayerX, pPlayerY)

  -- On vérifie d'abord la distance
  if distPlayer <= LIST_DIST_DETEC[pEnemyType] then
    --On vérifie ensuite l'angle
    local angleAtPlayer = MathMod.getAngle(pEnemyX, pEnemyY, pPlayerX, pPlayerY, "degAbsolute")

    if
      angleAtPlayer >= pEnemyAngle - LIST_ANGLE_DETEC[pEnemyType] and
        angleAtPlayer <= pEnemyAngle + LIST_ANGLE_DETEC[pEnemyType]
     then
      isInArea = true
    end
  end

  return isInArea
end

local function VerifyCollideWall(pEnemyX, pEnemyY)
  if pEnemyX < 0 + (enemyModule.TANK_WIDTH / 2) or 
  pEnemyX > SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER - (enemyModule.TANK_WIDTH / 2) or
  pEnemyY < 0 + (enemyModule.TANK_HEIGHT / 2) or
  pEnemyY > SettingsMod.screenH - (enemyModule.TANK_HEIGHT / 2)
   then
    return true
  else
    return false
  end
end

local function VerifyCollideWidthEntities(pEnemyX, pEnemyY, pEnemyIndex)
  local isCollide = false

  for n = 1, #enemyModule.listEnemies do
    local e = enemyModule.listEnemies[n]
    if pEnemyIndex ~= n then
      isCollide = MathMod.verifyCollideGeneral(
        pEnemyX, pEnemyY, enemyModule.TANK_WIDTH, enemyModule.TANK_HEIGHT, 
        e.x, e.y, enemyModule.TANK_WIDTH, enemyModule.TANK_HEIGHT)
    end
    if isCollide then
      return true
    end
  end

  for n = 1, #MiningMod.listSites do 
    local s = MiningMod.listSites[n]
    isCollide = MathMod.verifyCollideGeneral(
      pEnemyX, pEnemyY, enemyModule.TANK_WIDTH, enemyModule.TANK_HEIGHT,
      s.x, s.y, MiningMod.mineW, MiningMod.mineH
    )

    if isCollide then
      return true
    end
  end

  return isCollide
end

local function RotateElement(pEnemyAngleElement, pAngleAtObject, pSpeed, dt)
  local diffAngle = math.abs(pEnemyAngleElement - pAngleAtObject)
  local newAngle

  if pEnemyAngleElement > pAngleAtObject then
    if diffAngle < 180 then
      newAngle = pEnemyAngleElement - pSpeed * dt
    else
      newAngle = pEnemyAngleElement + pSpeed * dt
    end
  elseif pEnemyAngleElement < pAngleAtObject then
    if diffAngle < 180 then
      newAngle = pEnemyAngleElement + pSpeed * dt
    else
      newAngle = pEnemyAngleElement - pSpeed * dt
    end
  end

  return newAngle
end

local function ControllAngleElement(pAngleElement)
  local newAngle = pAngleElement
  if pAngleElement > 360 then
    newAngle = pAngleElement - 360
  elseif pAngleElement < 0 then
    newAngle = pAngleElement + 360
  end
  return newAngle
end

local function CalculNewPosByAxe(pPos, pAngle, pSpeed, pCosOrSin, dt)
  local newPos
  local v
  if pCosOrSin == "cos" then
    v = math.cos(math.rad(pAngle)) * pSpeed * dt
  elseif pCosOrSin == "sin" then
    v = math.sin(math.rad(pAngle)) * pSpeed * dt
  end
  newPos = pPos + v
  return newPos
end

local function DeleteEnemy(pN, pId)
  table.insert(enemyModule.listDeadIds, pId)
  table.remove(enemyModule.listEnemies, pN)
end

--Machine à états des ennemis
local function UpdateEnemyByState(pIndex, dt, pPlayerX, pPlayerY)
  local e = enemyModule.listEnemies[pIndex]
  local oldPosX = e.x
  local oldPosY = e.y

  --Machine à états tank
  if e.type < 4 then 
    if e.state == STATE_SPAWN then
      local oldPosX = e.x
      local oldPosY = e.y
      e.timerMove = e.timerMove - dt
      e.x = CalculNewPosByAxe(e.x, e.angleBody, LIST_SPD_ENEMIES[e.type] , "cos", dt)
      e.y = CalculNewPosByAxe(e.y, e.angleBody, LIST_SPD_ENEMIES[e.type] , "sin", dt)

      local isCollide = VerifyCollideWidthEntities(e.x, e.y, pIndex)

      if isCollide then
        e.x = oldPosX
        e.y = oldPosY
        e.state = STATE_NULL
      else
        if e.timerMove <= 0 then
          e.newDirectionAngle = math.random(20, 40)
          e.state = STATE_NULL
        end
      end
    elseif e.state == STATE_NULL then
      e.timerMove = TIMER_MOVE
      e.timerRadar = TIMER_RADAR
      e.timerShot = LIST_TIMER_SHOT[e.type]
      e.angleBarrel = e.angleBody

      if e.counterCollide == 2 then
        e.counterCollide = 0
        e.newDirectionAngle = 180
      else
        e.newDirectionAngle = math.random(30, 50)
        local CoinFlip = math.random(1, 10)
        if CoinFlip <= 5 then
          e.newDirectionAngle = -e.newDirectionAngle
        end
      end
      e.newRotationTimer = math.abs(e.newDirectionAngle) / SPD_ROTA_TANK
      e.state = STATE_CHANGEDIR
    elseif e.state == STATE_RADAR then
      e.timerRadar = e.timerRadar - dt

      --Quand timer à 0 on tire si joueur sinon état null pour un nouveau cycle
      if e.timerRadar <= 0 then
        local playerIsInArea = PlayerIsInDetectionArea(e.x, e.y, e.angleBody, e.type, pPlayerX, pPlayerY)
        --Si joueur détecté alors on passe à la procédure de tir
        if playerIsInArea then
          e.state = STATE_CHASE
        else
          e.newDirectionAngle = math.random(20, 40)
          e.state = STATE_NULL
        end
      end
    elseif e.state == STATE_CHASE then
      local distPlayer = MathMod.absoluteDistance(e.x, e.y, pPlayerX, pPlayerY)
      local angPlayer = MathMod.getAngle(e.x, e.y, pPlayerX, pPlayerY, "degAbsolute")

      if e.timerShot > 0 then
        e.timerShot = e.timerShot - dt
      end

      --Si le joueur est dans la zone de détection
      if distPlayer <= LIST_DIST_DETEC[e.type] then
        --Le tank et le canon se tourne vers le joueur
        e.angleBarrel = RotateElement(e.angleBarrel, angPlayer, SPD_ROTA_BARREL, dt)
        e.angleBody = RotateElement(e.angleBody, angPlayer, SPD_ROTA_TANK, dt)

        --On remet l'angle en 0 et 360°
        e.angleBarrel = ControllAngleElement(e.angleBarrel)
        e.angleBody = ControllAngleElement(e.angleBody)

        --Le tank suit le joueur s'il s'éloigne
        if distPlayer >= LIST_DIST_DETEC[e.type] * LIST_COEF_DIST_SHOOT[e.type] then
          e.x = CalculNewPosByAxe(e.x, e.angleBody, LIST_SPD_ENEMIES[e.type] , "cos", dt)
          e.y = CalculNewPosByAxe(e.y, e.angleBody, LIST_SPD_ENEMIES[e.type] , "sin", dt)
        end

        --On vérifie la collision avec les bords et les autres ennemis
        local isOutOfMap = VerifyCollideWall(e.x, e.y)
        local isCollideWithOtherEnemy = VerifyCollideWidthEntities(e.x, e.y, pIndex)

        if isOutOfMap or isCollideWithOtherEnemy then
          e.x = oldPosX
          e.y = oldPosY
          e.counterCollide = e.counterCollide + 1
          e.state = STATE_NULL
        else
          --Si le joueur est proche et que le canon pointe vers lui on tire
          local newDistPlayer = MathMod.absoluteDistance(e.x, e.y, pPlayerX, pPlayerY)
          local diffAngleBarrelAndPlayer = math.abs(e.angleBarrel - angPlayer)

          if newDistPlayer <= LIST_DIST_DETEC[e.type] * LIST_COEF_DIST_SHOOT[e.type] and e.timerShot <= 0 then
            e.state = STATE_SHOOT
            if e.type == 3 then
              local CoinFlip = math.random(0, 1)
              if CoinFlip == 0 then
                e.directionShot = LIST_ANGLE_DETEC[e.type] / 5
              else
                e.directionShot = -LIST_ANGLE_DETEC[e.type] / 5
              end
            end
          end
        end
      else
        e.state = STATE_NULL
      end
    elseif e.state == STATE_CHANGEDIR then
      e.newRotationTimer = e.newRotationTimer - dt

      --Le tank se tourne vers sa nouvelle direction
      local rotation = SPD_ROTA_TANK * (e.newDirectionAngle / math.abs(e.newDirectionAngle))
      e.angleBody = e.angleBody + rotation * dt
      e.angleBody = ControllAngleElement(e.angleBody)
      e.angleBarrel = e.angleBody

      if e.newRotationTimer <= 0 then
        e.state = STATE_MOVE
      end
    elseif e.state == STATE_MOVE then
      e.timerMove = e.timerMove - dt
      e.x = CalculNewPosByAxe(e.x, e.angleBody, LIST_SPD_ENEMIES[e.type] , "cos", dt)
      e.y = CalculNewPosByAxe(e.y, e.angleBody, LIST_SPD_ENEMIES[e.type] , "sin", dt)

      local isOutOfMap = VerifyCollideWall(e.x, e.y)
      local isCollideWithOtherEnemy = VerifyCollideWidthEntities(e.x, e.y, pIndex)

      if isOutOfMap or isCollideWithOtherEnemy then
        e.x = oldPosX
        e.y = oldPosY
        e.counterCollide = e.counterCollide + 1
        e.state = STATE_NULL
      else
        if e.timerMove <= 0 then
          e.state = STATE_RADAR
        end
      end
    elseif e.state == STATE_SHOOT then
      if e.type == 1 or e.type == 2 then
        e.isShooting = true
        e.timerShot = LIST_TIMER_SHOT[e.type]
        e.state = STATE_CHASE
      elseif e.type == 3 then
        --Le timer diminue
        e.rateOfFire = e.rateOfFire - dt

        --Le canon tourne pour le prochain tir
        if e.magazine == 3 then
          e.angleBarrel = e.angleBarrel + e.directionShot * dt
        else
          e.angleBarrel = e.angleBarrel - e.directionShot * dt
        end

        --quand le timer est finit le tank tir un missile
        if e.rateOfFire <= 0 then
          e.isShooting = true
          e.magazine = e.magazine - 1
          e.rateOfFire = LIST_RATE_OF_FIRE[e.type]
        end

        --Quand le chargeur est vide on change de mode
        if e.magazine == 0 then
          e.magazine = 3
          e.timerShot = LIST_TIMER_SHOT[e.type]
          e.state = STATE_CHASE
        end
      end
    end
  elseif e.type == 4 then
    if e.state == STATE_SPAWN then
      e.x = CalculNewPosByAxe(e.x, e.angleBody, LIST_SPD_ENEMIES[e.type] , "cos", dt)
      e.y = CalculNewPosByAxe(e.y, e.angleBody, LIST_SPD_ENEMIES[e.type] , "sin", dt)

      e.timerMove = e.timerMove - dt
      if e.timerMove <= 0 then
        e.state = STATE_TARGET
      end
    elseif e.state == STATE_TARGET then
      --Nouvelle cible
      if e.isEmpty then
      --Le drone cible une mine
        local idMine = TargetCloserSpot(e.x, e.y, "mine")
        e.target = {
          id = idMine,
          x = MiningMod.listSites[idMine].x,
          y = MiningMod.listSites[idMine].y
        }
      else
      --Le drone cible un depot
        local idDeposit = TargetCloserSpot(e.x, e.y, "deposit")
        e.target = {
          id = idDeposit,
          x = DepositMod.LIST_DEPOSIT_SITES[idDeposit].x,
          y = DepositMod.LIST_DEPOSIT_SITES[idDeposit].y
        }
      end

      --Nouvel angle
      e.state = STATE_MOVE
    
    elseif e.state == STATE_MOVE then
      --rotation du drone
      local angTarget = MathMod.getAngle(e.x, e.y, e.target.x, e.target.y, "degAbsolute")
      e.angleBody = RotateElement(e.angleBody, angTarget, SPD_ROTA_TANK, dt)
      e.angleBody = ControllAngleElement(e.angleBody)

      --déplacement du drone
      if math.abs(angTarget - e.angleBody) <= 5 then
        e.x = CalculNewPosByAxe(e.x, e.angleBody, LIST_SPD_ENEMIES[e.type] , "cos", dt)
        e.y = CalculNewPosByAxe(e.y, e.angleBody, LIST_SPD_ENEMIES[e.type] , "sin", dt)
        
        if e.isEmpty then
          --On vérifie qu'on est sur la mine
          local t = MiningMod.listSites[e.target.id]
          local isCollideTarget = MathMod.verifyCollideGeneral(
            e.x, e.y, e.w / 2, e.h / 2,
            t.x, t.y, MiningMod.mineW, MiningMod.mineH
          )
          if isCollideTarget then
            e.isEmpty = false
            e.state = STATE_MINE
          end
        else
          --On vérifie qu'on est sur le dépot
          local t = DepositMod.LIST_DEPOSIT_SITES[e.target.id]
          local size = DepositMod.DEPOSIT_SIZE
          local isCollideTarget = MathMod.verifyCollideGeneral(
            e.x, e.y, e.w / 2, e.h / 2,
            t.x, t.y, DepositMod.DEPOSIT_SIZE, DepositMod.DEPOSIT_SIZE
          )
          if isCollideTarget then
            --Si oui on décharge le drone
            e.state = STATE_RUNDOWN
          end
        end
      end
    elseif e.state == STATE_MINE then
      e.timerExtract = e.timerExtract - dt
      if e.timerExtract <= 0 and e.stockEnergy < enemyModule.FULL_STOCK_ENERGY then
        e.timerExtract = TIMER_EXTRACT
        e.stockEnergy = e.stockEnergy + 1
      end

      --Une fois plein on change de mode
      if e.stockEnergy == enemyModule.FULL_STOCK_ENERGY then
        e.isEmpty = false
        e.state = STATE_TARGET
      end
    elseif e.state == STATE_RUNDOWN then
      e.timerRunDown = e.timerRunDown - dt 
      if e.timerRunDown <= 0 and e.stockEnergy > 0 then
        e.timerRunDown = TIMER_RUNDOWN
        e.stockEnergy = e.stockEnergy - 1
      end

      if e.stockEnergy == 0 then
        e.isTaskFinished = true
      end
    end
  end
end

function enemyModule.update(dt, pPlayer)
  --spawn des ennemis
  if enemyModule.enemiesStock > 0 then
    timerSpawn = timerSpawn - dt
    if timerSpawn < 0 then
      timerSpawn = TIMER_SPAWN_TANK_REF
      CreateEnemy(math.random(1, 3))
      enemyModule.enemiesStock = enemyModule.enemiesStock - 1
    end
  end

  timerSpawnDrone = timerSpawnDrone - dt
  if timerSpawnDrone <= 0 then
    timerSpawnDrone = TIMER_SPAWN_DRONE_REF
    CreateEnemy(4)
  end

  --update des ennemis
  for n = 1, #enemyModule.listEnemies do
    UpdateEnemyByState(n, dt, pPlayer.x, pPlayer.y)
  end

  --Mort/Suppression d'un ennemi
  for n = #enemyModule.listEnemies, 1, -1 do
    --On supprime les ennemis morts 
    local e = enemyModule.listEnemies[n]
    if e.hp <= 0 then
      enemyModule.scorePlayer = enemyModule.scorePlayer + 1
      GoldMod.genereGold(e)
      ExplodeModule.createMultiExplode(e.x, e.y, enemyModule.TANK_WIDTH, enemyModule.TANK_HEIGHT)
      sndExplodeTank:stop()
      sndExplodeTank:play()
      DeleteEnemy(n, e.id)
    end

    --On supprime les drone qui ont fini leur mission
    if e.type == 4 and e.isTaskFinished then
      enemyModule.enemiesStock = enemyModule.enemiesStock + 1
      DeleteEnemy(n, e.id)
    end
  end

  --Victoire du joueur
  if enemyModule.enemiesStock == 0 and #enemyModule.listEnemies == 0 and #ExplodeModule.listExplodes == 0 then
    enemyModule.playerVictory = true
  end
end

function enemyModule.draw()
  for n = 1, #enemyModule.listEnemies do
    local e = enemyModule.listEnemies[n]

    if e.type < 4 then
      local imageBarrel = LIST_IMG_BARREL[e.type]
      love.graphics.draw(
        e.imgBody,
        e.x,
        e.y,
        math.rad(e.angleBody),
        1,
        1,
        e.w / 2,
        e.h / 2
      )
      love.graphics.draw(
        imageBarrel,
        e.x,
        e.y,
        math.rad(e.angleBarrel),
        1,
        1,
        5,
        imageBarrel:getHeight() / 2
      )
    else
      love.graphics.draw(
        e.imgBody,
        e.x,
        e.y,
        math.rad(e.angleBody),
        1,
        1,
        e.w / 2,
        e.h / 2
      )
    end

    --love.graphics.print(e.state, e.x - 35, e.y - 40)
  end
end

return enemyModule
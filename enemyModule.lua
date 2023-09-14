local enemyModule = {}

local ShotModule = require("shotModule")
local MathModule = require("utilMath")

local LIST_IMG_TANKS = {}
LIST_IMG_TANKS[1] = love.graphics.newImage("images/enemyTank1.png")
LIST_IMG_TANKS[2] = love.graphics.newImage("images/enemyTank2.png")
LIST_IMG_TANKS[3] = love.graphics.newImage("images/enemyTank3.png")

local LIST_IMG_BARREL = {}
LIST_IMG_BARREL[1] = love.graphics.newImage("images/enemyBarrel1.png")
LIST_IMG_BARREL[2] = love.graphics.newImage("images/enemyBarrel2.png")
LIST_IMG_BARREL[3] = love.graphics.newImage("images/enemyBarrel3.png")

local LIST_BULLETS_SPEED = {}
LIST_BULLETS_SPEED[1] = 600
LIST_BULLETS_SPEED[2] = 450
LIST_BULLETS_SPEED[3] = 375

local LIST_DIST_DETECTION = {}
LIST_DIST_DETECTION[1] = 400
LIST_DIST_DETECTION[2] = 400
LIST_DIST_DETECTION[3] = 700

local LIST_ANGLE_DETECTION = {}
LIST_ANGLE_DETECTION[1] = 30
LIST_ANGLE_DETECTION[1] = 25
LIST_ANGLE_DETECTION[1] = 50

local WIDTH, HEIGHT
local ANGLE_DETECTION = 30
local SPD_ENEMY = 125
local SPD_ROTA_TANK = 100
local SPD_ROTA_BARREL = 125
local timerSpawn = 1.5
local TIMER_MOVE = 1.25
local TIMER_RADAR = 0.5
local TIMER_SHOT = 0.5
local MAGAZINE_SIZE = 3
local TANK_WIDTH = LIST_IMG_TANKS[1]:getWidth()
local TANK_HEIGHT = LIST_IMG_TANKS[1]:getHeight()
local BARREL_WIDTH = LIST_IMG_BARREL[1]:getWidth()
local BARREL_HEIGHT = LIST_IMG_BARREL[1]:getHeight()
local LIST_SPAWN = {}

local listEnemies = nil

local STATE_SPAWN = "spawn"
local STATE_NULL = "null"
local STATE_RADAR = "radar"
local STATE_CHASE = "chase"
local STATE_CHANGEDIR = "chd"
local STATE_MOVE = "move"
local STATE_SHOOT = "shoot"

function loadSpawns()
  local spawn1 = {}
  spawn1.x = 0
  spawn1.y = HEIGHT - (HEIGHT / 4)
  spawn1.angle = 0
  
  local spawn2 = {}
  spawn2.x = 0
  spawn2.y = HEIGHT / 4
  spawn2.angle = 0
  
  local spawn3 = {}
  spawn3.x = WIDTH / 3
  spawn3.y = 0
  spawn3.angle = 90
  
  local spawn4 = {}
  spawn4.x = WIDTH - (WIDTH / 3)
  spawn4.y = 0
  spawn4.angle = 90
  
  local spawn5 = {}
  spawn5.x = WIDTH
  spawn5.y = HEIGHT / 4
  spawn5.angle = 180
  
  local spawn6 = {}
  spawn6.x = WIDTH
  spawn6.y = HEIGHT - (HEIGHT / 4)
  spawn6.angle = 180
  
  local spawn7 = {}
  spawn7.x = WIDTH - (WIDTH / 3)
  spawn7.y = HEIGHT
  spawn7.angle = 270
  
  local spawn8 = {}
  spawn8.x = WIDTH / 3
  spawn8.y = HEIGHT
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

function enemyModule.loadModule()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
  listEnemies = {}
  loadSpawns()
end

function CreateEnemy(pType)
  local currentSpawn = LIST_SPAWN[math.random(1, 8)]
  local newEnemy = {}
  newEnemy.x = currentSpawn.x 
  newEnemy.y = currentSpawn.y 
  newEnemy.angleTank = currentSpawn.angle
  newEnemy.angleBarrel = currentSpawn.angle
  newEnemy.state = "spawn"
  newEnemy.type = pType
  newEnemy.timerMove = TIMER_MOVE
  newEnemy.timerRadar = TIMER_RADAR
  newEnemy.timerShot = 0
  newEnemy.newDirectionAngle = 0
  newEnemy.newRotationTimer = 0
  newEnemy.collideWithLimits = false
  newEnemy.hp = 1
  table.insert(listEnemies, newEnemy)
end

function PlayerIsInDetectionArea(pEnemyX, pEnemyY, pEnemyAngle, pEnemyType, pPlayerX, pPlayerY)
  local isInArea = false 
  local distPlayer = MathModule.absoluteDistance(pEnemyX, pEnemyY, pPlayerX, pPlayerY)

  -- On vérifie d'abord la distance
  if distPlayer <= LIST_DIST_DETECTION[pEnemyType] then
    --On vérifie ensuite l'angle
    local angleAtPlayer = MathModule.getAngle(pEnemyX, pEnemyY, pPlayerX, pPlayerY, "degAbsolute")

    if angleAtPlayer >= pEnemyAngle - ANGLE_DETECTION and 
    angleAtPlayer <= pEnemyAngle + ANGLE_DETECTION then
      isInArea = true
    end

  end

  return isInArea
end

function VerifyCollideWall(pEnemyX, pEnemyY)
  if pEnemyX < 0 + (TANK_WIDTH / 2) or 
  pEnemyX > WIDTH - (TANK_WIDTH / 2) or
  pEnemyY < 0 + (TANK_HEIGHT / 2) or
  pEnemyY > HEIGHT - (TANK_HEIGHT / 2) then
    return true 
  else 
    return false
  end
end

function RotateElement(pEnemyAngleElement, pAngleAtPlayer, pSpeed, dt)
  local diffAngle = math.abs(pEnemyAngleElement - pAngleAtPlayer)
  local newAngle

  if pEnemyAngleElement > pAngleAtPlayer then
    if diffAngle < 180 then
      newAngle = pEnemyAngleElement - pSpeed * dt
    else
      newAngle = pEnemyAngleElement + pSpeed * dt
    end
  elseif pEnemyAngleElement < pAngleAtPlayer then
    if diffAngle < 180 then
      newAngle = pEnemyAngleElement + pSpeed * dt
    else
      newAngle = pEnemyAngleElement - pSpeed * dt
    end
  end

  return newAngle
end

function ControllAngleElement(pAngleElement)
  local newAngle = pAngleElement
  if pAngleElement > 360 then 
    newAngle = pAngleElement - 360
  elseif pAngleElement < 0 then 
    newAngle = pAngleElement + 360
  end
  return newAngle
end

--Machine à états des ennemis
function UpdateEnemyByState(pIndex, dt, pPlayerX, pPlayerY)
  local enemy = listEnemies[pIndex]

  --Machine à états
  if enemy.state == STATE_SPAWN then
    local vx = math.cos(math.rad(enemy.angleTank)) * SPD_ENEMY * dt
    local vy = math.sin(math.rad(enemy.angleTank)) * SPD_ENEMY * dt
    enemy.x = enemy.x + vx 
    enemy.y = enemy.y + vy
    enemy.timerMove = enemy.timerMove - dt
    if enemy.timerMove <= 0 then
      enemy.state = STATE_RADAR
    end

  elseif enemy.state == STATE_NULL then
    enemy.timerMove = TIMER_MOVE
    enemy.timerRadar = TIMER_RADAR
    enemy.timerShot = TIMER_SHOT
    enemy.angleBarrel = enemy.angleTank
    if enemy.collideWithLimits then
      enemy.collideWithLimits = false
      enemy.newDirectionAngle = 180
    else
      enemy.newDirectionAngle = math.random(20, 40)
      local CoinFlip = math.random(1, 10)
      if CoinFlip <= 5 then
        enemy.newDirectionAngle = -enemy.newDirectionAngle
      end
    end
    
    enemy.newRotationTimer = math.abs(enemy.newDirectionAngle) / SPD_ROTA_TANK
    enemy.state = STATE_CHANGEDIR

  elseif enemy.state == STATE_RADAR then
    enemy.timerRadar = enemy.timerRadar - dt
    
    --Quand timer à 0 on tire si joueur sinon état null pour un nouveau cycle
    if enemy.timerRadar <= 0 then
      local playerIsInArea = PlayerIsInDetectionArea(enemy.x, enemy.y, enemy.angleTank,enemy.type, pPlayerX, pPlayerY)
      --Si joueur détecté alors on passe à la procédure de tir
      if playerIsInArea then
        enemy.state = STATE_CHASE
      else
        enemy.state = STATE_NULL
      end
    end

  elseif enemy.state == STATE_CHASE then
    local distPlayer = MathModule.absoluteDistance(enemy.x, enemy.y, pPlayerX, pPlayerY)
    local angPlayer = MathModule.getAngle(enemy.x, enemy.y, pPlayerX, pPlayerY, "degAbsolute")

    if enemy.timerShot > 0 then
      enemy.timerShot = enemy.timerShot - dt
    end

    --Si le joueur est dans la zone de détection
    if distPlayer <= LIST_DIST_DETECTION[enemy.type] then

      --Le tank et le canon se tourne vers le joueur
      enemy.angleBarrel = RotateElement(enemy.angleBarrel, angPlayer, SPD_ROTA_BARREL, dt)
      enemy.angleTank = RotateElement(enemy.angleTank, angPlayer, SPD_ROTA_TANK, dt)

      --On remet l'angle en 0 et 360°
      enemy.angleBarrel = ControllAngleElement(enemy.angleBarrel)
      enemy.angleTank = ControllAngleElement(enemy.angleTank)

      if enemy.type == 1 or enemy.type == 2 then
        --Le tank suit le joueur
        local oldPosX = enemy.x
        local oldPosY = enemy.y
        local vx = SPD_ENEMY * math.cos(math.rad(enemy.angleTank))
        local vy = SPD_ENEMY * math.sin(math.rad(enemy.angleTank))
        enemy.x = enemy.x + vx * dt
        enemy.y = enemy.y + vy * dt
      end

      --On vérifie la collision avec les bords
      local isOutOfMap = VerifyCollideWall(enemy.x, enemy.y)
      if isOutOfMap then
        enemy.x = oldPosX
        enemy.y = oldPosY
        enemy.collideWithLimits = true
        enemy.state = STATE_NULL
      end

      --Si le joueur est proche on tire et que le canon point vers lui on tire
      local newDistPlayer = MathModule.absoluteDistance(enemy.x, enemy.y, pPlayerX, pPlayerY)

      local diffAngleBarrelAndPlayer = math.abs(enemy.angleBarrel - angPlayer)
      if newDistPlayer <= LIST_DIST_DETECTION[enemy.type] * 0.75 and diffAngleBarrelAndPlayer < 10 and enemy.timerShot <= 0 then
        enemy.state = STATE_SHOOT
      end
    else
      enemy.state = STATE_NULL
    end

  elseif enemy.state == STATE_CHANGEDIR then
    enemy.newRotationTimer = enemy.newRotationTimer - dt

    --Le tank se tourne vers sa nouvelle direction
    local rotation = SPD_ROTA_TANK * (enemy.newDirectionAngle / math.abs(enemy.newDirectionAngle))
    enemy.angleTank = enemy.angleTank + rotation * dt
    enemy.angleTank = ControllAngleElement(enemy.angleTank)
    enemy.angleBarrel = enemy.angleTank

    if enemy.newRotationTimer <= 0 then
      enemy.state = STATE_MOVE
    end
  
  elseif enemy.state == STATE_MOVE then
    local oldPosX = enemy.x
    local oldPosY = enemy.y

    enemy.timerMove = enemy.timerMove - dt
    local vx = SPD_ENEMY * math.cos(math.rad(enemy.angleTank))
    local vy = SPD_ENEMY * math.sin(math.rad(enemy.angleTank))
    enemy.x = enemy.x + vx * dt
    enemy.y = enemy.y + vy * dt

    local isOutOfMap = VerifyCollideWall(enemy.x, enemy.y)

    if isOutOfMap then
      enemy.x = oldPosX
      enemy.y = oldPosY
      enemy.collideWithLimits = true
      enemy.state = STATE_NULL
    end

    if enemy.timerMove <= 0 then
      enemy.state = STATE_RADAR
    end
  elseif enemy.state == STATE_SHOOT then
    local x = enemy.x + math.cos(math.rad(enemy.angleBarrel)) * BARREL_WIDTH
    local y = enemy.y + math.sin(math.rad(enemy.angleBarrel)) * BARREL_WIDTH
    ShotModule.Shoot(x, y, enemy.angleBarrel, LIST_BULLETS_SPEED[enemy.type], enemy.type, "enemy")
    enemy.timerShot = TIMER_SHOT
    enemy.state = STATE_CHASE
  end
end

function enemyModule.updateEnemies(dt, pPlayerX, pPlayerY)
  timerSpawn = timerSpawn - dt 
  if timerSpawn < 0 then
    timerSpawn = 200
    CreateEnemy(math.random(1, 3))
  end

  if #listEnemies > 0 then
    for n = 1, #listEnemies do
      UpdateEnemyByState(n, dt, pPlayerX, pPlayerY)
    end
  end

  --collision avec les tirs du joueur
  if #ShotModule.listShots > 0 and #listEnemies > 0 then
    --Pour chaque enemy
    for n = 1, #listEnemies do
      local e = listEnemies[n]
      --Pour chaque tirs
      for n = 1, #ShotModule.listShots do
        local s = ShotModule.listShots[n]
        --Si le tir provient du joueur
        if s.team == "ally" then
          --Si le tir touche
          if s.x >= e.x - (TANK_WIDTH/2) - (s.image:getWidth()/2) and
          s.x <= e.x + (TANK_WIDTH/2) + (s.image:getWidth()/2) and
          s.y >= e.y - (TANK_HEIGHT/2) - (s.image:getHeight()/2) and
          s.y <= e.y + (TANK_HEIGHT/2) + (s.image:getHeight()/2) then
            s.isDeletable = true
            e.hp = e.hp - 1
          end
        end
      end
    end
  end

  --On supprime les enemis sans vie
  for n = #listEnemies, 1, -1 do
    local e = listEnemies[n]
    if e.hp == 0 then
      table.remove(listEnemies, n)
    end
  end 
end

function enemyModule.drawEnemies()
  if #listEnemies > 0 then
    for n = 1, #listEnemies do 
      local enemy = listEnemies[n]
      local imageTank = LIST_IMG_TANKS[enemy.type]
      local imageBarrel = LIST_IMG_BARREL[enemy.type]

      love.graphics.draw(imageTank, enemy.x, enemy.y,
        math.rad(enemy.angleTank), 1, 1, imageTank:getWidth()/2, imageTank:getHeight()/2)
      love.graphics.draw(imageBarrel, enemy.x, enemy.y,
        math.rad(enemy.angleBarrel), 1, 1, 5, imageBarrel:getHeight()/2)

      love.graphics.print(enemy.state, enemy.x - 35, enemy.y - 40)
    end
  end
end

return enemyModule



















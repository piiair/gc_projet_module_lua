local enemyModule = {}

local ShotModule = require("shotModule")
local MathModule = require("utilMath")

local LIST_IMG_TANKS = {}
LIST_IMG_TANKS[1] = love.graphics.newImage("images/enemyTank1.png")
LIST_IMG_TANKS[2] = love.graphics.newImage("images/enemyTank2.png")

local LIST_IMG_BARREL = {}
LIST_IMG_BARREL[1] = love.graphics.newImage("images/enemyBarrel1.png")
LIST_IMG_BARREL[2] = love.graphics.newImage("images/enemyBarrel2.png")

local WIDTH, HEIGHT
local DIST_DETECTION = 250
local ANGLE_DETECTION = 30
local SPEED_ENEMY = 125
local SPEED_ROTATION = 40
local TIMER_SPAWN = 1.5
local TIMER_MOVE = 1.25
local TIMER_RADAR = 1.5
local TIMER_SHOT = 0.5
local MAGAZINE_SIZE = 3
local TANK_WIDTH = LIST_IMG_TANKS[1]:getWidth()
local TANK_HEIGHT = LIST_IMG_TANKS[1]:getHeight()

local LIST_BULLETS_SPEED = {}
LIST_BULLETS_SPEED[1] = 400
LIST_BULLETS_SPEED[2] = 250


local listEnemies = nil
local listSpawns = {}

local STATE_SPAWN = "spawn"
local STATE_NULL = "null"
local STATE_CHANGEDIR = "chd"
local STATE_MOVE = "move"
local STATE_RADAR = "radar"
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

  table.insert(listSpawns, spawn1)
  table.insert(listSpawns, spawn2)
  table.insert(listSpawns, spawn3)
  table.insert(listSpawns, spawn4)
  table.insert(listSpawns, spawn5)
  table.insert(listSpawns, spawn6)
  table.insert(listSpawns, spawn7)
  table.insert(listSpawns, spawn8)
end

function enemyModule.loadModule()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
  listEnemies = {}
  loadSpawns()
end

function CreateEnemy(pType)
  local currentSpawn = listSpawns[math.random(1, 8)]
  local newEnemy = {}
  newEnemy.x = currentSpawn.x 
  newEnemy.y = currentSpawn.y 
  newEnemy.angleTank = currentSpawn.angle
  newEnemy.angleBarrel = currentSpawn.angle
  newEnemy.state = "spawn"
  newEnemy.type = pType
  newEnemy.timerMove = TIMER_MOVE
  newEnemy.timerRadar = TIMER_RADAR
  newEnemy.timerShot = TIMER_SHOT
  newEnemy.newDirectionAngle = 0
  newEnemy.newRotationTimer = 0
  newEnemy.collideWithLimits = false
  table.insert(listEnemies, newEnemy)
end

function PlayerTankIsInDetectionArea(pEnemyX, pEnemyY, pEnemyAngle, pPlayerX, pPlayerY)
  local isInArea = false 
  local distanceAtPlayer = MathModule.absoluteDistance(pEnemyX, pEnemyY, pPlayerX, pPlayerY)

  -- On vérifie d'abord la distance
  if distanceAtPlayer <= DIST_DETECTION then
    --On vérifie ensuite l'angle
    local angleAtPlayer = MathModule.getAngle(pEnemyX, pEnemyY, pPlayerX, pPlayerY, "degree")
    if angleAtPlayer >= pEnemyAngle - ANGLE_DETECTION and angleAtPlayer <= pEnemyAngle + ANGLE_DETECTION then
      isInArea = true
    end
  end

  return isInArea
end

--Machine à états des ennemis
function updateEnemyByState(pIndex, dt, pPlayerX, pPlayerY)
  local enemy = listEnemies[pIndex]

  if enemy.state == STATE_SPAWN then
    local vx = math.cos(math.rad(enemy.angleTank)) * SPEED_ENEMY * dt
    local vy = math.sin(math.rad(enemy.angleTank)) * SPEED_ENEMY * dt
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
    if enemy.collideWithLimits == true then
      enemy.newDirectionAngle = 180
    else
      enemy.newDirectionAngle = math.random(20, 40)

      local CoinFlip = math.random(1, 10)
      if CoinFlip <= 5 then
        enemy.newDirectionAngle = -enemy.newDirectionAngle
      end
    end
    
    enemy.newRotationTimer = math.abs(enemy.newDirectionAngle) / SPEED_ROTATION
    enemy.state = STATE_CHANGEDIR

  elseif enemy.state == STATE_RADAR then

    enemy.timerRadar = enemy.timerRadar - dt
    
    --Quand timer à 0 on tire si joueur sinon état null pour un nouveau cycle
    if enemy.timerRadar <= 0 then
      local playerIsInArea = PlayerTankIsInDetectionArea(enemy.x, enemy.y, enemy.angleTank, pPlayerX, pPlayerY)
      --Si joueur détecté alors on passe à la procédure de tir
      if playerIsInArea then
        enemy.shotsRemaining = MAGAZINE_SIZE
        enemy.state = STATE_SHOOT
      else
        enemy.state = STATE_NULL
      end
    end

  elseif enemy.state == STATE_CHANGEDIR then
    enemy.newRotationTimer = enemy.newRotationTimer - dt
    local rotation = SPEED_ROTATION * (enemy.newDirectionAngle / math.abs(enemy.newDirectionAngle))
    enemy.angleTank = enemy.angleTank + rotation * dt
    enemy.angleBarrel = enemy.angleTank

    if enemy.newRotationTimer <= 0 then
      enemy.state = STATE_MOVE
    end
  elseif enemy.state == STATE_MOVE then
    local oldPosX = enemy.x
    local oldPosY = enemy.y

    enemy.timerMove = enemy.timerMove - dt
    local vx = SPEED_ENEMY * math.cos(math.rad(enemy.angleTank))
    local vy = SPEED_ENEMY * math.sin(math.rad(enemy.angleTank))
    enemy.x = enemy.x + vx * dt
    enemy.y = enemy.y + vy * dt

    local isOut = false
    if enemy.x < 0 + (TANK_WIDTH / 2) then
      isOut = true
    elseif enemy.x > WIDTH - (TANK_WIDTH / 2) then
      isOut = true
    elseif enemy.y < 0 + (TANK_HEIGHT / 2) then
      isOut = true
    elseif enemy.y > HEIGHT - (TANK_HEIGHT / 2) then
      isOut = true
    end

    if isOut then
      enemy.x = oldPosX
      enemy.y = oldPosY
      enemy.collideWithLimits = true
      enemy.state = STATE_NULL
    end

    if enemy.timerMove <= 0 then
      enemy.state = STATE_RADAR
    end
  elseif enemy.state == STATE_SHOOT then
    enemy.timerShot = enemy.timerShot - dt

    -- tir quand timer à 0
    if enemy.timerShot <= 0 then
      enemy.timerShot = TIMER_SHOT
      if enemy.shotsRemaining > 0 then
        ShotModule.Shoot(enemy.x, enemy.y, enemy.angleBarrel, LIST_BULLETS_SPEED[1], 1, "enemy")
      end
      enemy.shotsRemaining = enemy.shotsRemaining - 1
    end

    --rotation du canon
    if enemy.shotsRemaining == MAGAZINE_SIZE or enemy.shotsRemaining == 0 then
      enemy.angleBarrel = enemy.angleBarrel - (ANGLE_DETECTION / TIMER_SHOT) * dt
    else
      enemy.angleBarrel = enemy.angleBarrel + (ANGLE_DETECTION / TIMER_SHOT) * dt
    end

    --changement d'état quand plus de tirs
    if enemy.shotsRemaining == -1 then
      enemy.state = STATE_NULL
    end
  end

end

function enemyModule.updateEnemies(dt, pPlayerX, pPlayerY)
  TIMER_SPAWN = TIMER_SPAWN - dt 
  if TIMER_SPAWN < 0 then
    TIMER_SPAWN = 2
    CreateEnemy(math.random(1, 2))
  end

  if #listEnemies > 0 then
    for n = 1, #listEnemies do
      updateEnemyByState(n, dt, pPlayerX, pPlayerY)
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



















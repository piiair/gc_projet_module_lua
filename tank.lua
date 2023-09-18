local tank = {}

local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

local LST_BUL_SPD_TANK = {}
LST_BUL_SPD_TANK[1] = 600
LST_BUL_SPD_TANK[2] = 400

local TIMER_SHOT = 0.5

--Fixe
tank.imageTank = love.graphics.newImage("images/tank.png")
tank.imageBarrel = love.graphics.newImage("images/barrel.png")
tank.widthTank = tank.imageTank:getWidth()
tank.heightTank = tank.imageTank:getHeight()
tank.widthBarrel = tank.imageBarrel:getWidth()
tank.heightBarrel = tank.imageBarrel:getHeight()

--Variable 
local isDead = nil
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
  
  isDead = false
end

function tank.load()
  tank.x = WIDTH / 2
  tank.y = HEIGHT / 2
  tank.angleTank = 270
  tank.angleBarrel = 270
  tank.rotationSpeedTank = 200
  tank.rotationSpeedBarrel = 100
  tank.velocity = 0
  tank.velocityMax = 1.25
  tank.inertiaCap = 0.75
  tank.hpMax = 100
  tank.hp = tank.hpMax
  tank.timerShot = TIMER_SHOT
  tank.score = 0
  tank.engineIsOn = false
  tank.gameOver = false

  MouseX, MouseY = love.mouse.getPosition()
  isDead = false
end

function explodeTank(pX, pY)
  if tank.hp > 0 then
    ExplodeModule.createExplode(pX, pY, 0.1)
  else 
    for n = 1, math.random(4, 6) do
      local x = math.random(tank.x - tank.widthTank / 2, tank.x + tank.widthTank / 2)
      local y = math.random(tank.y - tank.heightTank / 2, tank.y + tank.heightTank / 2)
      ExplodeModule.createExplode(x, y, math.random(5, 20) / 100)
    end
  end
end 

function tank.update(dt)
  
  if tank.hp > 0 then
    --tirs du tank
    if tank.timerShot > 0 then
      tank.timerShot = tank.timerShot - dt
    end
    
    if love.mouse.isDown(1) and tank.timerShot <= 0 then
      tank.timerShot = TIMER_SHOT
      ShotModule.Shoot(tank.x, tank.y, tank.angleBarrel, LST_BUL_SPD_TANK[1], 1, "ally")
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
    tank.angleBarrel = MathModule.getAngle(tank.x, tank.y, MouseX, MouseY, "degAbsolute")

    --avancée du tank
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

    --Collision avec les tirs ennemis
    if #ShotModule.listShots > 0 then
      for n = 1, #ShotModule.listShots do 
        local shot = ShotModule.listShots[n]
        if shot.team == "enemy" then
          if shot.x >= tank.x - tank.widthTank / 2  and 
          shot.x <= tank.x + tank.widthTank / 2  and 
          shot.y >= tank.y - tank.heightTank / 2  and
          shot.y <= tank.y + tank.heightTank / 2  then
            tank.hp = tank.hp - shot.type
            if tank.hp < 0 then
              tank.hp = 0
            end
            shot.isDeletable = true
            explodeTank(shot.x, shot.y)
          end
        end
      end
    end

    --Collision avec les bords
    if tank.x < 0 + (tank.widthTank / 2) then
      tank.x = 0 + (tank.widthTank / 2)
    elseif tank.x > WIDTH - (tank.widthTank / 2) then
      tank.x = WIDTH - (tank.widthTank / 2)
    end

    if tank.y < 0 + (tank.heightTank / 2) then
      tank.y = 0 + (tank.heightTank / 2)
    elseif tank.y > HEIGHT - (tank.heightTank / 2) then
      tank.y = HEIGHT - (tank.heightTank / 2)
    end

  
  else
    isDead = true
  end

  --tank.gameOver
  if isDead and #ExplodeModule.listExplodes == 0 then
    tank.gameOver = true
  end
end

function tank.draw()
  --dessin du tank
  if isDead == false then
    love.graphics.draw( tank.imageTank, tank.x, tank.y, 
    math.rad(tank.angleTank), 1, 1, tank.widthTank / 2, tank.heightTank / 2)

    --dessin du canon
    love.graphics.draw(tank.imageBarrel, tank.x, tank.y, 
    math.rad(tank.angleBarrel), 1, 1, 5, tank.heightBarrel / 2)
  end
end
return tank
local tank = {}

local ShotModule = require("shotModule")

local WIDTH, HEIGHT
local STD_BULLET_SPEED = 400
--local MISSILE_SPEED = 250
local TIMER_SHOT = 0.5

--Fixe
tank.imageTank = love.graphics.newImage("images/tank.png")
tank.imageBarrel = love.graphics.newImage("images/barrel.png")
tank.widthTank = tank.imageTank:getWidth()
tank.heightTank = tank.imageTank:getHeight()
tank.widthBarrel = tank.imageBarrel:getWidth()
tank.heightBarrel = tank.imageBarrel:getHeight()

--Variable
tank.x = 0
tank.y = 0
tank.angleTank = nil
tank.angleBarrel = nil
tank.rotationSpeedTank = nil
tank.rotationSpeedBarrel = nil
tank.velocity = nil
tank.velocityMax = nil
tank.inertiaCap = nil
tank.engineIsOn = nil
tank.canShoot = nil

function tank.loadTank()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
  tank.x = WIDTH / 2
  tank.y = HEIGHT / 2
  tank.angleTank = 270
  tank.angleBarrel = 270
  tank.rotationSpeedTank = 75
  tank.rotationSpeedBarrel = 150
  tank.velocity = 0
  tank.velocityMax = 2.5
  tank.inertiaCap = 0.75
  tank.engineIsOn = false
  tank.canShoot = true
end

function tank.updateTank(dt)
  --tirs du tank
  if tank.canShoot == false then
    TIMER_SHOT = TIMER_SHOT - dt
    if TIMER_SHOT <= 0 then
      TIMER_SHOT = 1
      tank.canShoot = true
    end
  else
    if love.keyboard.isDown("space") then
      tank.canShoot = false
      ShotModule.Shoot(tank.x, tank.y, tank.angleBarrel, STD_BULLET_SPEED, 1, "ally")
    end
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
  if love.keyboard.isDown("left") then
    tank.angleBarrel = tank.angleBarrel - (tank.rotationSpeedBarrel * dt)
    if tank.angleBarrel < 0 then
      tank.angleBarrel = 360 - tank.angleBarrel
    end
  end

  if love.keyboard.isDown("right") then
    tank.angleBarrel = tank.angleBarrel + (tank.rotationSpeedBarrel * dt)
    if tank.angleBarrel > 360 then
      tank.angleBarrel = tank.angleBarrel - 360
    end
  end

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
end

function tank.drawTank()
  --dessin du tank
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
end

return tank

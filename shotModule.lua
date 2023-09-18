local shotModule = {}

local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

shotModule.listShots = nil

local LIMIT_COUNTER_SINUSOIDE = 0.3
local CONST_DEVIATION = 45

function shotModule.load()
  shotModule.listShots = {}
end

function shotModule.Shoot(pXShooter, pYShooter, pAngle, pSpeed, pType, pTeam)
  local shot = {}
  shot.x = pXShooter
  shot.y = pYShooter
  shot.angle = pAngle
  shot.speed = pSpeed
  shot.type = pType
  shot.team = pTeam
  shot.isDeletable = false
  
  if shot.team == "ally" then
    shot.image = love.graphics.newImage("images/myBullet"..tostring(shot.type)..".png")
  elseif shot.team == "enemy" then
    shot.image = love.graphics.newImage("images/enemyBullet"..tostring(shot.type)..".png")
  end

  shot.w = shot.image:getWidth()
  shot.h = shot.image:getHeight()

  --cas des missiles
  if shot.type == 3 then
    local rnd = math.random(0, 1)
    if rnd == 0 then
      shot.deviateUp = false
      shot.deviateCounter = -LIMIT_COUNTER_SINUSOIDE / 2
    else 
      shot.deviateUp = true 
      shot.deviateCounter = LIMIT_COUNTER_SINUSOIDE / 2
    end
  end
  table.insert(shotModule.listShots, shot)
end

function shotModule.update(dt)
  if #shotModule.listShots > 0 then
    for n = 1, #shotModule.listShots do 
      local shot = shotModule.listShots[n]

      if shot.type == 3 then
        --On dévie le tir dans un sens ou dans l'autre (sinusoïdale)
        if shot.deviateUp then
          shot.angle = shot.angle + dt * CONST_DEVIATION
          shot.deviateCounter = shot.deviateCounter + dt
        else
          shot.angle = shot.angle - dt * CONST_DEVIATION
          shot.deviateCounter = shot.deviateCounter - dt
        end
        
        if shot.deviateCounter >= LIMIT_COUNTER_SINUSOIDE then
          shot.deviateUp = false
        elseif shot.deviateCounter <= -LIMIT_COUNTER_SINUSOIDE then
          shot.deviateUp = true
        end
      end

      --Avancée des tirs 
      local vx = math.cos(math.rad(shot.angle)) * shot.speed
      local vy = math.sin(math.rad(shot.angle)) * shot.speed
     
      shot.x = shot.x + vx * dt
      shot.y = shot.y + vy * dt
      
      if shot.x < 0 - shot.image:getWidth()/2 or
        shot.x > WIDTH + shot.image:getWidth()/2 or
        shot.y < 0 - shot.image:getHeight()/2 or
        shot.y > HEIGHT + shot.image:getHeight()/2 then
          shot.isDeletable = true
      end
    end
    
    --Suppression des tirs
    for n = #shotModule.listShots, 1, -1 do
      if shotModule.listShots[n].isDeletable then
        table.remove(shotModule.listShots, n)
      end
    end
  end
end

function shotModule.draw()
  if #shotModule.listShots > 0 then
    for n = 1, #shotModule.listShots do
      local shot = shotModule.listShots[n]
      love.graphics.draw(shot.image, shot.x, shot.y, 
        math.rad(shot.angle), 1, 1, shot.image:getWidth()/2, shot.image:getHeight()/2)
    end
  end
end

return shotModule
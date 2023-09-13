local shotModule = {}

local WIDTH, HEIGHT

shotModule.listShots = nil

function shotModule:loadModule()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
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
  shot.vx = math.cos(math.rad(shot.angle)) * shot.speed
  shot.vy = math.sin(math.rad(shot.angle)) * shot.speed
  shot.isDeletable = false
  
  if shot.team == "ally" then
    shot.image = love.graphics.newImage("images/myBullet"..tostring(shot.type)..".png")
  elseif shot.team == "enemy" then
    shot.image = love.graphics.newImage("images/enemyBullet"..tostring(shot.type)..".png")
  end
  table.insert(shotModule.listShots, shot)
end

function shotModule.updateShots(dt)
  if #shotModule.listShots > 0 then
    for n = 1, #shotModule.listShots do 
      local shot = shotModule.listShots[n]
      shot.x = shot.x + shot.vx * dt
      shot.y = shot.y + shot.vy * dt
      
      if shot.x < 0 - shot.image:getWidth()/2 or
        shot.x > WIDTH + shot.image:getWidth()/2 or
        shot.y < 0 - shot.image:getHeight()/2 or
        shot.y > HEIGHT + shot.image:getHeight()/2 then
          shot.isDeletable = true
      end
    end
    
    for n = #shotModule.listShots, 1, -1 do
      if shotModule.listShots[n].isDeletable then
        table.remove(shotModule.listShots, n)
      end
    end
  end
end

function shotModule.drawShots()
  if #shotModule.listShots > 0 then
    for n = 1, #shotModule.listShots do
      local shot = shotModule.listShots[n]
      love.graphics.draw(shot.image, shot.x, shot.y, 
        math.rad(shot.angle), 1, 1, shot.image:getWidth()/2, shot.image:getHeight()/2)
    end
  end
end

return shotModule





local explodeModule = {}

local LST_IMG_EXPLODE = {}
for n = 1, 5 do
  LST_IMG_EXPLODE[n] = love.graphics.newImage("images/explode_"..tostring(n)..".png")
end

explodeModule.listExplodes = nil 

function explodeModule.load()
  explodeModule.listExplodes = {}
end

function explodeModule.createExplode(pX, pY, ptimer)
  local explode = {}
  explode.x = pX
  explode.y = pY
  explode.frame = 1
  explode.timerRef = ptimer
  explode.timer = ptimer
  explode.isDeletable = false
  table.insert(explodeModule.listExplodes, explode)
end

function explodeModule.update(dt)
  if #explodeModule.listExplodes > 0 then
    --évolution des explosions
    for n = 1, #explodeModule.listExplodes do 
      local ex = explodeModule.listExplodes[n]
      ex.timer = ex.timer - dt
      if ex.timer <= 0 then
        ex.frame = ex.frame + 1
        ex.timer = ex.timerRef
      end

      if ex.frame > #LST_IMG_EXPLODE then
        ex.isDeletable = true
      end
    end
  end

  --Suppression des explosions
  for n = #explodeModule.listExplodes, 1, -1 do 
    local ex = explodeModule.listExplodes[n]
    if ex.isDeletable then
      table.remove(explodeModule.listExplodes, n)
    end
  end
end

function explodeModule.draw()
  if #explodeModule.listExplodes > 0 then
    for n = 1, #explodeModule.listExplodes do 
      local ex = explodeModule.listExplodes[n]
      local imgFrame = LST_IMG_EXPLODE[ex.frame]
      love.graphics.draw(imgFrame, ex.x, ex.y, 0, 1, 1, imgFrame:getWidth()/2, imgFrame:getHeight()/2)
    end
  end
end

return explodeModule
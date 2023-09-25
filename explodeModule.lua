local explodeModule = {}

local LST_IMG_EXPLODE = {}
for n = 1, 5 do
  LST_IMG_EXPLODE[n] = love.graphics.newImage("images/explode_"..tostring(n)..".png")
end

local LST_IMG_EXPLODE_MISSILE = {}
local IMG_MISSILE_EXPL = love.graphics.newImage("images/explosion_missile.png")
for n = 1, 6 do
  LST_IMG_EXPLODE_MISSILE[n] = love.graphics.newQuad(32* (n-1), 0, 32, 32, 
  IMG_MISSILE_EXPL:getWidth(), IMG_MISSILE_EXPL:getHeight())
end

local TYPE_SIMPLE = "simple"
local TYPE_MISSILE = "missile"

explodeModule.listExplodes = nil 

function explodeModule.load()
  explodeModule.listExplodes = {}
end

function explodeModule.createExplode(pX, pY, ptimer, pType)
  local explode = {}
  explode.x = pX
  explode.y = pY
  explode.frame = 1
  explode.timerRef = ptimer
  explode.timer = ptimer
  explode.isDeletable = false
  explode.type = pType
  table.insert(explodeModule.listExplodes, explode)
end

function explodeModule.createMultiExplode(pX, pY, pObjW, pObjH)
  for n = 1, math.random(4, 6) do
    local x = math.random(pX - pObjW / 2, pX + pObjW / 2)
    local y = math.random(pY- pObjH / 2, pY + pObjH / 2)
    local timer = math.random(5, 20) / 100
    explodeModule.createExplode(x, y, timer, "simple")
  end
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

      if ex.type == "simple" then
        if ex.frame > #LST_IMG_EXPLODE then
          ex.isDeletable = true
        end
      elseif ex.type == "missile" then
        if ex.frame > #LST_IMG_EXPLODE_MISSILE then
          ex.isDeletable = true
        end
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
      local imgFrame
      if ex.type == "simple" then 
        imgFrame = LST_IMG_EXPLODE[ex.frame]
        love.graphics.draw(imgFrame, ex.x, ex.y, 0, 1, 1, imgFrame:getWidth()/2, imgFrame:getHeight()/2)
      elseif ex.type == "missile" then 
        love.graphics.draw(IMG_MISSILE_EXPL, LST_IMG_EXPLODE_MISSILE[ex.frame], ex.x, ex.y)
      end 
    end
  end
end

return explodeModule
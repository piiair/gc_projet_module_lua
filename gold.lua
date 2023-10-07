local gold = {}

local SettingsMod = require("settings")
local MathMod = require("utilMath")

local imgGold = love.graphics.newImage("images/gold.png")
local IMG_W = imgGold:getWidth()
local IMG_H = imgGold:getHeight()

local DROP_RAY = 20

gold.listCoin = nil

function gold.genereGold(pEnemy)
  local rnd = math.random(1, math.floor(pEnemy.hpMax / 2))
  for n = 1, rnd do 
    local c = {}
    c.image = imgGold
    c.w = IMG_W
    c.h = IMG_H
    c.isDeletable = false
    c.timer = math.random(5, 10)

    c.x = math.random(pEnemy.x - DROP_RAY, pEnemy.x + DROP_RAY)
    c.y = math.random(pEnemy.y - DROP_RAY, pEnemy.y + DROP_RAY)
    local isCollideBorder = MathMod.verifyCollideScreenBorders(
      c, 
      SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER, 
      SettingsMod.screenH, 
      "inside"
    )
    while isCollideBorder do
      c.x = math.random(pEnemy.x - DROP_RAY, pEnemy.x + DROP_RAY)
      c.y = math.random(pEnemy.y - DROP_RAY, pEnemy.y + DROP_RAY)
      isCollideBorder = MathMod.verifyCollideScreenBorders(
      c, 
      SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER, 
      SettingsMod.screenH, 
      "inside"
    )
    end

    table.insert(gold.listCoin, c)
  end
end

function gold.load()
  gold.listCoin = {}
end

function gold.update(dt)
  for n = 1, #gold.listCoin do
    local c = gold.listCoin[n]
    c.timer = c.timer - dt
    if c.timer <= 0 then
      c.isDeletable = true
    end
  end

  --Suppression des coin ramassés
  for n = #gold.listCoin, 1, -1 do
    local c = gold.listCoin[n]
    if c.isDeletable then
      table.remove(gold.listCoin, n)
    end
  end
end

function gold.draw()
  for n = 1, #gold.listCoin do 
    local c = gold.listCoin[n]
    love.graphics.draw(c.image, c.x, c.y, 0, 1, 1, c.w/2, c.h/2)
  end
end

return gold
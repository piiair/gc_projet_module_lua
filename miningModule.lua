local miningMod = {}

local MathMod = require("utilMath")
local SettingsMod = require("settings")

local imgSite = love.graphics.newImage("images/mine.png")
miningMod.mineW = imgSite:getWidth()
miningMod.mineH = imgSite:getHeight()

miningMod.listSites = {}
local lstSites = miningMod.listSites

local LIMIT_X_BORDER = 150
local LIMIT_Y_BORDER = 150
local DIST_MIN = 150

function miningMod.reset()
  miningMod.listSites = {}
end

function miningMod.load(Tank)
  while #miningMod.listSites < 5 do
    local s = {}
    local validPos = true
    local W = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER
    local H = SettingsMod.screenH

    s.stock = 5
    s.x = math.random(LIMIT_X_BORDER, W - LIMIT_X_BORDER)
    s.y = math.random(LIMIT_Y_BORDER, H - LIMIT_Y_BORDER)

    local distPlayer = MathMod.absoluteDistance(s.x, s.y, Tank.x, Tank.y)
    if distPlayer < DIST_MIN then
      validPos = false
    end

    for n = 1, #miningMod.listSites do
      local curSite = miningMod.listSites[n]
      local dist = MathMod.absoluteDistance(s.x, s.y, curSite.x, curSite.y)
      if dist < DIST_MIN then
        validPos = false
      end
    end

    if validPos then
      table.insert(miningMod.listSites, s)
    end
  end
end

function miningMod.update()
  for n = #miningMod.listSites, 1, -1 do
    local s = miningMod.listSites[n]
    if s.stock == 0 then
      table.remove(miningMod.listSites, n)
    end
  end
end

function miningMod.draw()
  for n = 1, #miningMod.listSites do
    local s = miningMod.listSites[n]
    love.graphics.draw(imgSite, s.x, s.y, 0, 1, 1, miningMod.mineW / 2, miningMod.mineH / 2)
  end
end

return miningMod

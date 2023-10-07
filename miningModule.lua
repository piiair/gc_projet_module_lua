local miningMod = {}

local MathMod = require("utilMath")
local SettingsMod = require("settings")

local imgSite = love.graphics.newImage("images/mine.png")
miningMod.mineW = imgSite:getWidth()
miningMod.mineH = imgSite:getHeight()

local LIMIT_X_BORDER = 150
local LIMIT_Y_BORDER = 150
local DIST_MIN = 175

local NB_SITES = 6
local STOCK_PER_SITES = 8

function miningMod.reset()
  miningMod.listSites = nil
  miningMod.totalStock = nil
end

function miningMod.load(Tank)
  miningMod.listSites = {}
  miningMod.totalStock = NB_SITES * STOCK_PER_SITES
  local counterId = 1

  while #miningMod.listSites < NB_SITES do
    local s = {}
    local validPos = true
    local W = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER
    local H = SettingsMod.screenH

    s.stock = STOCK_PER_SITES
    s.id = counterId
    s.minor = 0
    s.x = math.random(LIMIT_X_BORDER, W - LIMIT_X_BORDER)
    s.y = math.random(LIMIT_Y_BORDER, H - LIMIT_Y_BORDER)

    --On vérifie que la position du nouveau site soit valide par rapport au joueur
    local distPlayer = MathMod.absoluteDistance(s.x, s.y, Tank.x, Tank.y)
    if distPlayer < DIST_MIN then
      validPos = false
    end

    --On vérifie que la position du nouveau site soit valide par rapport aux autres sites
    for n = 1, #miningMod.listSites do
      local curSite = miningMod.listSites[n]
      local dist = MathMod.absoluteDistance(s.x, s.y, curSite.x, curSite.y)
      if dist < DIST_MIN then
        validPos = false
      end
    end

    --On ajoute le site si la position est valide
    if validPos then
      table.insert(miningMod.listSites, s)
      counterId = counterId + 1
    end
  end
end

function miningMod.findSiteById(pIdMine)
  for n = 1, #miningMod.listSites do
    if miningMod.listSites[n].id == pIdMine then
      return n
    end
  end
end

function miningMod.Mine(pIdMine)
  local index = miningMod.findSiteById(pIdMine)
  miningMod.listSites[index].minor = miningMod.listSites[index].minor - 1
end

function miningMod.update()
  for n = #miningMod.listSites, 1, -1 do
    local s = miningMod.listSites[n]
    if s.stock == 0 and s.minor == 0 then
      table.remove(miningMod.listSites, n)
    end
  end
end

function miningMod.draw()
  for n = 1, #miningMod.listSites do
    local s = miningMod.listSites[n]
    love.graphics.draw(imgSite, s.x, s.y, 0, 1, 1, miningMod.mineW / 2, miningMod.mineH / 2)
  end

  love.graphics.print(miningMod.totalStock, 100)
  local totalStock = 0
  local totalMinor = 0
  for n = 1, #miningMod.listSites do
    local s = miningMod.listSites[n]
    totalStock = totalStock + s.stock 
    totalMinor = totalMinor + s.minor
  end
  love.graphics.print(totalStock, 100, 20)
  love.graphics.print(totalMinor, 100, 40)
end

return miningMod

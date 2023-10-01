local up = {}

--[[Les charactéristiques sont gérées comme suit (pour les références d'index): 
  1 = damages
  2 = speed
  3 = rate
  4 = range
]]

local Tank = require("tank")

local LST_UPGRADE_BY_CHAR = {1, 25, 0.1, 25}

local sndUpgrade = love.audio.newSource("sounds/upgrade.wav", "static")

up.listBul = nil

function up.load()
  up.listBul = {}
  for n = 1, 3 do
    local bul = {}
    if n < 3 then
      for N = 1, 4 do
        local char = {}
        char.lvl = 1
        char.bonus = 0
        table.insert(bul, char)
      end
    elseif n == 3 then
      for N = 1, 3 do
        local char = {}
        char.lvl = 1
        char.bonus = 0
        table.insert(bul, char)
      end
    end
    table.insert(up.listBul, bul)
  end
end

function up.upgradeChar(pBullet, pCharId)
  local charToUp = up.listBul[pBullet][pCharId]
  if charToUp.lvl < 5 and Tank.goldStock >= charToUp.lvl then
    charToUp.lvl = charToUp.lvl + 1
    charToUp.bonus = charToUp.bonus + LST_UPGRADE_BY_CHAR[pCharId]
    Tank.goldStock = Tank.goldStock - charToUp.lvl
    sndUpgrade:stop()
    sndUpgrade:play()
  end
  up.listBul[pBullet][pCharId] = charToUp
end

return up
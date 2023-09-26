local depo = {}

local SettingsMod = require("settings")

local imgDepo = love.graphics.newImage("images/deposit.png")
local imgW = imgDepo:getWidth()
local imgH = imgDepo:getHeight()

depo.LIST_DEPOSIT_SITES = {}
depo.DEPOSIT_SIZE = 32

function depo.loadDepositSites()
  local W = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER
  local H = SettingsMod.screenH

  local s1 = {
    x = 0 + depo.DEPOSIT_SIZE / 2, 
    y = H / 2
  }

  local s2 = {
    x = W / 2, 
    y = 0 + depo.DEPOSIT_SIZE / 2
  }

  local s3 = {
    x =  W - depo.DEPOSIT_SIZE / 2, 
    y = H / 2
  }

  local s4 = {
    x = W / 2, 
    y = H - depo.DEPOSIT_SIZE / 2
  }

  table.insert(depo.LIST_DEPOSIT_SITES, s1)
  table.insert(depo.LIST_DEPOSIT_SITES, s2)
  table.insert(depo.LIST_DEPOSIT_SITES, s3)
  table.insert(depo.LIST_DEPOSIT_SITES, s4)
end

function depo.draw()
  for n = 1, #depo.LIST_DEPOSIT_SITES do
    local d = depo.LIST_DEPOSIT_SITES[n]
    love.graphics.draw(imgDepo, d.x, d.y, 0, 1, 1, imgW / 2, imgH / 2)
  end
end

return depo
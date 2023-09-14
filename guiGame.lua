local GuiGame = {}

local GCGUI = require("GCGUI")
local Tank = require("tank")

local WIDTH, HEIGHT

local imageButton = {}
imageButton.image = love.graphics.newImage("images/button.png")
imageButton.w = imageButton.image:getWidth()
imageButton.h = imageButton.image:getHeight()

GuiGame.menuGroup = nil
GuiGame.gameGroup = nil
GuiGame.gameOverGroup = nil

--fonctions du menuGroup
function GuiGame.loadMenuGroup()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()

  GuiGame.menuGroup = GCGUI.newGroup()
  local menuButtonPlay = GCGUI.newButton(WIDTH/2 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "Play", GCGUI.font)
  menuButtonPlay:setImage(imageButton.image)

  GuiGame.menuGroup:addElement(menuButtonPlay)
end

function GuiGame.updateMenuGroup(dt)
  GuiGame.menuGroup:update(dt)
end

--Fonctions du gameGroup
function GuiGame.loadGameGroup()
  GuiGame.gameGroup = GCGUI.newGroup()
  local gameHpBarPlayer = GCGUI.newProgressBar(0, 0, Tank.widthTank, 6,
    Tank.hpMax, {65 / 255, 61 / 255, 61 / 255}, {27 / 255, 180 / 255, 27 / 255})
  gameHpBarPlayer:setValue(Tank.hp)
  GuiGame.gameGroup:addElement(gameHpBarPlayer)
end

function GuiGame.updateGameGroup(dt)
  --GuiGame.gameGroup:update(dt)
  GuiGame.gameGroup.elements[1]:setValue(Tank.hp)
  GuiGame.gameGroup.elements[1].setPosition(Tank.x - Tank.widthTank / 2, Tank.y - Tank.heightTank - 10)
end



return GuiGame





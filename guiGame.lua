local GuiGame = {}

local GCGUI = require("GCGUI")

local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()

local imageButton = {}
imageButton.image = love.graphics.newImage("images/button.png")
imageButton.w = imageButton.image:getWidth()
imageButton.h = imageButton.image:getHeight()

GuiGame.menuGroup = nil
GuiGame.gameGroup = nil
GuiGame.victoryGroup = nil
GuiGame.gameOverGroup = nil

function GuiGame.resetGui()
  GuiGame.menuGroup = nil
  GuiGame.gameGroup = nil
  GuiGame.victoryGroup = nil
  GuiGame.gameOverGroup = nil
end

--fonctions du menuGroup
function GuiGame.loadMenuGroup()
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

--Fonctions du victoryGroup
function GuiGame.loadVictoryGroup()
  GuiGame.victoryGroup = GCGUI.newGroup()

  local victoryButtonRestart = GCGUI.newButton(WIDTH/3 - imageButton.w / 2, 350, imageButton.w, imageButton.h, "New Game", GCGUI.font)
  victoryButtonRestart:setImage(imageButton.image)

  local victoryButtonMenu = GCGUI.newButton(WIDTH - WIDTH/3 - imageButton.w / 2, 350, imageButton.w, imageButton.h, "Menu", GCGUI.font)
  victoryButtonMenu:setImage(imageButton.image)

  local text = "You Win !"
  local victoryText = GCGUI.newText(0, 0, WIDTH, 300, text, GCGUI.font, "center", "center")

  GuiGame.victoryGroup:addElement(victoryButtonRestart)
  GuiGame.victoryGroup:addElement(victoryButtonMenu)
  GuiGame.victoryGroup:addElement(victoryText)
end

function GuiGame.updateVictoryGroup(dt)
  GuiGame.victoryGroup:update(dt)
end

--Fonctions du gameOverGroup
function GuiGame.loadGameOverGroup()
  GuiGame.gameOverGroup = GCGUI.newGroup()

  local gameOverButtonRestart = GCGUI.newButton(WIDTH/3 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "New Game", GCGUI.font)
  gameOverButtonRestart:setImage(imageButton.image)

  local gameOverButtonMenu = GCGUI.newButton(WIDTH - WIDTH/3 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "Menu", GCGUI.font)
  gameOverButtonMenu:setImage(imageButton.image)

  local enemyOrEnemies
  if Tank.score > 1 then
    enemyOrEnemies = " enemies."
  else
    enemyOrEnemies = " enemy."
  end
  local text = "Game Over... You survive "..tostring(Tank.score)..enemyOrEnemies
  local gameOverText = GCGUI.newText(0, 0, WIDTH, 300, text, GCGUI.font, "center", "center")

  GuiGame.gameOverGroup:addElement(gameOverButtonRestart)
  GuiGame.gameOverGroup:addElement(gameOverButtonMenu)
  GuiGame.gameOverGroup:addElement(gameOverText)
end

function GuiGame.updateGameOverGroup(dt)
  GuiGame.gameOverGroup:update(dt)
end

return GuiGame





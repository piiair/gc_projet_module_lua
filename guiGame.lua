local GuiGame = {}

local GCGUI = require("GCGUI")
local SettingsMod = require("settings")
local Tank = require("tank")
local EnemyMod = require("enemyModule")

local imageButton = {}
imageButton.image = love.graphics.newImage("images/button.png")
imageButton.w = imageButton.image:getWidth()
imageButton.h = imageButton.image:getHeight()

local PROG_BAR_SIZE = 6
local BAR_HP_COLOR_OUT = {
  [1] = 65 / 255,
  [2] = 61 / 255,
  [3] = 61 / 255
}
local BAR_HP_COLOR_IN = {
  [1] = 27 / 255,
  [2] = 180 / 255,
  [3] = 27 / 255
}

function GuiGame.resetGui()
  GuiGame.menuGroup = nil
  GuiGame.gameGroup = nil
  GuiGame.victoryGroup = nil
  GuiGame.gameOverGroup = nil
end

--fonctions du menuGroup
function GuiGame.loadMenuGroup()
  GuiGame.menuGroup = GCGUI.newGroup()
  local menuButtonPlay =
    GCGUI.newButton(SettingsMod.screenW / 2 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "Play", GCGUI.font)
  menuButtonPlay:setImage(imageButton.image)

  GuiGame.menuGroup:addElement(menuButtonPlay)
end

function GuiGame.updateMenuGroup(dt)
  GuiGame.menuGroup:update(dt)
end

--Fonctions du gameGroup
function GuiGame.loadGameGroup()
  GuiGame.gameGroup = GCGUI.newGroup()

  local gameHpBarPlayer =
    GCGUI.newProgressBar(0, 0, Tank.widthTank, PROG_BAR_SIZE, Tank.hpMax, BAR_HP_COLOR_OUT, BAR_HP_COLOR_IN)
  gameHpBarPlayer:setValue(Tank.hp)

  local text = "Enemies remaining: " .. tostring(EnemyMod.ENEMIES_PER_LEVEL[1] - Tank.score)
  local remainingEnemiesPanel =
    GCGUI.newText(SettingsMod.screenW - 300, 10, 200, 25, text, GCGUI.font, "center", "center")

  GuiGame.gameGroup:addElement(gameHpBarPlayer)
  GuiGame.gameGroup:addElement(remainingEnemiesPanel)
  GuiGame.gameGroup.hpBarsGroup = GCGUI.newGroup()
end

local function AddHpBarEnemy(pEnemy)
  local e = pEnemy
  local bar =
    GCGUI.newProgressBar(
    e.x - EnemyMod.TANK_WIDTH / 2,
    e.y - EnemyMod.TANK_HEIGHT / 2,
    EnemyMod.TANK_WIDTH,
    PROG_BAR_SIZE,
    e.hp,
    BAR_HP_COLOR_OUT,
    BAR_HP_COLOR_IN
  )
  GuiGame.gameGroup.hpBarsGroup:addElement(bar)
end

function GuiGame.updateGameGroup(dt)
  --GuiGame.gameGroup:update(dt)

  --La barre hp du joueur
  GuiGame.gameGroup.elements[1]:setValue(Tank.hp)
  GuiGame.gameGroup.elements[1].setPosition(Tank.x - Tank.widthTank / 2, Tank.y - Tank.heightTank - 10)

  --Le score
  local text = "Enemies remaining: " .. tostring(EnemyMod.ENEMIES_PER_LEVEL[1] - EnemyMod.scorePlayer)
  GuiGame.gameGroup.elements[2]:updateText(text)

  --Les barres hp des ennemis
  local groupBar = GuiGame.gameGroup.hpBarsGroup
  for n = 1, #EnemyMod.listEnemies do
    local e = EnemyMod.listEnemies[n]
    if not groupBar.elements[e.id] then
      local b = AddHpBarEnemy(e)
    end
    groupBar.elements[e.id]:setValue(e.hp)
    groupBar.elements[e.id].setPosition(e.x - e.w / 2, e.y - e.h / 2 - 10)
  end
end

function GuiGame.drawHpBars()
  GuiGame.gameGroup.hpBarsGroup:draw()
end

--Fonctions du victoryGroup
function GuiGame.loadVictoryGroup()
  GuiGame.victoryGroup = GCGUI.newGroup()

  local victoryButtonRestart =
    GCGUI.newButton(
    SettingsMod.screenW / 3 - imageButton.w / 2,
    350,
    imageButton.w,
    imageButton.h,
    "New Game",
    GCGUI.font
  )
  victoryButtonRestart:setImage(imageButton.image)

  local victoryButtonMenu =
    GCGUI.newButton(
    SettingsMod.screenW - SettingsMod.screenW / 3 - imageButton.w / 2,
    350,
    imageButton.w,
    imageButton.h,
    "Menu",
    GCGUI.font
  )
  victoryButtonMenu:setImage(imageButton.image)

  local text = "You Win !"
  local victoryText = GCGUI.newText(0, 0, SettingsMod.screenW, 300, text, GCGUI.font, "center", "center")

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

  local gameOverButtonRestart =
    GCGUI.newButton(
    SettingsMod.screenW / 3 - imageButton.w / 2,
    250,
    imageButton.w,
    imageButton.h,
    "New Game",
    GCGUI.font
  )
  gameOverButtonRestart:setImage(imageButton.image)

  local gameOverButtonMenu =
    GCGUI.newButton(
    SettingsMod.screenW - SettingsMod.screenW / 3 - imageButton.w / 2,
    250,
    imageButton.w,
    imageButton.h,
    "Menu",
    GCGUI.font
  )
  gameOverButtonMenu:setImage(imageButton.image)

  local enemyOrEnemies
  if Tank.score > 1 then
    enemyOrEnemies = " enemies."
  else
    enemyOrEnemies = " enemy."
  end
  local text = "Game Over... You destroyed " .. tostring(EnemyMod.scorePlayer) .. enemyOrEnemies
  local gameOverText = GCGUI.newText(0, 0, SettingsMod.screenW, 300, text, GCGUI.font, "center", "center")

  GuiGame.gameOverGroup:addElement(gameOverButtonRestart)
  GuiGame.gameOverGroup:addElement(gameOverButtonMenu)
  GuiGame.gameOverGroup:addElement(gameOverText)
end

function GuiGame.updateGameOverGroup(dt)
  GuiGame.gameOverGroup:update(dt)
end

return GuiGame

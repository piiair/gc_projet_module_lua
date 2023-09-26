local GuiGame = {}

local GCGUI = require("GCGUI")
local SettingsMod = require("settings")
local GoldMod = require("gold")
local Tank = require("tank")
local EnemyMod = require("enemyModule")

local imageButton = {}
imageButton.image = love.graphics.newImage("images/button.png")
imageButton.w = imageButton.image:getWidth()
imageButton.h = imageButton.image:getHeight()

local W = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER
local H = SettingsMod.screenH

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

  --Gui du joueur avec les infos InGame utiles et les boutons d'upgrade
  local guiPlayer = GCGUI.newGroup()
  local panelBG = GCGUI.newPanel(W, 0, SettingsMod.MARGIN_GUI_PLAYER, H, {50 / 255, 40 / 255, 10 / 255})
  local margL = 5

  local text = "Enemies remaining: " .. tostring(EnemyMod.enemiesStock)
  local textEnemiesRemaining = GCGUI.newText(
    W + margL, 0, SettingsMod.MARGIN_GUI_PLAYER, 30, 
    text, GCGUI.font, "", "center"
  )

  local scoreText = "Enemies killed: "..tostring(EnemyMod.scorePlayer)
  local scorePanel = GCGUI.newText(
    W + margL, 40, SettingsMod.MARGIN_GUI_PLAYER, 30, 
    scoreText, GCGUI.font, "", "center"
  )

  local goldText = "Golds: "..tostring(Tank.goldStock)
  local goldPanel = GCGUI.newText(
    W + margL, 80, SettingsMod.MARGIN_GUI_PLAYER, 30, 
    goldText, GCGUI.font, "", "center"
  )

  guiPlayer:addElement(panelBG)
  guiPlayer:addElement(textEnemiesRemaining)
  guiPlayer:addElement(scorePanel)
  guiPlayer:addElement(goldPanel)

  GuiGame.gameGroup:addElement(gameHpBarPlayer)
  GuiGame.gameGroup:addElement(guiPlayer)
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
    e.hpMax,
    BAR_HP_COLOR_OUT,
    BAR_HP_COLOR_IN
  )
  bar.id = e.id
  GuiGame.gameGroup.hpBarsGroup:addElement(bar)
end

function GuiGame.updateGameGroup(dt)
  --GuiGame.gameGroup:update(dt)

  --La barre hp du joueur
  GuiGame.gameGroup.elements[1]:setValue(Tank.hp)
  GuiGame.gameGroup.elements[1].setPosition(Tank.x - Tank.widthTank / 2, Tank.y - Tank.heightTank - 10)

  --Les barres hp des ennemis
  local groupBar = GuiGame.gameGroup.hpBarsGroup

  --Suppression des barres obsolètes
  for n = #EnemyMod.listDeadIds, 1, -1 do
    local id = EnemyMod.listDeadIds[n]
    for o = #groupBar.elements, 1, -1 do
      local bar = groupBar.elements[o]
      if bar.id == id then
        table.remove(groupBar.elements, o)
        table.remove(EnemyMod.listDeadIds, n)
      end
    end
  end

  --Ajout des barres des nouveaux ennemis
  for n = 1, #EnemyMod.listEnemies do
    --création d'une barre
    local e = EnemyMod.listEnemies[n]
    local hasABar = false
    --On vérifie si l'ennemi a déjà une barre 
    for o = 1, #groupBar.elements do
      local bar = groupBar.elements[o]
      if e.id == bar.id then
        hasABar = true
      end
    end  
    --On en crée une dans le cas contraire
    if hasABar == false then
      AddHpBarEnemy(e)
    end
  end

  --update des barres
  for n = 1, #groupBar.elements do 
    local bar = groupBar.elements[n]
    for i = 1, #EnemyMod.listEnemies do
      local e = EnemyMod.listEnemies[i]
      if e.id == bar.id then
        bar:setValue(e.hp)
        bar.setPosition(e.x - e.w / 2, e.y - e.h / 2 - 10)
      end
    end
  end

  --Le gui player
  --Les ennemis restants
  local textEnemies = "Enemies remaining: " .. tostring(EnemyMod.enemiesStock)
  GuiGame.gameGroup.elements[2].elements[2]:updateText(textEnemies)

  --Le score du joueur
  local scoreText = "Enemies killed: "..tostring(EnemyMod.scorePlayer)
  GuiGame.gameGroup.elements[2].elements[3]:updateText(scoreText)

  --Les golds du joueur
  local goldText = "Golds: "..tostring(Tank.goldStock)
  GuiGame.gameGroup.elements[2].elements[4]:updateText(goldText)

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
  if EnemyMod.scorePlayer > 1 then
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

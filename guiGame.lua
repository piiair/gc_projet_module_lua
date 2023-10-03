local GuiGame = {}

local GCGUI = require("GCGUI")
local SettingsMod = require("settings")
local MathMod = require("utilMath")
local UpMod = require("upgrade")
local GoldMod = require("gold")
local Tank = require("tank")
local EnemyMod = require("enemyModule")
local ShotMod = require("shotModule")

local imageButton = {}
imageButton.image = love.graphics.newImage("images/button.png")
imageButton.w = imageButton.image:getWidth()
imageButton.h = imageButton.image:getHeight()

local imageBtnCharDefault = love.graphics.newImage("images/buttonCharD.png")
local imageBtnCharHover = love.graphics.newImage("images/buttonCharH.png")
local imageBtnCharPressed = love.graphics.newImage("images/buttonCharP.png")

local LIST_IMGS_UPGRADES = {}
for n = 1, 4 do
  LIST_IMGS_UPGRADES[n] = love.graphics.newImage("images/upgrade" .. tostring(n) .. ".png")
end

local W = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER
local H = SettingsMod.screenH

local PROG_BAR_SIZE = 6
local BAR_COLOR_OUT = {
  [1] = 65 / 255,
  [2] = 61 / 255,
  [3] = 61 / 255
}
local BAR_HP_COLOR_IN = {
  [1] = 27 / 255,
  [2] = 180 / 255,
  [3] = 27 / 255
}

local BAR_ENERGY_COLOR_IN = {
  [1] = 233 / 255,
  [2] = 233 / 255,
  [3] = 64 / 255
}

function GuiGame.resetGui()
  GuiGame.menuGroup = nil
  GuiGame.gameGroup = nil
  GuiGame.breakGroup = nil
  GuiGame.victoryGroup = nil
  GuiGame.gameOverGroup = nil
end

--fonctions du menuGroup
function GuiGame.loadMenuGroup()
  GuiGame.menuGroup = GCGUI.newGroup()
  local menuButtonPlay =
    GCGUI.newButton(SettingsMod.screenW / 2 - imageButton.w / 2, 125, imageButton.w, imageButton.h, "Play", GCGUI.font)
  menuButtonPlay:setImage(imageButton.image)

  local missionText = "Soldier ! Your mission is to destroy all enemies units before they got you!"
  local textMission = GCGUI.newText(0, 200, SettingsMod.screenW, 50, missionText, GCGUI.font, "center", "center")

  local marginLeft = 275
  local gameplayText = "~ Collect golds to upgrade your weapons or repair your tank."
  local textGameplay = GCGUI.newText(marginLeft , 250, SettingsMod.screenW, 50, gameplayText, GCGUI.fontMedium, "", "center")

  local controlsText = "~ [Z] to move, [Q] / [D] to rotate"
  local textcontrols = GCGUI.newText(marginLeft, 300, SettingsMod.screenW, 50, controlsText, GCGUI.fontMedium, "", "center")

  local utilsText = "~ [S] to swap weapon"
  local textUtils = GCGUI.newText(marginLeft, 350, SettingsMod.screenW, 50, utilsText, GCGUI.fontMedium, "", "center")

  local shootText = "~ [LEFT CLICK] to shoot with current weapon"
  local textShoot = GCGUI.newText(marginLeft, 400, SettingsMod.screenW, 50, shootText, GCGUI.fontMedium, "", "center")

  local healText = "~ [SPACE] spend gold to repair"
  local textHeal = GCGUI.newText(marginLeft, 450, SettingsMod.screenW, 50, healText, GCGUI.fontMedium, "", "center")

  local glText = "Good luck soldier !"
  local textGl = GCGUI.newText(0, 550, SettingsMod.screenW, 50, glText, GCGUI.font, "center", "center")

  GuiGame.menuGroup:addElement(menuButtonPlay)
  GuiGame.menuGroup:addElement(textMission)
  GuiGame.menuGroup:addElement(textGameplay)
  GuiGame.menuGroup:addElement(textcontrols)
  GuiGame.menuGroup:addElement(textUtils)
  GuiGame.menuGroup:addElement(textShoot)
  GuiGame.menuGroup:addElement(textHeal)
  GuiGame.menuGroup:addElement(textGl)
end

function GuiGame.updateMenuGroup(dt)
  GuiGame.menuGroup:update(dt)
end

--Fonctions du gameGroup
function GuiGame.loadGameGroup()
  GuiGame.gameGroup = GCGUI.newGroup()

  local gameHpBarPlayer =
    GCGUI.newProgressBar(0, 0, Tank.widthTank, PROG_BAR_SIZE, Tank.hpMax, BAR_COLOR_OUT, BAR_HP_COLOR_IN)
  gameHpBarPlayer:setValue(Tank.hp)

  --Gui du joueur avec les infos InGame utiles et les boutons d'upgrade
  local guiPlayer = GCGUI.newGroup()
  local panelBG = GCGUI.newPanel(W, 0, SettingsMod.MARGIN_GUI_PLAYER, H, {50 / 255, 40 / 255, 10 / 255})
  local margL = 5

  --Infos sur les enemis
  local text = "Enemies remaining: " .. tostring(EnemyMod.enemiesStock)
  local textEnemiesRemaining =
    GCGUI.newText(W + margL, 0, SettingsMod.MARGIN_GUI_PLAYER, 30, text, GCGUI.font, "", "center")

  local scoreText = "Enemies killed: " .. tostring(EnemyMod.scorePlayer)
  local scorePanel =
    GCGUI.newText(W + margL, 40, SettingsMod.MARGIN_GUI_PLAYER, 30, scoreText, GCGUI.font, "", "center")

  --Infos sur les golds et upgrades
  local refY = 110
  local margY = 30

  local goldText = "Golds: " .. tostring(Tank.goldStock)
  local goldPanel =
    GCGUI.newText(W + margL, refY, SettingsMod.MARGIN_GUI_PLAYER, 30, goldText, GCGUI.fontMedium, "", "center")

  local priceText = "Cost = level x 1G"
  local pricePanel =
    GCGUI.newText(W + margL, refY + margY, SettingsMod.MARGIN_GUI_PLAYER, 30, priceText, GCGUI.fontMedium, "", "center")

  --Le heal
  local healText = "To repair : 1G = 1HP"
  local panelHeal = GCGUI.newText(W + margL, refY + margY * 2, SettingsMod.MARGIN_GUI_PLAYER, 30, healText, GCGUI.fontMedium, "", "center")
  
  guiPlayer:addElement(panelBG)
  guiPlayer:addElement(textEnemiesRemaining)
  guiPlayer:addElement(scorePanel)
  guiPlayer:addElement(goldPanel)
  guiPlayer:addElement(pricePanel)
  guiPlayer:addElement(panelHeal)

  --partie upgrades
  --les images des projectiles
  local widthPerImage = (SettingsMod.MARGIN_GUI_PLAYER - 6 * margL) / 3
  for n = 1, 3 do
    local image = ShotMod.LST_IMGS_SHOTS_ALLY[n]
    local w = image:getWidth()
    local h = image:getHeight()
    local x = W + margL * 6 + (widthPerImage * (n - 1)) + ((widthPerImage - w) / 2)
    local y = refY + (3 * margY) + ((margY - h) / 2)
    local panelBullet = GCGUI.newPanel(x, y, w, h)
    panelBullet:setImage(image)
    guiPlayer:addElement(panelBullet)
  end

  --Les images des upgrades
  for n = 1, 4 do
    local image = LIST_IMGS_UPGRADES[n]
    local w = image:getWidth()
    local h = image:getHeight()
    local x = W + margL / 2
    local y = refY + (4 * margY) + (60 * (n - 1)) + ((60 - h) / 2)
    local panelUpgrade = GCGUI.newPanel(x, y, w, h)
    panelUpgrade:setImage(image)
    guiPlayer:addElement(panelUpgrade)
  end

  --Les charactéristiques des bullets
  for n = 1, 3 do
    local bul = UpMod.listBul[n]
    for N = 1, #bul do
      local char = bul[N]
      local signBonus
      if N < 4 then
        signBonus = "+"
      else
        signBonus = "-"
      end
      local textChar = tostring(char.lvl) .. "/" .. signBonus .. tostring(char.bonus)
      local size = 48
      local x = W + margL * 6 + (widthPerImage * (n - 1)) + size / 2
      local y = refY + (3 * margY) + (60 * (N - 1)) + size
      local btnChar = GCGUI.newButton(x, y, size, size, textChar, GCGUI.fontLitte)
      btnChar:setImages(imageBtnCharDefault, imageBtnCharHover, imageBtnCharPressed)
      btnChar.idBul = n
      btnChar.idChar = N
      guiPlayer:addElement(btnChar)
    end
  end

  --L'arme équipée
  local imgRef = ShotMod.LST_IMGS_SHOTS_ALLY[3]
  local Xcenter = W + (SettingsMod.MARGIN_GUI_PLAYER - imgRef:getWidth()) / 2
  local panelWeaponBorder = GCGUI.newPanel(
    Xcenter - 2,
    refY + margY * 15 - 2,
    imgRef:getWidth() + 4,
    imgRef:getHeight() + 4,
    {100 / 255, 100 / 255, 50 / 255}
  )

  local panelWeapon = GCGUI.newPanel(
    Xcenter,
    refY + margY * 15,
    imgRef:getWidth(),
    imgRef:getHeight()
  )
  panelWeapon:setImage(ShotMod.LST_IMGS_SHOTS_ALLY[Tank.currentWeapon])

  guiPlayer:addElement(panelWeaponBorder)
  guiPlayer:addElement(panelWeapon)

  GuiGame.gameGroup:addElement(gameHpBarPlayer)
  GuiGame.gameGroup:addElement(guiPlayer)
  GuiGame.gameGroup.hpBarsGroup = GCGUI.newGroup()
  GuiGame.gameGroup.energyBarsGroup = GCGUI.newGroup()
end

local function AddBarEnemy(pEnemy, pTypeBar)
  local e = pEnemy
  local bar
  if pTypeBar == "hp" then
    bar =
      GCGUI.newProgressBar(
      e.x - EnemyMod.TANK_WIDTH / 2,
      e.y - EnemyMod.TANK_HEIGHT / 2,
      EnemyMod.TANK_WIDTH,
      PROG_BAR_SIZE,
      e.hpMax,
      BAR_COLOR_OUT,
      BAR_HP_COLOR_IN
    )
    bar.id = e.id
    GuiGame.gameGroup.hpBarsGroup:addElement(bar)
  elseif pTypeBar == "energy" then
    bar =
      GCGUI.newProgressBar(
      e.x - EnemyMod.TANK_WIDTH / 2,
      e.y - EnemyMod.TANK_HEIGHT / 1.25,
      EnemyMod.TANK_WIDTH,
      PROG_BAR_SIZE,
      EnemyMod.FULL_STOCK_ENERGY,
      BAR_COLOR_OUT,
      BAR_ENERGY_COLOR_IN
    )
    bar:setValue(e.stockEnergy)
    bar.id = e.id
    GuiGame.gameGroup.energyBarsGroup:addElement(bar)
  end
end

function GuiGame.updateGameGroup(dt)
  GuiGame.gameGroup:update(dt)

  --La barre hp du joueur
  GuiGame.gameGroup.elements[1]:setValue(Tank.hp)
  GuiGame.gameGroup.elements[1].setPosition(Tank.x - Tank.widthTank / 2, Tank.y - Tank.heightTank - 10)

  --Les barres hp/energy des ennemis
  local groupBarHp = GuiGame.gameGroup.hpBarsGroup
  local groupBarEnergy = GuiGame.gameGroup.energyBarsGroup

  --Suppression des barres obsolètes
  for n = #EnemyMod.listDeadIds, 1, -1 do
    local id = EnemyMod.listDeadIds[n]

    --Barres hp
    for o = #groupBarHp.elements, 1, -1 do
      local bar = groupBarHp.elements[o]
      if bar.id == id then
        table.remove(groupBarHp.elements, o)
      end
    end

    --Barres energy
    for o = #groupBarEnergy.elements, 1, -1 do
      local bar = groupBarEnergy.elements[o]
      if bar.id == id then
        table.remove(groupBarEnergy.elements, o)
        --On supprime l'id quand toutes les barres sont supprimées
        table.remove(EnemyMod.listDeadIds, n)
      end
    end
  end

  --Ajout des barres des nouveaux ennemis
  for n = 1, #EnemyMod.listEnemies do
    --création des barres hp/energy
    local e = EnemyMod.listEnemies[n]
    local hasABarHp = false
    local hasABarEnergy = false

    --On vérifie si l'ennemi a déjà une barre
    for o = 1, #groupBarHp.elements do
      local bar = groupBarHp.elements[o]
      if e.id == bar.id then
        hasABarHp = true
        break
      end
    end

    --On en crée une dans le cas contraire
    if hasABarHp == false then
      AddBarEnemy(e, "hp")
    end

    --Idem pour l'energy des drones
    if e.type == 4 then
      for o = 1, #groupBarEnergy.elements do
        local bar = groupBarEnergy.elements[o]
        if e.id == bar.id then
          hasABarEnergy = true
          break
        end
      end

      if hasABarEnergy == false then
        AddBarEnemy(e, "energy")
      end
    end
  end

  --update des barres
  for n = 1, #groupBarHp.elements do
    local bar = groupBarHp.elements[n]
    for i = 1, #EnemyMod.listEnemies do
      local e = EnemyMod.listEnemies[i]
      if e.id == bar.id then
        bar:setValue(e.hp)
        bar.setPosition(e.x - e.w / 2, e.y - e.h / 2 - 10)
      end
    end
  end

  for n = 1, #groupBarEnergy.elements do
    local bar = groupBarEnergy.elements[n]
    for i = 1, #EnemyMod.listEnemies do
      local e = EnemyMod.listEnemies[i]
      if e.id == bar.id then
        bar:setValue(e.stockEnergy)
        bar.setPosition(e.x - e.w / 2, e.y - e.h / 1.25 - 10)
      end
    end
  end

  --Le gui player
  --Les ennemis restants
  local textEnemies = "Enemies remaining: " .. tostring(EnemyMod.enemiesStock)
  GuiGame.gameGroup.elements[2].elements[2]:updateText(textEnemies)

  --Le score du joueur
  local scoreText = "Enemies killed: " .. tostring(EnemyMod.scorePlayer)
  GuiGame.gameGroup.elements[2].elements[3]:updateText(scoreText)

  --Les golds du joueur
  local goldText = "Golds: " .. tostring(Tank.goldStock)
  GuiGame.gameGroup.elements[2].elements[4]:updateText(goldText)

  --Les charactéristiques des bullets
  for n = 13, #GuiGame.gameGroup.elements[2].elements do
    local btnChar = GuiGame.gameGroup.elements[2].elements[n]
    if btnChar.isPressed then
      UpMod.upgradeChar(btnChar.idBul, btnChar.idChar)
      if btnChar.idChar < 4 then
        signBonus = "+"
      else
        signBonus = "-"
      end
      local char = UpMod.listBul[btnChar.idBul][btnChar.idChar]
      local textChar = tostring(char.lvl) .. "/" .. signBonus .. tostring(char.bonus)
      GuiGame.gameGroup.elements[2].elements[n]:updateLabel(textChar)
    end
  end

  --L'arme équipée
  local currWeaponImage = ShotMod.LST_IMGS_SHOTS_ALLY[Tank.currentWeapon]
  local borderPanel = GuiGame.gameGroup.elements[2].elements[#GuiGame.gameGroup.elements[2].elements - 1]
  local panelWeapon = GuiGame.gameGroup.elements[2].elements[#GuiGame.gameGroup.elements[2].elements]
  panelWeapon:setImage(currWeaponImage)
  panelWeapon.setPosition(
    borderPanel.x + (borderPanel.w - panelWeapon.w) / 2,
    borderPanel.y + (borderPanel.h - panelWeapon.h) / 2
  )

end

function GuiGame.drawBarsGameGroup()
  GuiGame.gameGroup.hpBarsGroup:draw()
  GuiGame.gameGroup.energyBarsGroup:draw()
end

--Fonctions du breakGroup
function GuiGame.loadBreakGroup()
  GuiGame.breakGroup = GCGUI.newGroup()
  local W = SettingsMod.screenW - SettingsMod.MARGIN_GUI_PLAYER

  local breakButtonRestart =
    GCGUI.newButton(W / 3 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "New Game", GCGUI.font)
  breakButtonRestart:setImage(imageButton.image)

  local breakButtonMenu =
    GCGUI.newButton(W - W / 3 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "Menu", GCGUI.font)
  breakButtonMenu:setImage(imageButton.image)

  local text = "Pause"
  local pauseText = GCGUI.newText(0, 0, W, 300, text, GCGUI.font, "center", "center")

  GuiGame.breakGroup:addElement(breakButtonRestart)
  GuiGame.breakGroup:addElement(breakButtonMenu)
  GuiGame.breakGroup:addElement(pauseText)
end

function GuiGame.updateBreakGroup(dt)
  GuiGame.breakGroup:update(dt)
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
    SettingsMod.screenW - SettingsMod.screenW / 3 - imageButton.w / 2,
    250,
    imageButton.w,
    imageButton.h,
    "New Game",
    GCGUI.font
  )
  gameOverButtonRestart:setImage(imageButton.image)

  local gameOverButtonMenu =
    GCGUI.newButton(SettingsMod.screenW / 3 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "Menu", GCGUI.font)
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

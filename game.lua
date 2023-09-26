local game = {}

local SettingsMod = require("settings")
local GoldMod = require("gold")
local DepositMod = require("deposit")
local ExplodeModule = require("explodeModule")
local MiningModule = require("miningModule")
local Tank = require("tank")
local EnemyModule = require("enemyModule")
local ShotModule = require("shotModule")
local GuiGame = require("guiGame")

local GameMode

local function resetModules()
  GuiGame.resetGui()
  Tank.reset()
  EnemyModule.reset()
  ShotModule.listShots = nil
  ExplodeModule.listExplodes = nil
  GoldMod.listCoin = nil
end

local function startNewGame()
  Tank.load()
  ShotModule.load()
  EnemyModule.load()
  MiningModule.load(Tank)
  ExplodeModule.load()
  GoldMod.load()
  GuiGame.loadGameGroup()
end

function game.init()
  GuiGame.loadMenuGroup()
  GameMode = "menu"
end

function game.update(dt)
  if GameMode == "menu" then
    --elseif GameMode == "setGame"
    GuiGame.updateMenuGroup(dt)

    if GuiGame.menuGroup.elements[1].isPressed then
      GameMode = "game"
      startNewGame()
    end
  elseif GameMode == "game" then
    --elseif GameMode == "break" then
    --changement si Pause
    --Game
    ExplodeModule.update(dt)
    Tank.update(dt)
    EnemyModule.update(dt, Tank)
    ShotModule.update(dt)
    MiningModule.update()
    GoldMod.update(dt)
    GuiGame.updateGameGroup(dt)

    --changement si victoire ou defaite (priorité à la défaite en cas d'égalité)
    if Tank.gameOver then
      GameMode = "gameOver"
      GuiGame.loadGameOverGroup()
    elseif EnemyModule.playerVictory then
      GameMode = "victory"
      GuiGame.loadVictoryGroup()
    end
  elseif GameMode == "victory" then
    GuiGame.updateVictoryGroup(dt)

    if GuiGame.victoryGroup.elements[1].isPressed then
      resetModules()
      GameMode = "game"
      startNewGame()
    elseif GuiGame.victoryGroup.elements[2].isPressed then
      resetModules()
      GameMode = "menu"
      GuiGame.loadMenuGroup()
    end
  elseif GameMode == "gameOver" then
    GuiGame.updateGameOverGroup(dt)

    if GuiGame.gameOverGroup.elements[1].isPressed then
      resetModules()
      GameMode = "game"
      startNewGame()
    elseif GuiGame.gameOverGroup.elements[2].isPressed then
      resetModules()
      GameMode = "menu"
      GuiGame.loadMenuGroup()
    end
  end
end

function game.draw()
  if GameMode == "menu" then
    GuiGame.menuGroup:draw()
  elseif GameMode == "game" then
    --elseif GameMode == "break" then
    ShotModule.draw()
    MiningModule.draw()
    DepositMod.draw()
    GoldMod.draw()
    Tank.draw()
    EnemyModule.draw()
    ExplodeModule.draw()
    GuiGame.gameGroup:draw()
    GuiGame.gameGroup.hpBarsGroup:draw()
  elseif GameMode == "victory" then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    ShotModule.draw()
    MiningModule.draw()
    DepositMod.draw()
    GoldMod.draw()
    Tank.draw()
    EnemyModule.draw()
    love.graphics.setColor(1, 1, 1)
    GuiGame.victoryGroup.draw()
  elseif GameMode == "gameOver" then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    ShotModule.draw()
    MiningModule.draw()
    DepositMod.draw()
    GoldMod.draw()
    EnemyModule.draw()
    love.graphics.setColor(1, 1, 1)
    GuiGame.gameOverGroup.draw()
  end
end

function love.keypressed(key)
  if key == "escape" then
    if GameMode == "menu" then
      love.event.quit()
    elseif GameMode == "game" then
      resetModules()
      GameMode = "menu"
      GuiGame.loadMenuGroup()
    end
  end
end

return game

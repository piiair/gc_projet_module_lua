local game = {}



InfosMod = require("infos")
GuiGame = require("guiGame")
Tank = require("tank")
ShotModule = require("shotModule")
EnemyModule = require("enemyModule")
ExplodeModule = require("explodeModule")

local GameMode

local function resetModules()
  GuiGame.resetGui()
  Tank.reset()
  EnemyModule.reset()
  ShotModule.listShots = nil
  ExplodeModule.listExplodes = nil
end

local function startNewGame()
  Tank.load()
  ShotModule.load()
  EnemyModule.load()
  ExplodeModule.load()
  GuiGame.loadGameGroup()
end

function game.init()
  GuiGame.loadMenuGroup()
  GameMode = "menu"
end

function game.update(dt)
  if GameMode == "menu" then
    GuiGame.updateMenuGroup(dt)

    if GuiGame.menuGroup.elements[1].isPressed then
      GameMode = "game"
      startNewGame()
    end
  --elseif GameMode == "setGame"
  elseif GameMode == "game" then
    --changement si Pause
    --Game
    ExplodeModule.update(dt)
    ShotModule.update(dt)
    Tank.update(dt)
    EnemyModule.update(dt, Tank.x, Tank.y)
    GuiGame.updateGameGroup(dt)

    --changement si victoire ou defaite
    if EnemyModule.playerVictory then
      GameMode = "victory"
      GuiGame.loadVictoryGroup()
    elseif Tank.gameOver then
      GameMode = "gameOver"
      GuiGame.loadGameOverGroup()
    end

  --elseif GameMode == "break" then
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
    Tank.draw()
    EnemyModule.draw()
    ExplodeModule.draw()
    GuiGame.gameGroup.draw()
  elseif GameMode == "victory" then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    ShotModule.draw()
    Tank.draw()
    EnemyModule.draw()

    love.graphics.setColor(1, 1, 1, 0.5)
    GuiGame.victoryGroup.draw()
  elseif GameMode == "gameOver" then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    ShotModule.draw()
    EnemyModule.draw()

    love.graphics.setColor(1, 1, 1, 0.5)
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

  if key == "return" then
    if GameMode == "gameOver" then
      GameMode = "game"
      startNewGame()
    end
  end
end

return game
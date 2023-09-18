if pcall(require, "lldebugger") then
  require("lldebugger").start()
end

io.stdout:setvbuf("no")

love.window.setMode(1080, 720)
--love.window.setTitle("Tank quelque chose")
local MouseImage = love.graphics.newImage("images/cursor.png")
local MouseCursor = love.mouse.newCursor("images/cursor.png", MouseImage:getWidth() / 2, MouseImage:getHeight() / 2)
love.mouse.setCursor(MouseCursor)

GuiGame = require("guiGame")
Tank = require("tank")
ShotModule = require("shotModule")
EnemyModule = require("enemyModule")
ExplodeModule = require("explodeModule")

local WIDTH = love.graphics.getWidth()
local HEIGHT = love.graphics.getHeight()
local GameMode

function resetModules()
  GuiGame.resetGui()
  Tank.reset()
  EnemyModule.reset()
  ShotModule.listShots = nil
  ExplodeModule.listExplodes = nil
end

function love.load()
  GuiGame.loadMenuGroup()
  GameMode = "menu"
end

function startNewGame()
  Tank.load()
  ShotModule.load()
  EnemyModule.load()
  ExplodeModule.load()
  GuiGame.loadGameGroup()
end

function love.update(dt)
  if GameMode == "menu" then
    GuiGame.updateMenuGroup(dt)

    if GuiGame.menuGroup.elements[1].isPressed then
      GameMode = "game"
      startNewGame()
    end
  elseif GameMode == "game" then
    --changement si Pause
    --elseif GameMode == "break" then
    --Game
    Tank.update(dt)
    EnemyModule.update(dt, Tank.x, Tank.y)
    ExplodeModule.update(dt)
    ShotModule.update(dt)
    GuiGame.updateGameGroup(dt)

    --changement si victoire ou defaite
    if EnemyModule.playerVictory then
      GameMode = "victory"
      GuiGame.loadVictoryGroup()
    elseif Tank.gameOver then
      GameMode = "gameOver"
      GuiGame.loadGameOverGroup()
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

function love.draw()
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

if pcall(require, "lldebugger") then
  require("lldebugger").start()
end

io.stdout:setvbuf("no")

local GuiGame = require("guiGame")
local Tank = require("tank")
local ShotModule = require("shotModule")
local EnemyModule = require("enemyModule")

local WIDTH, HEIGHT
local GameMode

function love.load()
  love.window.setMode(1080, 720)

  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()

  GuiGame.loadGui()

  GameMode = "menu"
end

function love.update(dt)
  if GameMode == "menu" then
    GuiGame.menuGroup:update(dt)

    if GuiGame.menuGroup.elements[1].isPressed then
      GameMode = "game"
      Tank.loadTank()
      ShotModule.loadModule()
      EnemyModule:loadModule()
    end
  elseif GameMode == "game" then
    ShotModule.updateShots(dt)
    Tank.updateTank(dt)
    EnemyModule.updateEnemies(dt, Tank.x, Tank.y)
  --elseif GameMode == "break" then

  --elseif GameMode == "victory" then

  --elseif GameMode == "gameOver" then
  end
end

function love.draw()
  if GameMode == "menu" then
    GuiGame.menuGroup:draw()
  elseif GameMode == "game" then
    ShotModule.drawShots()
    Tank.drawTank()
    EnemyModule.drawEnemies()
  --elseif GameMode == "break" then

  --elseif GameMode == "victory" then

  --elseif GameMode == "gameOver" then
  end
end

function love.keypressed(key)
  if key == "escape" then
    if GameMode == "menu" then
      love.event.quit()
    elseif GameMode == "game" then
      GameMode = "menu"
    end
  end
end

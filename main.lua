io.stdout:setvbuf('no')

local GuiGame = require("gameGui")

local WIDTH, HEIGHT
local GameMode

function love.load()
  love.window.setMode(1000, 700)
  
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
  
  GuiGame:loadGui(WIDTH, HEIGHT)
  
  GameMode = "menu"
end

function love.update(dt)
  
  if GameMode == "menu" then
    GuiGame.menuGroup:update(dt)
    
    if GuiGame.menuGroup.elements[1].isPressed then
      GameMode = "game"
    end
  elseif GameMode == "game" then
  
  elseif GameMode == "break" then
  
  elseif GameMode == "victory" then
  
  elseif GameMode == "gameOver" then

  end
  
end

function love.draw()
  
  if GameMode == "menu" then
    GuiGame.menuGroup:draw()
  elseif GameMode == "bame" then
  
  elseif GameMode == "break" then
  
  elseif GameMode == "victory" then
  
  elseif GameMode == "gameOver" then

  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  
  if key == "w" then
    if GameMode == "game"
  end
end
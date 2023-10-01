if pcall(require, "lldebugger") then
  require("lldebugger").start()
end

io.stdout:setvbuf("no")

local Game = require("game")

function love.load()
  Game.init()
end

function love.update(dt)
  Game.update(dt)
end

function love.draw()
  Game.draw()
end




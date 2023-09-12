local GuiGame = {}

local GCGUI = require("GCGUI")

local WIDTH, HEIGHT
local imageButton = {}
imageButton.image = love.graphics.newImage("images/button.png")
imageButton.w = imageButton.image:getWidth()
imageButton.h = imageButton.image:getHeight()

GuiGame.menuGroup = GCGUI.newGroup()
GuiGame.gameGroup = GCGUI.newGroup()
GuiGame.gameOverGroup = GCGUI.newGroup()

function GuiGame.loadGui()
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
  
  local menuButtonPlay = GCGUI.newButton(WIDTH/2 - imageButton.w / 2, 250, imageButton.w, imageButton.h, "Play", GCGUI.font)
  menuButtonPlay:setImage(imageButton.image)
  
  GuiGame.menuGroup:addElement(menuButtonPlay)
end

return GuiGame





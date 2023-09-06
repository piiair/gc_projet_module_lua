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

function GuiGame:loadGui(pWidth, pHeight)
  WIDTH = pWidth
  HEIGHT = pHeight
  
  local menuButtonPlay = GCGUI.newButton(WIDTH/2 - imageButton.w / 2, 150, imageButton.w, imageButton.h, "Play", GCGUI.font, "center", "center")
  menuButtonPlay:setImages(imageButton.image, imageButton.image, imageButton.image)
  
  GuiGame.menuGroup:addElement(menuButtonPlay)
  
end
  

return GuiGame
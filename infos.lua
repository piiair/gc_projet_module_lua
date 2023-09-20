local infos = {}

--La fenêtre
love.window.setMode(1080, 720)
--love.window.setTitle("Tank quelque chose")
infos.screenW = love.graphics.getWidth()
infos.screenH = love.graphics.getHeight()

--La souris
local MouseImage = love.graphics.newImage("images/cursor.png")
local MouseCursor = love.mouse.newCursor("images/cursor.png", MouseImage:getWidth() / 2, 
MouseImage:getHeight() / 2)

love.mouse.setCursor(MouseCursor)

return infos
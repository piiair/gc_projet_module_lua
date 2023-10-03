local settings = {}

--math.randomseed(os.time())

--La fenêtre
love.window.setMode(1280, 720)
--love.window.setTitle("Tank quelque chose")
settings.MARGIN_GUI_PLAYER = 300
settings.screenW = love.graphics.getWidth()
settings.screenH = love.graphics.getHeight()

--La souris
local MouseImage = love.graphics.newImage("images/cursor.png")
local MouseCursor = love.mouse.newCursor("images/cursor.png", MouseImage:getWidth() / 2, MouseImage:getHeight() / 2)

love.mouse.setCursor(MouseCursor)

--Le son
love.audio.setVolume(0.1)

return settings

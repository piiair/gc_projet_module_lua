local GCGUI = {}

GCGUI.font = love.graphics.newFont("images/JosefinSans-Bold.ttf", 22)
--créer un ouvel élément
local function newElement(pX, pY)
  local myElement = {}
  myElement.x = pX
  myElement.y = pY
  myElement.visible = true 
  
  --function myElement:update(dt)
    --print("newElement / update / not implemented")
  --end
  
  --function myElement:draw()
   -- print("newElement / draw / not implemented")
  --end
  
  function myElement:setVisible(pVisible)
    self.visible = pVisible
  end
  
  return myElement
end


function GCGUI.newGroup()
  local myGroup = {}
  myGroup.elements = {}
  
  --ajouter un élément au groupe 
  function myGroup:addElement(pElement)
    table.insert(self.elements, pElement)
  end
  
  --gérer la visibilité
  function myGroup:setVisible(pVisible)
    for n, v in pairs(myGroup.elements) do
      v:setVisible(pVisible)
    end
  end
  
  --update
  function myGroup:update(dt)
    for n, v in pairs(myGroup.elements) do
      if v:update() == "function" then
        v:update(dt)
      end
    end
  end
  
  --draw
  function myGroup:draw()
    love.graphics.push()
    for n, v in pairs(myGroup.elements) do 
      if v:draw() == "function" then
        v:draw()
      end
    end
    love.graphics.pop()
  end

  return myGroup
end

function GCGUI.newPanel(pX, pY, pW, pH, pColor)
  local myPanel = newElement(pX, pY)
  myPanel.w = pW
  myPanel.h = pH
  myPanel.color = pColor
  myPanel.image = nil
  myPanel.listEvents = {}
  
  myPanel.isHover = false
  
  function myPanel:setEvent(pEventType, pFunction)
    self.listEvents[pEventType] = pFunction
  end
  
  
  function myPanel:setImage(pImage)
    myPanel.image = love.graphics.newImage(pImage)
    myPanel.w = myPanel.image:getWidth()
    myPanel.h = myPanel.image:getHeight()
  end
  
  function myPanel:updatePanel(dt)
    
    --vérification hover
    local mx, my = love.mouse.getPosition()
    if mx > self.x and mx < self.x + self.w and my > self.y and my < self.y + self.h then
      if self.isHover == false then
        self.isHover = true
        if self.listEvents["hover"] ~= nil then
          self.listEvents["hover"]("begin")
        end
      end
    else
      if self.isHover == true then
        self.isHover = false
        if self.listEvents["hover"] ~= nil then
          self.listEvents["hover"]("end")
        end
      end
    end
  end
  
  function myPanel:update(dt)
    self:updatePanel()
  end
  
  function myPanel.drawPanel()
    if myPanel.visible then
      if myPanel.color ~= nil then 
        love.graphics.setColor(myPanel.color[1], myPanel.color[2], myPanel.color[3], myPanel.color[4])
      else
        love.graphics.setColor(1, 1, 1)
      end
      
      
      if myPanel.image == nil then
        love.graphics.rectangle("fill", myPanel.x, myPanel.y, myPanel.w, myPanel.h)
      else
        love.graphics.draw(myPanel.image, myPanel.x, myPanel.y)
      end
      
    end
  end 
  
  function myPanel:draw()
    if myPanel.visible == false then return end
    myPanel:drawPanel()
    love.graphics.setColor(1, 1, 1)
  end
  
  return myPanel
end

function GCGUI.newText(pX, pY, pW, pH, pText, pFont, pHAlign, pVAlign)
  local myText = GCGUI.newPanel(pX, pY, pW, pH)
  myText.text = pText
  myText.font = pFont
  myText.textW = pFont:getWidth(pText)
  myText.textH = pFont:getHeight(pText)
  myText.hAlign = pHAlign
  myText.vAlign = pVAlign
  
  function myText:updateText(pNewText)
    self.text = pNewText
  end
  
  function myText:draw()
    if self.visible then 
      love.graphics.setColor(1, 1, 1)
      love.graphics.setFont(self.font)
      local x = self.x
      local y = self.y
      
      if self.hAlign == "center" then
        x = x + (self.w - self.textW) / 2
      end
      
      if self.vAlign == "center" then
        y = y + (self.h - self.textH) / 2
      end
      
      love.graphics.print(self.text, x, y)
    end
  end
  
  return myText
end

function GCGUI.newButton(pX, pY, pW, pH, pText, pFont, pColor)
  local myButton = GCGUI.newPanel(pX, pY, pW, pH, pColor)
  myButton.text = pText
  --myButton.font = pFont
  myButton.label = GCGUI.newText(pX, pY, pW, pH, pText, pFont, "center", "center")
  
  myButton.isPressed = false
  myButton.oldButtonState = false
  
  myButton.imgDefault = nil 
  myButton.imgHover = nil
  myButton.imgPressed = nil
  
  --initialisation des images du bouton
  function myButton:setImages(pID, pIH, pIP)
    myButton.imgDefault = pID
    myButton.imgHover = pIH
    myButton.imgPressed = pIP
    myButton.w = pID:getWidth()
    myButton.h = pID:getHeight()
  end
  
  --update button
  function myButton:update(dt)
    
    self:updatePanel(dt)
    
    if self.isHover and love.mouse.isDown(1) and self.isPressed == false and self.oldButtonState == false then
      self.isPressed = true
      if self.listEvents["pressed"] ~= nil then
        self.listEvents["pressed"](self.text)
      end
    else
      if self.isPressed and love.mouse.isDown(1) == false then 
        self.isPressed = false
      end
    end
    
    self.oldButtonState = love.mouse.isDown(1)
  end
  
  --draw button 
  function myButton:draw()
    if self.visible then
      love.graphics.setColor(1, 1, 1)
      if self.isPressed then
        
        if self.imgPressed == nil then 
          self:drawPanel()
          love.graphics.setColor(0.1, 0.1, 0.1, 1)
          love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
        else
          love.graphics.draw(self.imgPressed, self.x, self.y)
        end
        
      elseif self.isHover then
        
        if self.imgHover == nil then
          self:drawPanel()
          love.graphics.setColor(0.1, 0.1, 0.1)
          love.graphics.rectangle("line", self.x+2, self.y+2, self.w-4, self.h-4)
        else
          love.graphics.draw(self.imgHover, self.x, self.y)
        end
        
      else
        
        if self.imgDefault == nil then
          self:drawPanel()
        else
          love.graphics.draw(self.imgDefault, self.x, self.y)
        end
        
      end
      
      self.label:draw()
      love.graphics.setColor(1, 1, 1)
    end
  end
  
  return myButton
end

function GCGUI.newCheckbox(pX, pY, pW, pH)
  local myCheckbox = GCGUI.newPanel(pX, pY, pW, pH)
  myCheckbox.imgUp = nil
  myCheckbox.imgDown = nil
  
  myCheckbox.isPressed = false
  myCheckbox.oldButtonState = false
  
  function myCheckbox:setImages(pIUp, pIDown)
    myCheckbox.imgUp = pIUp
    myCheckbox.imgDown = pIDown
    myCheckbox.w = pIUp:getWidth()
    myCheckbox.h = pIUp:getHeight()
  end
  
  function myCheckbox:update(dt)
    self:updatePanel(dt)
    
    if self.isHover and love.mouse.isDown(1) and self.isPressed == false and self.oldButtonState == false  then
      self.isPressed = true
      if self.listEvents["pressed"] ~= nil then
        self.listEvents["pressed"](self.isPressed)
      end
    elseif self.isHover and love.mouse.isDown(1) and self.isPressed == true and self.oldButtonState == false then
      self.isPressed = false
      if self.listEvents["pressed"] ~= nil then
        self.listEvents["pressed"](self.isPressed)
      end
    end
    
    self.oldButtonState = love.mouse.isDown(1)
  end
  
  function myCheckbox:draw()
    love.graphics.setColor(255, 255, 255)
    if self.isPressed then
      
      if self.imgDown == nil then
        self:drawPanel()
        love.graphics.setColor(255, 0, 0)
        love.graphics.rectangle("line", self.x+2, self.y+2, self.w-4, self.h-4)
      else
        love.graphics.draw(self.imgDown, self.x, self.y)
      end
      
    else
    
      if self.imgUp == nil then
        self:drawPanel()
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle("line", self.x+2, self.y+2, self.w-4, self.h-4)
      else
        love.graphics.draw(self.imgUp, self.x, self.y)
      end
     
    end
  end
  
  return myCheckbox
end


function GCGUI.newProgressBar(pX, pY, pW, pH, pMax, pColorOut, pColorIn)
  local myProgressBar = GCGUI.newPanel(pX, pY, pW, pH, pColorOut)
  myProgressBar.colorOut = pColorOut
  myProgressBar.colorIn = pColorIn
  myProgressBar.max = pMax
  myProgressBar.value = pMax
  myProgressBar.imgBack = nil 
  myProgressBar.imgBar = nil 
  
  function myProgressBar:setImages(pImgBack, pImgBar)
    self.imgBack = pImgBack
    self.imgBar = pImgBar
    self.w = pImgBack:getWidth()
    self.h = pImgBack:getHeight()
  end
  
  function myProgressBar:setValue(pValue)
    if pValue >= 0 and pValue <= self.max then
      self.value = pValue
    else
      print("myProgressBar:setValue error - out of range")
    end
  end
  
  function myProgressBar:setColorIn(pTableColor)
    self.colorIn = {}
    for n = 1, #pTableColor do
      self.colorIn[n] = pTableColor[n]
    end
  end
  
  function myProgressBar:setMax(pMax)
    self.max = pMax
  end
  
  function myProgressBar:draw()
    self:drawPanel()
    if self.visible then
      local barSize = (self.w - 2) * (self.value / self.max)
      if self.imgBack ~= nil and self.imgBar ~= nil then
        love.graphics.draw(self.imgBack, self.x, self.y)
        local barQuad = love.graphics.newQuad(0, 0, barSize, self.h, self.w, self.h)
        love.graphics.draw(self.imgBar, barQuad, self.x, self.y)
      else
        if self.colorOut ~= nil then
          love.graphics.setColor(self.colorIn[1], self.colorIn[2], self.colorIn[3])
        else
          love.graphics.setColor(1, 1, 1)
        end
        love.graphics.rectangle("fill", self.x + 1, self.y + 1, barSize, self.h - 2)
        love.graphics.setColor(1, 1, 1)
      end
    end
    
  end

  return myProgressBar
end

return GCGUI
local GUI = {}


local function newElement(pX, pY,pType)
  local myElement = {}
  myElement.X = pX
  myElement.Y = pY
  myElement.type = pType
  function myElement:draw()
    --print("newElement / draw / Not implemented")
  end
  function myElement:setVisible(pVisible)
    self.Visible = pVisible
  end
  
  function myElement:update(dt)
    --print("newElement / update / Not implemented")
  end 
  return myElement
end

function GUI.newGroup()
  local myGroup = {}
  myGroup.elements = {}
  myGroup.list = {}
  
  function myGroup:addElement(pElement)
    if self.elements[pElement.type] == nil then
      print(pElement.type)
      self.elements[pElement.type] = {}
    end
    table.insert(self.elements[pElement.type],pElement)
  end
  
  function myGroup:addList(pList)
    table.insert(self.list,pList)
  end
  
  
  function myGroup:removeElement(pElement)
    for i,e in ipairs(myGroup.elements) do
      if e == pElement then
        table.remove(self.elements,i)
        break
      end
    end
   
  end
  
  function myGroup:setVisible(pVisible)
    for n,v in pairs(myGroup.elements) do
      v:setVisible(pVisible)
    end
  end
  
  function myGroup:draw()
    love.graphics.push()
    for n,v in pairs(myGroup.elements) do
      for a,b in ipairs(myGroup.elements[n]) do
        b:draw(a)
      end
    for n,v in pairs(myGroup.list) do
      for a,b in ipairs(myGroup.list[n]) do
        b:draw(a)
      end
    
  end
    
    end
    love.graphics.pop()
  end
  function myGroup:update(dt)
    for n,v in pairs(myGroup.elements) do
      v:update(dt)
    end
  end



  return myGroup
end

function GUI.newPanel(pX, pY, pW, pH)
  
  local myPanel = newElement(pX, pY,"panel")
  myPanel.W = pW
  myPanel.H = pH
  myPanel.Image = nil

  function myPanel:setImage(pImage)
    self.Image = pImage
    self.W = pImage:getWidth()
    self.H = pImage:getHeight()
  end

  function myPanel:drawPanel(x)
    love.graphics.setColor(255,255,255)
    if self.Image == nil then
      love.graphics.rectangle("line", self.X, x*self.Y, self.W, self.H)
    else
      love.graphics.draw(self.Image, self.X, self.Y)
    end
  end

  function myPanel:draw(x)
    if self.Visible == false then return end
    self:drawPanel(x)
  end
  
  return myPanel
end

function GUI.newText(pX, pY, pW, pH, pText, pFont, pHAlign, pVAlign,pColor)
  local myText = GUI.newPanel(pX, pY, pW, pH)
  
  myText.Color = pColor
  myText.Text = pText
  myText.Font = pFont
  myText.TextW = pFont:getWidth(pText)
  myText.TextH = pFont:getHeight(pText)
  myText.HAlign = pHAlign
  myText.VAlign = pVAlign

  function myText:drawText()
    if myText.Color ~= nil then 
      love.graphics.setColor( myText.Color)
    else
    love.graphics.setColor(255,255,255)
  end
  
    love.graphics.setFont(self.Font)
    local x = self.X
    local y = self.Y
    if self.HAlign == "center" then

      x = x + ((self.W - self.TextW) / 2)
    end
    if self.VAlign == "center" then

    
      y = y + ((self.H - self.TextH) / 2)
    end
    love.graphics.print(self.Text, x, y)
  end

  function myText:draw()
    if self.Visible == false then return end
    self:drawText()
  end
  
  return myText
end

function GUI.newButton(pX, pY, pW, pH, pText, pFont, pColor)
  local myButton = GUI.newPanel(pX, pY, pW, pH)
  myButton.Text = pText
  myButton.Font = pFont
  myButton.Label = GUI.newText(pX, pY, pW, pH, pText, pFont,
                                 "center", "center", pColor)
  myButton.isHover = false
  myButton.isPressed = false
  myButton.oldButtonState = false


  myButton.imgDefault = nil
  myButton.imgHover = nil
  myButton.imgPressed = nil
  
    function myButton:setImages(pImageDefault, pImageHover, pImagePressed)
    self.imgDefault = pImageDefault
    self.imgHover = pImageHover
    self.imgPressed = pImagePressed
    self.W = pImageDefault:getWidth()
    self.H = pImageDefault:getHeight()
  end
  
  
  
  function myButton:draw()
    if self.isPressed then
      self:drawPanel()
      love.graphics.setColor(255,255,255,50)
      love.graphics.rectangle("fill",
                              self.X, self.Y, self.W, self.H)
    elseif self.isHover then
      self:drawPanel()
      love.graphics.setColor(255,255,255)
      love.graphics.rectangle("line",
                              self.X+2, self.Y+2, self.W-4, self.H-4)
    else
      self:drawPanel()
    end
    self.Label:draw()
  end


  function myButton:update(dt)
    local mx,my = love.mouse.getPosition()
    self.oldButtonState = love.mouse.isDown(1)
    if mx > self.X and mx < self.X + self.W and
       my > self.Y and my < self.Y + self.H then
      if self.isHover == false then
        self.isHover = true
        
      end
      
      print("---------------------------")
      print(tostring(self.isHover))
      print(tostring(love.mouse.isDown(1)))
      print(tostring(self.oldButtonState))
      print(tostring(self.isPressed))
      
      print("---------------------------")
      if self.isHover and love.mouse.isDown(1) and self.isPressed == false and self.oldButtonState == false then
          self.isPressed = true
        else
          if self.isPressed == true and love.mouse.isDown(1) == false then
          self.isPressed = false
          end
      end
    else
      print("En dehors")
      self.isHover = false

    end
      self.oldButtonState = love.mouse.isDown(1)

    
  end
  
  
  
  function myButton:draw()
    love.graphics.setColor(255,255,255)
    if self.isPressed then
      if self.imgPressed == nil then
        self:drawPanel()
        love.graphics.setColor(255,255,255,50)
        love.graphics.rectangle("fill", self.X, self.Y, self.W, self.H)
      else
        love.graphics.draw(self.imgPressed, self.X, self.Y)
      end
    elseif self.isHover then
      if self.imgHover == nil then
        self:drawPanel()
        love.graphics.setColor(255,255,255)
        love.graphics.rectangle("line",
                                self.X+2, self.Y+2, self.W-4, self.H-4)
      else
        love.graphics.draw(self.imgHover, self.X, self.Y)
      end
    else
      if self.imgDefault == nil then
        self:drawPanel()
      else
        love.graphics.draw(self.imgDefault, self.X, self.Y)
      end    
    end
    self.Label:draw()
  end
  
  return myButton
end




return GUI
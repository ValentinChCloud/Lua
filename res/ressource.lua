local ressource = {}


function ressource.newRessource(x,y,pW,pH,pType)
  local myElement = {}
  myElement.X =x
  myElement.Y = y
  myElement.W = pW
  myElement.H = pH
  myElement.type = pType
  myElement.isUsed= false
  myElement.room = nil

  function myElement:draw(x)
    love.graphics.setColor(255,255,255)
    
      if self.Image == nil then
        local trueX = x-1
        local offsetY = self.Y - (self.H*trueX) -trueX

        
        if self.isUsed == true then
          love.graphics.setColor(1,0,0)
          love.graphics.circle("fill",self.room.posXCenter,self.room.posYCenter,10)
        else
                  love.graphics.rectangle("fill", self.X, offsetY, self.W, self.H)
        end
      else
        love.graphics.draw(self.Image, self.X, self.Y)
      end
  end
  
  function myElement:setVisible(pVisible)
    self.Visible = pVisible
  end
  
  function myElement:update(dt)
    --print("newElement / update / Not implemented")
  end 
  

  
  
  
  return myElement
end

function ressource.newGroup()
  local myGroup = {}
  myGroup.elements = {}
  
  function myGroup:addElement(pElement)
    if self.elements[pElement.type] == nil then
      self.elements[pElement.type] = {}
    end
    table.insert(self.elements[pElement.type],pElement)
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
      local trueA = 0
      for a,b in ipairs(myGroup.elements[n]) do
        --if b.isUsed == true then
         -- trueA= trueA -1
       -- else
          
        b:draw(a)--+trueA)
       -- end
      end
      
    end
    love.graphics.pop()
  end
  function myGroup:update(dt)
    for n,v in pairs(myGroup.elements) do
      v:update(dt)
    end
  end
  
-- Debug
  function myGroup:affiche()
    for n,v in pairs(myGroup.elements) do
      for a,b in ipairs(myGroup.elements[n]) do
      end
    end
  end
  


  return myGroup
end









return ressource
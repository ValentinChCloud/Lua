-- Cette ligne permet d'afficher des traces dans la console pendant l'éxécution
io.stdout:setvbuf('no')

-- Empèche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
 
-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end
-- Cette ligne permet de déboguer pas à pas dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

--------------
-- GUI
--------------

local myGUI = require("res.GUI")


local groupGUI


local count
count = 1

local ressource = require("res.ressource")
local groupRessources 


--------------
-- Utils
--------------
  function Walkable(v)
      return v==1 or v==2 or v==3 or v==4
  end
  
  ------------
  -- Require
  ------------
local Grid = require("Jumper-master.jumper.grid")-- The grid class
local Pathfinder = require ("Jumper-master.jumper.pathfinder") -- The pathfinder lass
local grid = nil
    -- Creates a pathfinder object using Jump Point Search
local myFinder = nil
  
  
--------------
-- TileMap
--------------
local tilemap = {}
tilemap.map = {}
tilemap.line = 0
tilemap.column = 0
tilemap.w = 0
tilemap.h = 0
tilemap.posX = 0
tilemap.posY = 0
tilemap.wSmall= 0
tilemap.hSmall =0

-- La map version matric pour le path
local intTileMap = {}

--------------
-- Les Salles
--------------
local listSalles ={}

local LISTSALLESTOTAL =0
--------------
--Debug
--------------


--------------
--- ROOMTYPE
--------------
-- Quel type de salle, mur,porte,salle etc...
local ROOMTYPE = {}
ROOMTYPE.NONE =""
ROOMTYPE.WALL = "wall"
ROOMTYPE.DOOR ="door"
ROOMTYPE.ROOM = "room"
ROOMTYPE.INTERROOM= "interoom"
ROOMTYPE.START ="start"

-- Si c'est une salle, quelle est sa disposition. Simple, double, special
local ROOMDISPLAY = {}
ROOMDISPLAY[1] = "simpleCorridor"
ROOMDISPLAY[2]="doubleCorridor"
ROOMDISPLAY[3]="special"
ROOMDISPLAY["simpleCorridor"] = 2
ROOMDISPLAY["doubleCorridor"] = 4
ROOMDISPLAY["special"] = 4


--------------
-- SPRITES
----------

imgTile = love.graphics.newImage("Tile1.png")

-- CREW

imgCrew = love.graphics.newImage("crew.png")
imgCrewSize = {}
imgCrewSize.w = imgCrew:getWidth()/2
imgCrewSize.h = imgCrew:getHeight()/2
local myZombies = {}

imgZombie = love.graphics.newImage("zombie_1.png")

local imgZombieSize = {}
imgZombieSize.w =imgZombie:getWidth()/2
imgZombieSize.h = imgZombie:getHeight()/2



-- Map france
imgMap = love.graphics.newImage("images/France.png")

local animations = {}
function CreateAnimation(nameAnimation,pImageFile,pNFrames)
  
  local  animation = {}
  local i
  for i=1,pNFrames do
    local fileName = "images/"..pImageFile.."-"..i..".png"
    animation[i] = love.graphics.newImage(fileName)
    print("Loading frame "..fileName)
  end
  animations[nameAnimation]=animation
end

CreateAnimation("hpUP","Sprite",8)


local testAnimation = {}
testAnimation.frame = 1
testAnimation.animation= animations["hpUP"]
testAnimation.anime = function(dt)
  local i
  for i=1,#testAnimation.animation do
    testAnimation.frame = testAnimation.frame+(2*dt)
    if testAnimation.frame >= #testAnimation.animation +1 then
      testAnimation.frame =1 
    end
  end
end

testAnimation.draw = function()
  local frame = testAnimation.animation[math.floor(testAnimation.frame)]
  love.graphics.draw(frame,10,400,0,1,1)
end


--------------
-- Liste des objets cherchant un pathfinding
--------------
local inPathfinding = {}
--------------
-- Liste des survivants
--------------
local myCrew = {}

  
  



local STATE ={}
STATE.NONE =""
STATE.IDLE ="idle"
STATE.WALKING= "walking"
STATE.FIGHTING ="fighting"
STATE.FIGHTINGDOOR ="fightingdoor"
STATE.DOING ="doing"
STATE.DEAD = "dead"


-- IMG
imgStart = love.graphics.newImage("images/Depart.png")
imgEasy= love.graphics.newImage("images/Easy.png")
imgNormal= love.graphics.newImage("images/Normal.png")
imgHard= love.graphics.newImage("images/Hard.png")


imgCarte = love.graphics.newImage("images/CarteXL.png")
function DrawMap()
  love.graphics.draw(imgMap,0,0)
  love.graphics.draw(imgStart,400,160)
end




local savePlayer = {}
savePlayer.currentLevel =0
savePlayer.nbrCrew =0
savePlayer.resElect=0
savePlayer.resFood=0
savePlayer.resDefence =0


local LevelMap = {}

function IniLevelMap ()
  LevelMap.nbrNiveaux = 4
  LevelMap.niveaux = {}
  LevelMap.niveaux[1] = {}
  LevelMap.niveaux[1][1] = {}
  LevelMap.niveaux[1][1].posX= 400
  LevelMap.niveaux[1][1].posY = 160
  LevelMap.niveaux[1][1].img = imgStart
  LevelMap.niveaux[1][1].nextLevel = {}
  LevelMap.niveaux[1][1].difficulte = ""
  
  
  for i=1, LevelMap.nbrNiveaux do
	LevelMap.CreateStep(i)
  end
  
 
 
LevelMap.LastLevel = function ()
	LevelMap.niveaux[nbrNiveaux+1]= {}
	LevelMap.niveaux[nbrNiveaux+1].posX=0
	LevelMap.niveaux[nbrNiveaux+1].posY=0
	LevelMap.niveaux[nbrNiveaux+1].img = imgFinale
end
  

LevelMap.DrawMap = function()
    love.graphics.draw(imgMap,0,0)
    
    for i=1,#LevelMap.niveaux do
      for l=1,#LevelMap.niveaux[i] do
      
       love.graphics.draw(LevelMap.niveaux[i][l].img,LevelMap.niveaux[i][l].posX,LevelMap.niveaux[i][l].posY)
       love.graphics.print(LevelMap.niveaux[i][l].difficulte, LevelMap.niveaux[i][l].posX,LevelMap.niveaux[i][l].posY -20)
      end
    end
  end
  --ShelterMap.GenerateNextStep = function(pNbrStep)
  --  for i=1,pNbrStep do
   --   table.insert(ShelterMap[i].niveaux,)
   --   then
 
LevelMap.CreateStep = function(currentLevel)
     local nbrStepRandom
     local oldPosX = {}
     local ramdomXPos
     nbrStepRandom = math.random(1,3)
     LevelMap.niveaux[currentLevel+1] = {}
     for i=1,nbrStepRandom do
       LevelMap.niveaux[currentLevel+1][i] ={}
       
       ramdomXPos = math.random(215,600) 
        if i==1 then 
        
        else
        for n=1,#oldPosX do
            if math.abs(oldPosX[n] - ramdomXPos) <= imgStart:getWidth() then 
              ramdomXPos= ramdomXPos+math.abs(oldPosX[n]-ramdomXPos)*2 end
          end
        end
      
        LevelMap.niveaux[currentLevel+1][i].posX = ramdomXPos
        LevelMap.niveaux[currentLevel+1][i].posY = LevelMap.niveaux[currentLevel][1].posY +84 
        LevelMap.niveaux[currentLevel+1][i].difficulte =LevelMap.ChooseDifficulte()
        if LevelMap.niveaux[currentLevel+1][i].difficulte == "easy" then LevelMap.niveaux[currentLevel+1][i].img = imgEasy end
        if LevelMap.niveaux[currentLevel+1][i].difficulte == "normal" then LevelMap.niveaux[currentLevel+1][i].img = imgNormal end
        if LevelMap.niveaux[currentLevel+1][i].difficulte == "hard" then LevelMap.niveaux[currentLevel+1][i].img = imgHard end       
        
		-- Pour se souvenir des anciennes posX pour le current level
		table.insert(oldPosX, LevelMap.niveaux[currentLevel+1][i].posX)
		
		
    end
  end
  
-- Les gros niveaux amènenet forcément sur une carte mais la carte peut être différente??
-- Niveau normal difficulté normal chance de trouver des ressources normal
-- Niveau facile diffuclté simple chance de trouver ressource faible
-- Niveau dur difficulté dur chane de trouvé ressource élevé

LevelMap.ChooseDifficulte = function ()
  local random = math.random(1,100)
  if random <=20 then return "hard" end
  if random >20  and  random<= 80 then return "normal" end
  if random >80 then return "easy" end
end

LevelMap.MousePressed = function(x,y)
	local distanceX
	local distanceY
	local w = 
	local h 
	-- Plutot que de chercher dans tous les niveaux je vais demander just een fonction de là ou est 
	for i=1,#LevelMap.niveaux[savePlayer] do
		distanceX = math.abs(x-LevelMap.niveaux[savePlayer][i].posX)
		distanceY = math.abs(y-LevelMap.niveaux[savePlayer][i].posXY
		if distanceX < LevelMap.niveaux[savePlayer][i].img:getWidth() && distanceY < LevelMap.niveaux[savePlayer][i].img:getHeight() then
			LevelMap.LoadShelterMap(LevelMap.niveaux[savePlayer][i].difficulte)
		break
		end
	end
	
	

end 

LevelMap.LoadShelterMap = function (difficulte)
	


end



  
end







-- Ressemble = ShelterMap mais on regénère à chaque fois
local ShelterMap = {}

function IniShelterMap()
  ShelterMap.niveaux = {}
  ShelterMap.niveaux[1] = {}
  ShelterMap.niveaux[1][1] = {}
  ShelterMap.niveaux[1][1].posX= 660
  ShelterMap.niveaux[1][1].posY = 100
  ShelterMap.niveaux[1][1].img = imgStart
  ShelterMap.niveaux[1][1].nextLevel = {}
  
  
ShelterMap.DrawMap = function()
    love.graphics.draw(imgCarte,0,5)
    
    for i=1,#ShelterMap.niveaux do
      for l=1,#ShelterMap.niveaux[i] do

       love.graphics.draw(ShelterMap.niveaux[i][l].img,ShelterMap.niveaux[i][l].posX,ShelterMap.niveaux[i][l].posY)
       
      end
    end
end


ShelterMap.CreateStep = function(currentLevel)
     local nbrStepRandom
     local oldPosY = {}
     local ramdomXPos
     nbrStepRandom = math.random(1,5)
     ShelterMap.niveaux[currentLevel+1] = {}
     for i=1,nbrStepRandom do
       ShelterMap.niveaux[currentLevel+1][i] ={}
       
       ramdomYPos = math.random(120+(currentLevel*90),490) 
        if i==1 then 
        
        else
        for n=1,#oldPosY do
            if math.abs(oldPosY[n] - ramdomYPos) <= imgStart:getWidth() then 
              ramdomYPos= ramdomYPos+math.abs(oldPosY[n]-ramdomYPos)*2 end
          end
        end
      
        ShelterMap.niveaux[currentLevel+1][i].posX = ShelterMap.niveaux[currentLevel][1].posX -160
        ShelterMap.niveaux[currentLevel+1][i].posY = ramdomYPos
        ShelterMap.niveaux[currentLevel+1][i].img = imgStart
        table.insert(oldPosY, ShelterMap.niveaux[currentLevel+1][i].posY)
    end
  end
end



local SceneManager = {}
function IniSceneManager()
SceneManager.sceneActual= "niveau"
SceneManager.UpdateSceneManager = function(dt)

  if SceneManager.sceneActual == "title" then
    -- pas d'Update à faire
  elseif SceneManager.sceneActual == "niveau" then
    UpdateCrew(dt)
    UpdateZombies(dt)
    --groupGUI:update(dt)
    testAnimation.anime(dt)
  elseif SceneManager.sceneActual == "map" then
    
  end
  
end

SceneManager.DrawSceneManager = function()
  if SceneManager.sceneActual == "title" then
    DrawTitle()
  elseif SceneManager.sceneActual == "niveau" then
    DrawTiles()
    
    
      love.graphics.setColor(1,1,1)
  love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 100, 100)
    DrawZombies() 
    DebugDraw()
    DrawCrewMembers()  

    groupRessources:draw()
  elseif SceneManager.sceneActual == "map" then
    LevelMap.DrawMap()
    
  elseif SceneManager.sceneActual == "shelterMap" then
    
    ShelterMap.DrawMap()
    
  end

end






SceneManager.MousePressedManager = function()
  
  if SceneManager.sceneActual == "title" then
   --if key.presse
  else
    -- Les Draw habituel
  end
end

SceneManager.KeyPressedManager = function(key)

  
  if SceneManager.sceneActual == "title" then
    if key == "space" then
      -- On passe à la scene suivante
      -- pSceneActual == niveau
    end
  elseif  SceneManager.sceneActual == "map" then
    if key == "space" then
      
      LevelMap.CreateStep(count)
      count=count+1
    end
  elseif SceneManager.sceneActual == "shelterMap" then
      if key == "space" then
      
      ShelterMap.CreateStep(count)
      count=count+1
    end
  
    
    -- Les Draw habituel
  end
  
end

SceneManager.LoadMap = function()
  

end






end




function ChooseNameRandomly()
	local name = {'Alf','Bernard','Oupsy','Loki','Nobilis'}



	
	return name[math.random(0,#name)]
end



function AddCrew(pLine,pCol,speed)
  local newCrew = {}
  newCrew.type = "human"
  newCrew.name = "sam"
  newCrew.state = STATE.NONE
  newCrew.line =pLine
  newCrew.column =pCol
  newCrew.w =imgCrew:getWidth()
  newCrew.name = ChooseNameRandomly()
  newCrew.h = imgCrew:getHeight()
  --newCrew.posX =GetCenterOfTile(line,column)[1]
  newCrew.posX =GetCenterOfTile(pLine,pCol)[1]
 -- newCrew.posY =GetCenterOfTile(line,column)[2]
 newCrew.posY =GetCenterOfTile(pLine,pCol)[2]
  
  
  newCrew.path = nil
  newCrew.nodePosition =0
  newCrew.timer =0
  newCrew.speed =speed
  
  newCrew.target = nil
  
  newCrew.lightBonus = false
  
  
  newCrew.lengthPath=0
  -- Pour être enlevé facilement de la list de pathfinding
  newCrew.idMemory = tostring(newCrew)
  
  
  
  newCrew.destinationX = 0
  newCrew.destinationY =0
  newCrew.destinationL =0
  newCrew.destinationC =0

  table.insert(myCrew,newCrew)
 
 newCrew.isDead = false
 newCrew.health = 5
 newCrew.maxHealth = 5
  newCrew.takeDamage = function()
  newCrew.health = newCrew.health-1
      if newCrew.health <=0 then
        print("Un crew type : "..newCrew.type.." est mort")
        newCrew.isDead = true
        newCrew.state = STATE.DEAD
      end
  end 
    
    
    
  -- ATTACK PART
  newCrew.speedAttack = 2
  panelCrew = myGUI.newPanel(10,30,50,25)


end




function AddToListSalles(room)
  if listSalles[room.roomType] == nil then
    listSalles[room.roomType] = {}
  end
  table.insert(listSalles[room.roomType],room)
  LISTSALLESTOTAL = LISTSALLESTOTAL +1
end


function BuildRooms(nbrSalles)
  -- Generate dungeon
  listSalles = {}
  LISTSALLESTOTAL = 0
  -- Salle de départ choisi aléatoirment
  
  local nLineStart,nColumnStart
  nLineStart = math.random(1,math.floor(tilemap.line/2))*2
  nColumnStart =math.random(1,math.floor(tilemap.column/2))*2
  local salleStart = tilemap.map[nLineStart][nColumnStart]
  salleStart.roomType = ROOMTYPE.START
  salleStart.isLight = true
  AddToListSalles(salleStart)
  -- Debug
  pastouche =salleStart
  --Commence la liste des toutes mes salles actives
  --table.insert(listSalles,salleStart)
  
  
  -- Ensuite je peux commencer à creuse depuis la salle de départ
  GenerateRoom(nbrSalles)

end



  
function CreateWalls()
  for l=1,#intTileMap do
    for c=1,#intTileMap[l] do
      if intTileMap[l][c] ~= 9 then
      local compensoireL =0
      local compensoireC=0
      local compensoireUp=0
      local compensoireLeft=0
      if l==1 then compensoireL=1 end
      if c==1 then compensoireC=1 end
      if l==#intTileMap then compensoireLeft=-1 end
      if c==#intTileMap[l] then compensoireUp=-1 end

      
      
            if intTileMap[l+1+compensoireLeft][c] ==9 then            tilemap.map[l+1+compensoireLeft][c].roomType = ROOMTYPE.WALL end
            if intTileMap[l][c+1+compensoireUp] ==9 then tilemap.map[l][c+1+compensoireUp].roomType = ROOMTYPE.WALL   end
            if intTileMap[l+1+compensoireLeft][c+1+compensoireUp] ==9 then tilemap.map[l+1+compensoireLeft][c+1+compensoireUp].roomType = ROOMTYPE.WALL end
          if intTileMap[l-1+compensoireL][c] ==9 then tilemap.map[l-1+compensoireL][c].roomType = ROOMTYPE.WALL end
            if intTileMap[l][c-1+compensoireC] ==9 then tilemap.map[l][c-1+compensoireC].roomType = ROOMTYPE.WALL end
            if intTileMap[l-1+compensoireL][c-1+compensoireC] ==9 then tilemap.map[l-1+compensoireL][c-1+compensoireC].roomType = ROOMTYPE.WALL end
 end
    end
  end
  
end

-- Netoyer la tilemap des zones vides
function CleanUselessRoom()
  -- Function de la muerte ça donc bon, faut juste rajouter les bords
  for l=1,#intTileMap do
    for c=1,#intTileMap[l] do
        if c == #intTileMap[l]  or c==1 then
          -- On est au bord     
        else
          if l == #intTileMap or l==1 then
            --on est au bord on fait rien
          else
            if intTileMap[l+1][c] == 0 then
                if intTileMap[l][c+1] == 0 then
                    if intTileMap[l-1][c]== 0 then
                      if intTileMap[l][c-1] == 0 then
                          tilemap.map[l][c].roomType = ROOMTYPE.NONE
                          intTileMap[l][c] =9
                      end
                    end    
                  end  
            end
          end
        end
    end
  end
end


function CreateIntTileMap(mapT)
  for l=1,#mapT do
    intTileMap[l] = {}
    for c=1,#mapT[l] do
      local salleType = mapT[l][c].roomType
      if salleType == ROOMTYPE.WALL then
        intTileMap[l][c] = 0
      elseif salleType == ROOMTYPE.ROOM then
        intTileMap[l][c] = 1
      elseif salleType == ROOMTYPE.INTERROOM then
        intTileMap[l][c] = 2
      elseif salleType == ROOMTYPE.DOOR then
          if mapT[l][c].isOpen == true then
            intTileMap[l][c] = 3
          else
            intTileMap[l][c] = 8
          end
      elseif salleType == ROOMTYPE.START then
        intTileMap[l][c] = 4
      elseif salleType == ROOMTYPE.NONE then
        intTileMap[l][c] = 9
      end
    end
  end
--CleanUselessRoom() 
CreateWalls()
grid = Grid(intTileMap) 
    -- Creates a pathfinder object using Jump Point Search
myFinder = Pathfinder(grid, 'JPS', Walkable) 
end

---------------------
-- FUNCTIONS
---------------------


function CreateSalle(pLine,pColumn)
  local newSalle = {}
  -- Cord and size 
  newSalle.line = pLine
  newSalle.column = pColumn
  newSalle.posX =0
  newSalle.posY = 0
  newSalle.posXCenter = GetCenterOfTile(newSalle.line,newSalle.column)[1]
  newSalle.posYCenter =GetCenterOfTile(newSalle.line,newSalle.column)[2]
  newSalle.w =0
  newSalle.h =0
  
  
  
  -- Draw
  newSalle.couleur = {}
  newSalle.img= nil
  
  
  -- ROOMTYPE
  newSalle.roomType = ROOMTYPE.NONE
  newSalle.roomDisplay = ""
  
  
  -- CARAC
  newSalle.health = 2
  newSalle.isLight = false
  newSalle.isFood = false
  newSalle.isDefense = false
  
  newSalle.isDoor = false
  newSalle.isStart = false
  newSalle.isOpen = true
  newSalle.isWall = false
  newSalle.isBroken= false
  
  
  
  -- Si la pièce est une sièce spécial (+2salle) alors on lie les salles autour pour avoir les cordonné
  newSalle.roomLinked = {}
  



  
  newSalle.takeDamage = function()  
  newSalle.health = newSalle.health-1
      if newSalle.health <=0 then
        --print("Une salle type : "..newSalle.roomType.." est cassé")
        newSalle.isBroken = true
        if newSalle.roomType == ROOMTYPE.START then
        print("C'est la fiiiin vous avez perduuuuu")
        end
      end
  end
  return newSalle
end




function ConstructionSimple(directionX,directionY,salle,roomDisplay)
  -- Consctruction simple salle
  local newSalle = nil
  for n=1,roomDisplay.salleMin do
        -- Idée, j'ajoute une cord fois la direciton qui peut être positive/négative et je hceck les tile occupé ou non
        if tilemap.map[salle.line+(n*directionX)][salle.column+(n*directionY)].roomType ==ROOMTYPE.NONE and n%2 ~= 0 then
          -- On construit que le mur
          newSalle = tilemap.map[salle.line+(n*directionX)][salle.column+(n*directionY)]
          newSalle.roomType = ROOMTYPE.DOOR

          AddToListSalles(newSalle)
          --table.insert(listSalles,newSalle)
        elseif tilemap.map[salle.line+(n*directionX)][salle.column+(n*directionY)].roomType ~=ROOMTYPE.NONE then
          -- On fait rien
          
        else
          newSalle = tilemap.map[salle.line+(n*directionX)][salle.column+(n*directionY)]
         newSalle.roomType = ROOMTYPE.ROOM
         newSalle.roomDisplay = ROOMDISPLAY[1]
        AddToListSalles(newSalle)
        --table.insert(listSalles,newSalle)
          --On construit le mur et la salle
        end
        
  end
  
end



function ConstructionDouble(directionX,directionY,salle,roomDisplay)
  -- Consctruction simple Double
  local newSalle = nil
  local saveRoomCreated = {}
  
  for n=1,roomDisplay.salleMin do
        -- Idée, j'ajoute une cord fois la direciton qui peut être positive/négative et je hceck les tile occupé ou non
        if  n == 1 then
          -- On construit que le mur
          newSalle = tilemap.map[salle.line+(n*directionX)][salle.column+(n*directionY)]
          newSalle.roomType = ROOMTYPE.DOOR
           AddToListSalles(newSalle)
          --table.insert(listSalles,newSalle)
        elseif n%2 ~= 0 then
          newSalle = tilemap.map[salle.line+(n*directionX)][salle.column+(n*directionY)]
          newSalle.roomType = ROOMTYPE.INTERROOM
           AddToListSalles(newSalle)
           --table.insert(listSalles,newSalle)
        else
          newSalle = tilemap.map[salle.line+(n*directionX)][salle.column+(n*directionY)]
          newSalle.roomType = ROOMTYPE.ROOM
          newSalle.roomDisplay = ROOMDISPLAY[2]
          AddToListSalles(newSalle)
          --table.insert(listSalles,newSalle)
          table.insert(saveRoomCreated, newSalle)
        end
        
  end
  -- Pour chaque salle enregistré leur attribué une 
  for n=1,#saveRoomCreated do
    for  l=1,#saveRoomCreated do
      if saveRoomCreated[n].line ==  saveRoomCreated[l].line and saveRoomCreated[n].column ==  saveRoomCreated[l].column      then
            -- C'est la salle qu'on regarde actuellement on ne fait rien
      else

        -- On ajote la salle
        table.insert(saveRoomCreated[n].roomLinked,saveRoomCreated[l])
      end
    end
  end
end



function ConstructionIsPossible (directionX,directionY,salle,roomDisplay)
  
    --local isPossible = true
    if roomDisplay.name == "simpleCorridor" then
      -- Simple corridor, peut toujours être construit
    ConstructionSimple(directionX,directionY,salle,roomDisplay)
    elseif roomDisplay.name == "doubleCorridor" then
      local n
      local possible = true
      for n=1,2 do
        if tilemap.map[salle.line+(directionX*2*n)][salle.column+(directionY*2*n)].roomType == ROOMTYPE.ROOM or tilemap.map[salle.line+(directionX*2*n)][salle.column+(directionY*2*n)].roomType == ROOMTYPE.START  then
          -- Si toutes les 2 cases je tombe sur autre choses qu'un mur, je ne construits pas
          possible =false
          break
        end
      end
      
      -- Si je peux créer la salle, alors je la crée
      if possible then
        ConstructionDouble(directionX,directionY,salle,roomDisplay)
      end
    end
end




function DirectionIsAvailable(direction,salle,roomDisplay)
  local salleMin = roomDisplay.salleMin
  -- On vérifie si on est pas au bord d'une salle
  if direction == 1 and salle.line >salleMin then
    if ConstructionIsPossible(-1,0,salle,roomDisplay) then return true end
  elseif direction == 2 and salle.column <(tilemap.column-salleMin) then
    if ConstructionIsPossible(0,1,salle,roomDisplay) then return true end
  elseif direction == 3 and salle.line <(tilemap.line-salleMin) then
    if ConstructionIsPossible(1,0,salle,roomDisplay) then return true end
  elseif direction == 4 and salle.column >salleMin then
    if ConstructionIsPossible(0,-1,salle,roomDisplay) then return true end
  else
    --return false
  end
end

-- Dessine les membres d'équipage
function DrawZombies()
  local i
  for i=1,#myZombies do
    love.graphics.draw(imgZombie,myZombies[i].posX,myZombies[i].posY,0,2,2,imgZombieSize.w,imgZombieSize.h)
  end
  
end


function DrawCrewMembers()

  for e,c in ipairs(myCrew) do
    love.graphics.draw(imgCrew,c.posX,c.posY,0,1,1,imgCrewSize.w,imgCrewSize.h)

  end
end

-- Dessine les tuiles en fonctions de tilemap.map
function DrawTiles()
  for l=1,#tilemap.map do
    for c=1,#tilemap.map[l] do
      local x,y,w,h = tilemap.map[l][c].posX,tilemap.map[l][c].posY,tilemap.map[l][c].w,tilemap.map[l][c].h
      love.graphics.setColor(tilemap.map[l][c].couleur)
      love.graphics.rectangle("fill",x,y,w,h)
    end
  end
end

function DrawSalles()
  for l=1,#listSalles do
      local x,y,w,h = listSalles[l].posX,listSalles[l].posY,listSalles[l].w,listSalles[l].h
      love.graphics.setColor(listSalles[l].couleur)
      love.graphics.rectangle("fill",x,y,w,h)
  end
end

function DrawSalles2()
  for typE,table in pairs(listSalles) do
    for i=1,#listSalles[typE] do
      local x,y,w,h = listSalles[typeE][i].posX,listSalles[typeE][i].posY,listSalles[typeE][i].w,listSalles[typeE][i].h
      love.graphics.setColor(listSalles[typeE][i].couleur)
      love.graphics.rectangle("fill",x,y,w,h)
    end
  end
  
end





function GenerateRoom(nbrSalles)
  
    while LISTSALLESTOTAL < nbrSalles do
      local salle= nil
      -- On sélectione aléatoirement une salle, on ne peut pas creuse depuis certaines salles comme les portes
      if LISTSALLESTOTAL== 1 then 
        salle = listSalles[ROOMTYPE.START][1]
      else 
        
        salle = listSalles[ROOMTYPE.ROOM][math.random(1,#listSalles[ROOMTYPE.ROOM])]
      end
      local newSalle = nil
    
    -- 4 directions possible up,right,down,left
    local direction = math.random(1,4)
    
    -- Si typeRoom =1 == room de 1 
    -- Si typeRoom =2 == room de 2
    -- Si typeRoom =3 == salleSpéciale de 4x4
    local roomDisplay = RandomRoomDisplay(ROOMDISPLAY)

    -- Tester le type de salle qu'on veut générer
    -- On va dire que les salles 4x4 sont les salles spéciales de base, et donc en fait c'est composé de 4salles spécialles + 4 normal + au centre l'icone indiquant ce que c'est 
    

    DirectionIsAvailable(direction,salle,roomDisplay)
      -- Si bon on construit
      
      -- On peut continuer pour voir si on peut créer une salle
      -- Si réussi tester en fonction de la salle la création, donc en théorie salle et salle 2 c'est bon
      -- Test surtout pour salle spécial
      -- Mais enfaite faut faire un cas de génération de salle par display, car la salle 2 n'a pas de porte entre
      
      -- function tester si construction possible
      
    end
end






function GetCenterOfTile(pLine,pCol)
  local x = (tilemap.posX)
  local y = (tilemap.posY)
  if pCol%2 == 0 then
    x= x+ ((pCol/2)*tilemap.w)-(tilemap.w/2)
    x = x+ ((pCol/2) *tilemap.wSmall)
  else
    x = x+ (math.floor((pCol/2)) *tilemap.w)
    x = x+ (math.ceil((pCol/2 ))* tilemap.wSmall) - ((tilemap.wSmall)/2)
  end
    x =x+(1*pCol)
  
  if pLine%2 == 0 then
    y= y+ ((pLine/2)*tilemap.h)-(tilemap.h/2)
    y = y+ (((pLine/2)*(tilemap.hSmall)))
  else
    y = y+ (math.floor((pLine/2)) *tilemap.h)
    y = y+ (math.ceil((pLine/2 ))* (tilemap.hSmall)) - ((tilemap.hSmall)/2)
  end
  
  
    y =y+(1*pLine)
    
    
  local ret = {x,y}
  return ret

end


function GetCrew(pX,pY)
  local distanceX = 0
  local distanceY =0
  for n=1,#myCrew do
    distanceX = math.abs(pX-myCrew[n].posX)
    -- Moitié car origine au centre
    if distanceX<myCrew[n].w/2 then
      distanceY= math.abs(pY-myCrew[n].posY)
      if distanceY <myCrew[n].h/2 then
        return myCrew[n]
      end  
    end

  end
  return nil
end








function GetTile(pX,pY)
  local distanceX = 0
  local distanceY =0
  
  -- Bidouillage les tuiles sont pas centré sur leur origine
  -- Faut prendre la position +w/2 +h/2


  for typE,table in pairs(listSalles) do 

    for n=1,#listSalles[typE] do
      
    local resPosCentre = (listSalles[typE][n].posX+listSalles[typE][n].w/2)
    distanceX = math.abs(pX-resPosCentre)
    if distanceX<(listSalles[typE][n].w/2) then
      resPosCentre =(listSalles[typE][n].posY+listSalles[typE][n].h/2)
      distanceY= math.abs(pY-resPosCentre)
      if distanceY <(listSalles[typE][n].h/2) then
       return listSalles[typE][n]
      end  
    end
    end
  end
  --print("Je tape rien")
  return nil
end


function HowToDrawCrewMember()
  for e,c in ipairs(myCrew) do
  local pLine = c.line
  local pCol = c.column
  local x = (tilemap.posX)
  local y = (tilemap.posY)
  if pCol%2 == 0 then
    x= x+ ((pCol/2)*tilemap.w)-(tilemap.w/2)
    x = x+ ((pCol/2) *tilemap.wSmall)
  else
    x = x+ (math.floor((pCol/2)) *tilemap.w)
    x = x+ (math.ceil((pCol/2 ))* tilemap.wSmall) - ((tilemap.wSmall)/2)
  end
    x =x+(1*pCol)
  
  if pLine%2 == 0 then
    y= y+ ((pLine/2)*tilemap.h)-(tilemap.h/2)
    y = y+ (((pLine/2)*(tilemap.hSmall)))
  else
    y = y+ (math.floor((pLine/2)) *tilemap.h)
    y = y+ (math.ceil((pLine/2 ))* (tilemap.hSmall)) - ((tilemap.hSmall)/2)
  end
    y =y+(1*pLine)
    c.posX =x
    c.posY = y
  end
end

-- Determine comment dessiner les tuile, largeur,hauteur,couleur. Et change en fonction du fait si c'est un mur ou autre
function HowToDrawTile()
 
  local x,y = tilemap.posX,tilemap.posY
  local nLine,nColumn
  
  -- Variable temporaire qui vont me permettre de modifier la taille des salles et les transformer en porte/mur
  local hTmp = tilemap.h
  local wTmp= tilemap.w
  for nLine=1,tilemap.line do
    local bLignePaire = (nLine % 2 == 0)
    x=tilemap.posX
    for nColumn=1,tilemap.column do
      local bColonnePaire = (nColumn % 2 == 0)
      wTmp= tilemap.w
      hTmp = tilemap.h    
      -- Ligne paire + colonne impaire = mur vertical
      if bLignePaire == true and bColonnePaire == false  then
          wTmp= tilemap.wSmall
      end
      -- Ligne impaire + colonne paire = mur horizontal
      if bLignePaire == false and bColonnePaire == true  then
        hTmp  =tilemap.hSmall
      end
      -- Ligne Impaire + colonne imapire
      if bLignePaire == false and bColonnePaire == false then
        wTmp= tilemap.wSmall
        hTmp=tilemap.hSmall
      end
      -- Ligne pair + colonne paire
      if bLignePaire == true and bColonnePaire == true then
      end
      tilemap.map[nLine][nColumn].posX = x
      tilemap.map[nLine][nColumn].posY = y 
      tilemap.map[nLine][nColumn].w = wTmp
      tilemap.map[nLine][nColumn].h = hTmp
      SetColorTile(nLine,nColumn)
      x=x+wTmp +1
    end
    
    y=y+hTmp +1
  end 
  
  
  
end





















function IniMap(pLine,pColumn,pWeight,pHeight,pPosX,pPosY,nbrSalles)
  tilemap.w = pWeight
  tilemap.h = pHeight
  tilemap.line = pLine
  tilemap.column = pColumn
  tilemap.posX =pPosX
  tilemap.posY = pPosY
  tilemap.hSmall = tilemap.h/20
  tilemap.wSmall = tilemap.w/20
  
  local i
  for l=1,pLine do
    tilemap.map[l] = {}
    for c=1,pColumn do
      tilemap.map[l][c] = CreateSalle(l,c)
    end
  end
  BuildRooms(nbrSalles)
  CreateIntTileMap(tilemap.map)
  HowToDrawTile()
  

end




function DropListZombie()
  myZombies={}
end


function GenerateZombie(pNumber,timer,pSpeed)
  -- Faire apparaitre des zombies tous les combiens 

  
  while #myZombies < pNumber do
    local newZombie = {}
    local salleRandom =  listSalles[ROOMTYPE.ROOM][math.random(2,#listSalles[ROOMTYPE.ROOM])]
    
      if salleRandom.isLight == true then
        -- On recomence
      else

        -- Une salle sans lumière on peut faire poper un zombie
          newZombie.room = salleRandom
          newZombie.line = salleRandom.line
          newZombie.column = salleRandom.column
    
          newZombie.speed = math.random(1,pSpeed)
         -- newZombie.posX =GetCenterOfTile(newZombie.line,newZombie.column)[1]
          newZombie.posX =salleRandom.posXCenter
         -- newZombie.posY = GetCenterOfTile(newZombie.line,newZombie.column)[2]
          newZombie.posY = salleRandom.posYCenter

          newZombie.destinationL = listSalles[ROOMTYPE.START][1].line
          newZombie.destinationC = listSalles[ROOMTYPE.START][1].column
          newZombie.state= STATE.NONE
          
          newZombie.speedAttack = 2
          newZombie.timer = 0
          
          newZombie.nextRoom = nil
          newZombie.target = nil
          
          newZombie.isDead = false
          
          newZombie.health = 2
        newZombie.takeDamage = function()  
            newZombie.health = newZombie.health-1
            if newZombie.health <=0 then
            newZombie.isDead = true
            newZombie.state = STATE.DEAD
          end 
        end
          UpdatePath(newZombie)
          table.insert(myZombies,newZombie)
      end
      
    end

  
end









function love.load()
  
  love.window.setMode(800,600)
  love.window.setTitle("STH")
  screenWidth = love.graphics.getWidth()
  screenHeight = love.graphics.getHeight()
  
  -- Create the scenes
  
  
  
  
  
  -- load title page
  --SceneManager("title")
  
  groupRessources = ressource.newGroup()
  test = ressource.newRessource(10,550,10,10,"feu")
  groupRessources:addElement(test)
  test1 = ressource.newRessource(10,550,10,10,"feu")
  groupRessources:addElement(test1)
  

  IniMap(15,15,50,50,150,150,50,listSalles)
  

  AddCrew(10,10,5)
 -- AddCrew(12,12,5)
  --AddCrew(8,8,5)
  --GenerateZombie(20,5,1)
  
  IniSceneManager()
  IniLevelMap()
  IniShelterMap()
  
end




function love.update(dt)
   --HowToDrawCrewMember()

  --UpdateCrew (dt)
  --UpdateZombies(dt)
  --UpdateInPathFinding(inPathfinding)
  --groupGUI:update(dt)
  --testAnimation.anime(dt)
  
  SceneManager.UpdateSceneManager(dt)
end




-- Définit la couleur de la tuile en fonction de son type

function love.draw()
  --love.graphics.draw(img,10,500,0,10,10)
  --DrawTiles()
  --DrawSalles()
  --love.graphics.setColor(1,1,1)
  --love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 100, 100)

  --DebugDraw()
  --DrawZombies()
  --DrawCrewMembers()
  -- GUI
  --myGUI:draw()
  --groupRessources:draw()
  
  
  --testAnimation.draw()
  SceneManager.DrawSceneManager()
end

function love.keypressed(key)
  
  SceneManager.KeyPressedManager(key)
  
  
  if key == "space" then
    DropListZombie()
    IniMap(15,15,50,50,150,150,50,listSalles)
    GenerateZombie(20,5,1)
  elseif key == "a" then

    for l=1,#intTileMap do
      for c=1,#intTileMap[l] do
        io.write(tostring(intTileMap[l][c]))
      end
      io.write("\n")
    end
  elseif key =="r" then
    DropListZombie()
    GenerateZombie(5,5)
    
 elseif  key =="x" then
   

     myCrew[1].line = listSalles[1].line
     myCrew[1].column = listSalles[1].column
     
     myCrew[1].posX =GetCenterOfTile(listSalles[1].line,listSalles[1].column)[1]
     myCrew[1].posY =GetCenterOfTile(listSalles[1].line,listSalles[1].column)[2]
     
    elseif key =="u" then
      print("Door closing")
      for l=1,#listSalles do
        if listSalles[l].roomType == ROOMTYPE.DOOR then
            if listSalles[l].isOpen then
            listSalles[l].isOpen = false
          else
            listSalles[l].isOpen = true
          end
        end
      end
      CreateIntTileMap(tilemap.map)
  end
end


function CheckDestination(pObject,pTile)
  -- Surtout pour vérifier si c'est pas la même que la position actuelle du coup pas la peine d'appeler UpdatePAth()
  if pObject.line == pTile.line and pObject.column == pTile.column then
    return false
  else
    return true
  end
end

local listObjectSelected = {}
function love.mousepressed(x,y,button,istouch)
  
  if button == 1 then
    if #listObjectSelected == 0 then
      -- On peut y ajouter quelque chose
      local ObjectSelected
      ObjectSelected=GetCrew(x,y)
      
      
      if ObjectSelected ~= nil then
        print("J'ai un crew")
        table.insert(listObjectSelected,ObjectSelected)
      else
        
        
        
      local tileSelected = GetTile(x,y)
      if tileSelected ~= nil then
        print(tileSelected.roomType)
        if tileSelected.roomType ~= ROOMTYPE.ROOM  then
          print("je passe")
        else
          if tileSelected.isLight ==true then
         -- On désactive la lumire et on rend la ressource de nouveau disponible
         tileSelected.res.isUsed = false
         tileSelected.res.room =nil
         tileSelected.res =nil
         
         tileSelected.isLight = false
         tileSelected.couleur = {1,1,1,0.5}
          else
            for n,e in pairs(groupRessources.elements) do
                for l=1, #groupRessources.elements[n] do
                  if groupRessources.elements[n][l].isUsed == true then
                  -- On ne fait rien
                  else  

            -- On ajoute de l'electricité à la salle
                  groupRessources.elements[n][l].room = tileSelected
                  groupRessources.elements[n][l].isUsed = true
                  tileSelected.isLight = true
                  tileSelected.couleur = {1,1,1,1}
                  tileSelected.res = groupRessources.elements[n][l]
                  break
                  end
                end
            end 
          end
      
        end
      end
      end
    else
      local tileSelected = GetTile(x,y)
      if tileSelected == nil then
        print("Annulation selection")
      table.remove(listObjectSelected,1)
      else
        if tileSelected.roomType == ROOMTYPE.ROOM or tileSelected.roomType == ROOMTYPE.START then
                    if CheckDestination(listObjectSelected[1],tileSelected) then
            listObjectSelected[1].destinationX = tileSelected.posX
            listObjectSelected[1].destinationY = tileSelected.posY
            listObjectSelected[1].destinationL = tileSelected.line
            listObjectSelected[1].destinationC = tileSelected.column
            UpdatePath(listObjectSelected[1])
            table.remove(listObjectSelected,1)
          else
            print("Déja au bon endroit mon gars ")
          end
        else

        end
      end
    end
  end
    
end


function UpdatePositionZombie(pObject,dt)
if pObject.path ~=nil then 
  if pObject.nodePosition <= pObject.path:getLength() +1 then
    if pObject.nodePosition ==1 then pObject.nodePosition= pObject.nodePosition+1 end
    
    
    local angle = math.angle(pObject.posX,pObject.posY,pObject.nextRoom.posXCenter,pObject.nextRoom.posYCenter)
    local vx = pObject.speed*15*math.cos(angle) *dt
    local vy = pObject.speed *15*math.sin(angle) *dt
    local distanceX =math.abs(pObject.nextRoom.posXCenter-pObject.posX)
    if distanceX <=2 then
          pObject.posY =  pObject.posY+vy
          local distanceY =math.abs(pObject.nextRoom.posYCenter-pObject.posY )
          if distanceY <=1 then
            pObject.column = pObject.path._nodes[pObject.nodePosition]:getX()
            pObject.line = pObject.path._nodes[pObject.nodePosition]:getY()
            pObject.nodePosition =pObject.nodePosition+1
            local room = GetTile(pObject.posX,pObject.posY)
            pObject.onRoom = room
            GetNextRoom(pObject)
          end
    else
      pObject.posX =  pObject.posX+vx 
    end
  else
pObject.state= STATE.IDLE
pObject.path = nil
  end
 else
   print("pas de path")
   
end
end


function UpdatePosition(pCrew,dt)
 if pCrew.path ~=nil then 

--Le truc trop chiant qui fait que les salles sont décalé !!!!
     if pCrew.nodePosition <= pCrew.path:getLength() +1 then
       -- On fait pas la première étape ça sert à rien
      

      if pCrew.nodePosition ==1 then pCrew.nodePosition= pCrew.nodePosition+1 end
      
      
        --local centerTile = GetCenterOfTile(pCrew.path._nodes[pCrew.nodePosition]:getY(),pCrew.path._nodes[pCrew.nodePosition]:getX())
        local nextNodeX= pCrew.room.posXCenter
        local nextNodeY = pCrew.room.posYCenter
        --local nextNodeX= pCrew.nextRoom.posXCenter
        --local nextNodeY= pCrew.nextRoom.posYCenter
        local angle = math.angle(pCrew.posX,pCrew.posY,nextNodeX,nextNodeY)
        local vx = pCrew.speed*15*math.cos(angle) *dt
        local vy = pCrew.speed *15*math.sin(angle) *dt
          
        local room = GetTile(nextNodeX,nextNodeY)
        -- En gros si je cherche encore posX je modifie posX sinon je pass
        local distanceX=math.abs(nextNodeX-pCrew.posX)
        
        if distanceX <=2 then
          pCrew.posY =  pCrew.posY+vy
          local distanceY =math.abs(nextNodeY-pCrew.posY)
          if distanceY <=1 then
            
            pCrew.column = pCrew.path._nodes[pCrew.nodePosition]:getX()
            pCrew.line = pCrew.path._nodes[pCrew.nodePosition]:getY()
            pCrew.nodePosition =pCrew.nodePosition+1
            local room = GetTile(pCrew.posX,pCrew.posY)
            pCrew.onRoom =room
            GetNextRoom(pCrew)
          end
        else
           pCrew.posX =  pCrew.posX+vx 
        end
        
        -- DOnc je suis forcément en train de cherche Y
        
        
        
      
        --pCrew.posX = nextNodeX
        --pCrew.posY = nextNodeY


      else 
        local room = GetTile(pCrew.posX,pCrew.posY)
        pCrew.onRoom =room
        pCrew.state= STATE.IDLE
      end
else

end

end


function GetNextRoom (pObject)
  if pObject.path ~=nil then
    
    if pObject.nodePosition <= pObject.path:getLength()+1  then 
        if pObject.nodePosition ==1 then pObject.nodePosition = pObject.nodePosition +1 end
          local centerTile = GetCenterOfTile(pObject.path._nodes[pObject.nodePosition]:getY(),pObject.path._nodes[pObject.nodePosition]:getX())
        local nextNodeX = centerTile[1]
        local nextNodeY = centerTile[2]
        local room = GetTile(nextNodeX,nextNodeY)
        room.posXCenter= nextNodeX
        room.posYCenter =nextNodeY
        pObject.nextRoom= room
      else
        pObject.nextRoom= nil
        end
  else
    print("Pas de path on peut pas trouver la prochaine salle")
    pObject.nextRoom= nil
  end
  
  
end

function LookForZombie(pCrew)
  local target = nil
  for n=1,#myZombies do
    local distance = math.dist(pCrew.posX,pCrew.posY,myZombies[n].posX,myZombies[n].posY)
    -- Moitié car origine au centre
    if distance < tilemap.w/2 then
            pCrew.state = STATE.ATTACK
            target = myZombies[n]
            
    end
  end
  
  
  pCrew.target = target
end

function LookForHuman(pZombie)
  local target = nil
  for n=1,#myCrew do
    local distance = math.dist(pZombie.posX,pZombie.posY,myCrew[n].posX,myCrew[n].posY)
    -- Moitié car origine au centre
    if distance < tilemap.w/2 then
            pZombie.state = STATE.ATTACK
            target = myCrew[n]
            
    end
  end
  pZombie.target = target
end


function SmallRandomPosition(pZombie,dt)
  
        local randomX = math.random(pZombie.target.posX-10,pZombie.target.posX+10)
        local randomY =math.random(pZombie.target.posY-10,pZombie.target.posY+10)
        local angle = math.angle(pZombie.posX,pZombie.posY,randomX,randomY)
        local vx = pZombie.speed*15*math.cos(angle) *dt
        local vy = pZombie.speed *15*math.sin(angle) *dt

        pZombie.posX =pZombie.posX +vx
        pZombie.posY =pZombie.posY +vy
end

function UpdateZombies(dt)
  for n,zombie in ipairs(myZombies) do
--print(zombie.state)
   if zombie.state == STATE.NONE then
        if zombie.path ~= nil then
          zombie.state = STATE.WALKING
        end
    elseif zombie.state == STATE.WALKING then
      -- Mais d'abord vérifier si y a pas un humain par ici
      -- Il faut regarder ce qu'est la prochaine room
      if zombie.nextRoom ~= nil then
        if zombie.nextRoom.roomType == ROOMTYPE.DOOR  and zombie.nextRoom.isBroken ==false then
          zombie.state = STATE.FIGHTINGDOOR
        else
       --UpdatePosition(zombie,dt)
         UpdatePositionZombie(zombie,dt)
        end
      else
        GetNextRoom(zombie)
        --UpdatePosition(zombie,dt)
        UpdatePositionZombie(zombie,dt)
      end
      LookForHuman(zombie)
  elseif zombie.state == STATE.FIGHTINGDOOR then
        if zombie.nextRoom.isBroken == true then
          zombie.state = STATE.WALKING
        else
          if zombie.timer >= zombie.speedAttack then
            zombie.nextRoom.takeDamage()
            zombie.timer =0
          else
            zombie.timer = zombie.timer +dt
          end
          
        end
  elseif zombie.state == STATE.IDLE then
    if zombie.room.isBroken == true then
    else
      if zombie.timer >= zombie.speedAttack then
            zombie.room.takeDamage()
            zombie.timer =0
      else
            zombie.timer = zombie.timer +dt
      end
    end
    -- Pour le moment ça veut qu'on a atteint la fin
  elseif zombie.state == STATE.ATTACK then
    LookForHuman(zombie)
    if zombie.target ~= nil then
     SmallRandomPosition(zombie,dt)
     
      if zombie.timer >= zombie.speedAttack then
            zombie.target.takeDamage()
            zombie.timer =0
      else
            zombie.timer = zombie.timer +dt
      end
     
     
     
     
   else
     UpdatePath(zombie)
     zombie.state = STATE.WALKING
     end
  elseif zombie.state == STATE.DEAD then
    RemoveZombie(zombie)
    
  end
    end

  
end


function RemoveZombie(pZombie)
    for n=1,#myZombies do
    if myZombies[n] == pZombie then
        table.remove(myZombies,n)
    end
  end
  
end


function RemoveCrew(pCrew)
  for n=1,#myCrew do
    if myCrew[n] == pCrew then
        table.remove(myCrew,n)
    end
  end
  
  
end

function CrewGetBonus(pCrew)
  if pCrew.onRoom.isLight == true and pCrew.lightBonus == false then
    pCrew.lightBonus =true
    pCrew.health = (pCrew.health *10 ) /pCrew.maxHealth
    
  end
  
end

function CrewLostBonus(pCrew)
  
  pCrew.health = (pCrew.health*pCrew.maxHealth)/10

end

function UpdateCrew (dt)
  for n,crew in ipairs(myCrew) do
      --print(crew.health)
    if crew.state == STATE.NONE then
        if crew.path ~= nil then
          crew.state = STATE.WALKING
        end
    elseif crew.state == STATE.WALKING then
     -- CrewLostBonus (crew)
       GetNextRoom(crew)
      UpdatePositionZombie(crew,dt)
    elseif crew.state == STATE.IDLE then
        if crew.path ~= nil then
                crew.state = STATE.WALKING
        else
              CrewGetBonus(crew)
              LookForZombie(crew)
        end
              
    elseif crew.state == STATE.DEAD then
      RemoveCrew(crew)
    elseif crew.state == STATE.ATTACK then
      
    if crew.path == nil then
            LookForZombie(crew)
      if crew.target ~= nil then
        if crew.timer >= crew.speedAttack then
              crew.target.takeDamage()
              crew.timer =0
        else
              crew.timer = crew.timer +dt
        end
      else
        crew.state = STATE.IDLE
      end
    else
      crew.state = STATE.WALKING
    end
    end
  end
  
end






function UpdateInPathFinding(pList)
  
  -- On regarde tous les objets dans cette liste et on update leur position, si arrivé à destination on les enlève
  if #pList ~= 0 then
    
  for n=1,#pList do
    if pList[n].nodePosition  >=pList[n].lengthPath then
        pList[n].path = nil
        table.remove(pList,n)
    end
  end
  end
end


function MatrixAllPath()
  local salleStart
  local SalleFIN
  
    for l=1,#listSalles do
      
      salleStart = listSalles[l]
      local indexSalleStart = tostring(salleStart.line)..tostring(salleStart.column)

      matrixOfPath[indexSalleStart]= {}
      for c=1,#listSalles do
        
        
        SalleFIN = listSalles[c]
        local indexSalleFIN = tostring(SalleFIN.line)..tostring(SalleFIN.column)
        myFinder:setMode("ORTHOGONAL")
        local path = myFinder:getPath(salleStart.column, salleStart.line, SalleFIN.column, SalleFIN.line)
        if path ~= nil then
          --print(('Path found! Length: %.2f'):format(path:getLength()))
          matrixOfPath[indexSalleStart][indexSalleFIN] = path
            
            
        else
          
        end
        
        end
    end
  
end



function UpdatePath(pObject)
  if pObject ~= nil then
    
  -- Déclarer en même temps que la matrice de nombre dans CreateIntTile
    -- Creates a grid object
    --local grid = Grid(intTileMap) 
    -- Creates a pathfinder object using Jump Point Search
    --local myFinder = Pathfinder(grid, 'JPS', Walkable) 
      -- Je refuse que le chemin obtenu gère les diagonales
      myFinder:setMode("ORTHOGONAL")
      
   --------   

    local path = myFinder:getPath(pObject.column, pObject.line, pObject.destinationC, pObject.destinationL)
    if path ~= nil then
      --print(('Path found! Length: %.2f'):format(path:getLength()))
      for node, count in path:nodes() do
        --print(('Step: %d - x: %d - y: %d'):format(count, node:getX(), node:getY()))
      end
      -- C'est pas bon car deux fois le même objet
      -- Donc faut s'asurer que l'objet n'y ai plus
      -- Je pourais en théorie appeler la fonction pour nettoyer la liste des pathfindings mais au cas ou on laisse ça
      -- Mise de l'objet
        pObject.path = path
        pObject.nodePosition = 1
        pObject.idMemory = tostring(pObject)

        pObject.lengthPath = pObject.path:getLength()
      
      if #inPathfinding == 0 then     
        table.insert(inPathfinding,pObject)
      else
        local found=true
        for p=1,#inPathfinding do
          if inPathfinding[p].idMemory == pObject.idMemory then
            found =true
            break
          else 
            found = false
            --On l'ajoute à la liste   
          end
        end
        -- Si on l'a pas trouvé dans la lsite on 'lajoute
        if found ==false then
           table.insert(inPathfinding,pObject)
          end
      end
    else
    -- Path Non trouvé
      pObject.path = nil
    end
  else
  -- Nothing
  end
end









function RandomRoomDisplay(ROOMDISPLAY)
  local roomDisplay= {}
  roomDisplay.name = ROOMDISPLAY[math.random(1,#ROOMDISPLAY)]
  roomDisplay.salleMin = ROOMDISPLAY[roomDisplay.name]

  return roomDisplay
 end

function SetColorTile(pLineigne,nCol)
  local newCouleur
  local roomType =tilemap.map[pLineigne][nCol].roomType
  local alpha = 1
  if tilemap.map[pLineigne][nCol].isLight == false then alpha = 0.5 end
  if roomType == ROOMTYPE.START then
    newCouleur = {1,0,0,alpha}
  elseif roomType == ROOMTYPE.DOOR then 
     newCouleur ={1,1,0,alpha}
  elseif roomType == ROOMTYPE.ROOM then 
     newCouleur ={1,1,1,alpha}
     tilemap.map[pLineigne][nCol].img =imgTile
  elseif roomType == ROOMTYPE.WALL then
     newCouleur ={136/255,66/255,29/255}
  elseif roomType == ROOMTYPE.INTERROOM then
    newCouleur ={230/255,230/255,230/250}
  elseif roomType == ROOMTYPE.NONE then
    --newCouleur ={131/255,166/255,151/255}
    newCouleur ={0,0,0,0}
  end
    tilemap.map[pLineigne][nCol].couleur = newCouleur
end
  





function DebugRoomJoined()
  
for n=1,#listSalles do
 
  if listSalles[n].roomDisplay == ROOMDISPLAY[2] then
    for l=1,#listSalles[n].roomLinked do
      print("La salle ligne : "..listSalles[n].line.." et col : "..listSalles[n].column)
      print("est linked avec ")
      print("Salle jointe 1 X:"..listSalles[n].roomLinked[l].line)
      print("Salle jointe 1 Y:"..listSalles[n].roomLinked[l].column)
    end
  end
end
end

function DebugDraw()
  
  -- Debug
  love.graphics.setBackgroundColor(48/255, 48/255, 48/255)
  love.graphics.setFont(love.graphics.newFont(14))
  love.graphics.setColor(204/255,85/255,0)
  for n=1,#myCrew do
      love.graphics.print("Destination",myCrew[n].destinationX,myCrew[n].destinationY)
  end
  love.graphics.setColor(1,1,0)
  love.graphics.print("Porte",100, 80)
  love.graphics.setColor(1,1,1)
  love.graphics.print("Salle",100, 70)
  love.graphics.setColor(1,0,0)
  love.graphics.print("Première salle",100, 60)
  love.graphics.setColor(136/255,66/255,29/255)
  love.graphics.print("Mur",100, 50)
  love.graphics.setColor(230/255,230/255,230/250)
  love.graphics.print("EspaceEntreSalle",100, 40)
  love.graphics.setColor(131/255,166/255,161/255)
  love.graphics.print("Rien",100, 15)
  
  
  
  
  love.graphics.setColor(1,1,1)
  love.graphics.print("U pour fermer/ouvir les portes ",300, 15)
  love.graphics.print("X pour Positionner case rouge",300, 30)
  love.graphics.print("R pour parcourir path",300, 50)
  love.graphics.print("Espace pour reconstruire ",300, 70)
end
Board = Class{}

local boardCols, boardRows = 8, 8

function Board:init(x, y)
  self.x, self.y = x, y
  self.matches = {}
  self:initializeTiles()
end

function Board:initializeTiles()
  self.tiles = {}
  
  for tileY = 1, boardRows do
    -- new row empty table
    table.insert(self.tiles, {})
    
    for tileX = 1, boardCols do
      -- new tile
      table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(18), math.random(6)))
    end
  end
end

function Board:render()
  for y = 1, #self.tiles do
    for x = 1, #self.tiles[1] do
      self.tiles[y][x]:render(self.x, self.y)
    end
  end
end

-- searches for matches going left to right, top to bottom of the board
-- calculating matches by counting consecutive tiles of the same color
function Board:searchMatches()
  local matches = {}
  
  -- how many tiles of the same color are there in a row
  local numMatches = 1
  
  -- check for horizontal matches
  for y = 1, boardRows do
    local colorToMatch = self.tiles[y][1].color
    numMatches = 1
    
    for x = 2, boardCols do
      if self.tiles[y][x].color == colorToMatch then
        numMatches = numMatches + 1
      else
        colorToMatch = self.tiles[y][x].color
        -- if there was a match 3, get the tiles
        if numMatches >= 3 then
          table.insert(matches, self:getElements(self.tiles, y, y, x - numMatches, x - 1))
        end
        
        numMatches = 1
        
        -- no need to check the last two if they can't make a match three
        if x >= 7 then
          break
        end
      end
    end
    
    -- account for the last row ending with a match
    if numMatches >= 3 then
      table.insert(matches, self:getElements(self.tiles, y, y, boardCols - numMatches + 1, boardCols))
    end
  end
  
  -- vertical matches
  for x = 1, boardCols do
    local colorToMatch = self.tiles[1][x].color
    numMatches = 1
    
    for y = 2, boardRows do
      if self.tiles[y][x].color == colorToMatch then
        numMatches = numMatches + 1
      else
        colorToMatch = self.tiles[y][x].color
        if numMatches >= 3 then
          table.insert(matches, self:getElements(self.tiles, y - numMatches, y - 1, x, x))
        end
        
        numMatches = 1
        
        -- no need to check the last two if they can't make a match three
        if x >= 7 then
          break
        end
      end
    end
    
    -- account for the last row ending with a match
    if numMatches >= 3 then
      table.insert(matches, self:getElements(self.tiles, boardRows - numMatches + 1, boardRows, x, x))
    end
  end  
  
  self.matches = matches
  return #self.matches > 0 and self.matches or false
end

-- get elements from 2d table given i(row), j(col) indexes
function Board:getElements(tab, first_i, last_i, first_j, last_j)
  local elements = {}
  
  for i = first_i or 1, last_i or #tab do
    for j = first_j or 1, last_j or #tab[1] do
      elements[#elements+1] = tab[i][j]
    end
  end
  
  return elements
end

-- remove the matches tiles from the board by setting them to nil
function Board:removeMatches()
  for k, match in pairs(self.matches) do
    for k, tile in pairs(match) do
      self.tiles[tile.gridY][tile.gridX] = nil
    end
  end
  
  self.matches = nil
end

-- shifts down all the tiles that have spaces below them
-- and returns a table that contains tweening information for these new tiles
function Board:getFallingTiles()
  -- tween table with tiles as keys and their x, y coord as values
  local tweens = {}
  
  -- for each column, go up until we hit a space
  for x = 1, boardCols do
    local space = false
    local spaceY = 0
    
    local y = boardRows
    while y >= 1 do
      local tile = self.tiles[y][x]
      
      -- if there is a space below
      if space then
        -- if the current tile is not a space, bring it down to the lowest space
        if tile then
          --put the tile in the correct spot in the board and fix its grid positions
          self.tiles[spaceY][x] = tile
          tile.gridY = spaceY
          
          -- set its prior position to nil
          self.tiles[y][x] = nil
          
          -- save y position for making tween animations
          tweens[tile] = {
            y = (tile.gridY - 1) * 32
          }
          
          -- reset state and continue from spaceY up
          space = false
          y = spaceY
          spaceY = 0
        end
      -- if the current tile is a space
      elseif tile == nil then
        space = true
        
        if spaceY == 0 then
          spaceY = y
        end
      end
      
      y = y - 1
    end
  end
  
  -- create replacement tiles at the top of the screen
  for x = 1, 8 do
    for y = 8, 1, -1 do
      local tile = self.tiles[y][x]

      -- if the tile is nil, we need to add a new one
      if not tile then
        local tile = Tile(x, y, math.random(18), math.random(6))
        tile.y = -32
        self.tiles[y][x] = tile

        tweens[tile] = {
          y = (tile.gridY - 1) * 32
        }
      end
    end
  end
  
  return tweens
end
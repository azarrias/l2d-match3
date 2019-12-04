Board = Class{}

local boardCols, boardRows = 8, 8
local NUM_TILE_VARIATIONS = 6
local NUM_TILE_COLORS = 18

function Board:init(level, x, y)
  self.level = level
  self.x, self.y = x, y
  self.matches = {}
  self.tileColors = Set.new()
  self:initializeTiles()
end

function Board:initializeTiles()
  self.tiles = {}
  
  -- choose random available colors depending on the level
  local numColors = math.min(self.level + 3, 8)
  while #self.tileColors < numColors do
    self.tileColors:insert(math.random(18))
  end
  
  for tileY = 1, boardRows do
    -- new row empty table
    table.insert(self.tiles, {})
    
    for tileX = 1, boardCols do
      -- new tile
      -- 5% chance to generate shiny tiles starting on level 5
      isShiny = self.level >= 5 and math.random(100) <= 5 and true or false
      table.insert(self.tiles[tileY], Tile(tileX, tileY, self.tileColors[math.random(#self.tileColors)], math.random(1, (self.level - 1) % NUM_TILE_VARIATIONS + 1), isShiny))
    end
  end
  
  -- repeat until the board generated has no matches or deadlocks on start
  while self:searchMatches() or self:isDeadlock() do
    self:initializeTiles()
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
  
  -- flag to account for shiny tiles
  local foundShiny = false
  
  -- check for horizontal matches
  for y = 1, boardRows do
    local colorToMatch = self.tiles[y][1].color
    numMatches = 1
    foundShiny = self.tiles[y][1].shiny
    
    for x = 2, boardCols do
      if self.tiles[y][x].color == colorToMatch then
        numMatches = numMatches + 1
        foundShiny = foundShiny or self.tiles[y][x].shiny
      else
        colorToMatch = self.tiles[y][x].color
        
        -- if there was a match 3, get the tiles
        if numMatches >= 3 then
          if foundShiny then
            table.insert(matches, self:getElements(self.tiles, y, y, 1, boardCols))
          else
            table.insert(matches, self:getElements(self.tiles, y, y, x - numMatches, x - 1))
          end
        end
        
        numMatches = 1
        foundShiny = self.tiles[y][x].shiny
        
        -- no need to check the last two if they can't make a match three
        if x >= 7 then
          break
        end
      end
    end
    
    -- account for the last row ending with a match
    if numMatches >= 3 then
      if foundShiny then
        table.insert(matches, self:getElements(self.tiles, y, y, 1, boardCols))
      else
        table.insert(matches, self:getElements(self.tiles, y, y, boardCols - numMatches + 1, boardCols))
      end
    end
  end
  
  -- vertical matches
  for x = 1, boardCols do
    local colorToMatch = self.tiles[1][x].color
    numMatches = 1
    foundShiny = self.tiles[1][x].shiny
    
    for y = 2, boardRows do
      if self.tiles[y][x].color == colorToMatch then
        numMatches = numMatches + 1
        foundShiny = foundShiny or self.tiles[y][x].shiny
      else
        colorToMatch = self.tiles[y][x].color
        if numMatches >= 3 then
          if foundShiny then
            table.insert(matches, self:getElements(self.tiles, 1, boardRows, x, x))
          else
            table.insert(matches, self:getElements(self.tiles, y - numMatches, y - 1, x, x))
          end
        end
        
        numMatches = 1
        foundShiny = self.tiles[y][x].shiny
        
        -- no need to check the last two if they can't make a match three
        if y >= 7 then
          break
        end
      end
    end
    
    -- account for the last row ending with a match
    if numMatches >= 3 then
      if foundShiny then
        table.insert(matches, self:getElements(self.tiles, 1, boardRows, x, x))
      else
        table.insert(matches, self:getElements(self.tiles, boardRows - numMatches + 1, boardRows, x, x))
      end
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
        local tile = Tile(x, y, self.tileColors[math.random(#self.tileColors)], math.random(1, (self.level - 1) % NUM_TILE_VARIATIONS + 1), isShiny)
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

function Board:isDeadlock()
  -- check for all cells
  for y = 1, boardRows - 1 do
    for x = 1, boardCols - 1 do
      -- exchange cell with the one to its right
      local tempTile = self.tiles[y][x]
      self.tiles[y][x] = self.tiles[y][x+1]      
      self.tiles[y][x+1] = tempTile
      
      -- check for matches and undo move
      local foundMatches = self:searchMatches()
      
      -- undo move
      self.tiles[y][x+1] = self.tiles[y][x]
      self.tiles[y][x] = tempTile
      
      if foundMatches then
        return false
      end
      
      -- exchange cell with the one below
      self.tiles[y][x] = self.tiles[y+1][x]
      self.tiles[y+1][x] = tempTile
      
      -- check for matches and undo move
      foundMatches = self:searchMatches()
      
      self.tiles[y+1][x] = self.tiles[y][x]
      self.tiles[y][x] = tempTile
      
      if foundMatches then
        return false
      end
    end
  end
  
  return true
end

function Board:shuffle()
  -- rearrange the existing tiles
  for y = boardRows, 2, -1 do
    for x = boardCols, 2, -1 do
      r = math.random(y)
      c = math.random(x)
      
      local tmp = self.tiles[y][x]:clone()
      self.tiles[y][x].color = self.tiles[r][c].color
      self.tiles[y][x].variety = self.tiles[r][c].variety
      self.tiles[y][x].shiny = self.tiles[r][c].shiny
      self.tiles[r][c].color = tmp.color
      self.tiles[r][c].variety = tmp.variety
      self.tiles[r][c].shiny = tmp.shiny
    end
  end
end

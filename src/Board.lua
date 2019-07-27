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
          table.insert(matches, self:getElements(self.tiles, y, y, x - numMatches, x-1))
        end
        -- no need to check the last two if they can't make a match three
        if x >= 7 then
          break
        end
        
        numMatches = 1
      end
    end
    
    -- account for the last row ending with a match
    if numMatches >= 3 then
      table.insert(matches, self:getElements(self.tiles, y, y, boardCols - numMatches + 1, boardCols))
    end
  end
  
  -- TODO: vertical matches
  
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
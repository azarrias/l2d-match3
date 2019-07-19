Board = Class{}

local boardCols, boardRows = 8, 8

function Board:init(x, y)
  self.x, self.y = x, y
  self:initializeTiles()
end

function Board:initializeTiles()
  self.tiles = {}
  
  for tileY = 1, boardRows do
    -- new row empty table
    table.insert(self.tiles, {})
    
    for tileX = 1, boardCols do
      -- new tile
      table.insert(self.tiles[tileY], Tile(tileX, tileY))
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
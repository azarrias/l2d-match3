Tile = Class{}

function Tile:init(x, y)
  self.gridX = x
  self.gridY = y
  
  self.x = (self.gridX - 1) * 32
  self.y = (self.gridY - 1) * 32
end

function Tile:render(x, y)
  love.graphics.setColor(COLORS.white)
  love.graphics.draw(TEXTURES.main, FRAMES.tiles[1][1], 
    self.x + x, self.y + y)
end
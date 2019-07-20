Tile = Class{}

function Tile:init(x, y, color, variety)
  self.gridX = x
  self.gridY = y
  
  self.x = (self.gridX - 1) * 32
  self.y = (self.gridY - 1) * 32
  
  self.color = color
  self.variety = variety
end

function Tile:render(x, y)
  love.graphics.setColor(COLORS.white)
  love.graphics.draw(TEXTURES.main, FRAMES.tiles[self.color][self.variety], 
    self.x + x, self.y + y)
end
StartState = Class{__includes = BaseState}

local positions = {}
local cols, rows = 8, 8
local tileColors = 18
local tileVariants = 6
local tileSide = 32
local shadowSize = 3

function StartState:init()
  -- generate full table of tiles just for display
  for i = 1, cols * rows do
    table.insert(positions, FRAMES.tiles[math.random(tileColors)][math.random(tileVariants)])
  end
end  

function StartState:update(dt)
  -- handle input
  if love.keyboard.keysPressed.escape then
    love.event.quit()
  end
end

function StartState:render()
  -- calculate margin for the board to be centered on screen
  local marginX = (VIRTUAL_WIDTH - tileSide * cols) / 2
  local marginY = (VIRTUAL_HEIGHT - tileSide * rows) / 2
  for y = 1, rows do
    for x = 1, cols do
      -- draw shadow
      love.graphics.setColor(COLORS.black)
      love.graphics.draw(TEXTURES.main, positions[(y - 1) * x + x],
        (x - 1) * tileSide + marginX + shadowSize, (y - 1) * tileSide + marginY + shadowSize)
    end
  end
end
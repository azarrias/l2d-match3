StartState = Class{__includes = BaseState}

local positions = {}
local cols, rows = 8, 8
local tileColors = 18
local tileVariants = 6
local tileSide = 32
local shadowSize = 3
-- calculate margin for the board to be centered on screen
local marginX = (VIRTUAL_WIDTH - tileSide * cols) / 2
local marginY = (VIRTUAL_HEIGHT - tileSide * rows) / 2

function StartState:init()
  -- generate full table of tiles just for display
  for i = 1, cols * rows do
    table.insert(positions, FRAMES.tiles[math.random(tileColors)][math.random(tileVariants)])
  end
  
  -- palette for the title letters
  self.colors = {
    [1] = COLORS.mulberry,
    [2] = COLORS.turquoise,
    [3] = COLORS.gold,
    [4] = COLORS.purple,
    [5] = COLORS.green_light,
    [7] = COLORS.red_light
  }
end  

function StartState:update(dt)
  -- handle input
  if love.keyboard.keysPressed.escape then
    love.event.quit()
  end
end

function StartState:render()
  for y = 1, rows do
    for x = 1, cols do
      -- draw shadow
      love.graphics.setColor(COLORS.black)
      love.graphics.draw(TEXTURES.main, positions[(y - 1) * x + x],
        (x - 1) * tileSide + marginX + shadowSize, (y - 1) * tileSide + marginY + shadowSize)

      -- render tiles
      love.graphics.setColor(COLORS.white)
      love.graphics.draw(TEXTURES.main, positions[(y - 1) * x + x],
        (x - 1) * tileSide + marginX, (y - 1) * tileSide + marginY)
    end
  end
  
  -- apply a dark tint to the whole menu screen
  love.graphics.setColor(COLORS.black_semitransparent)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
  
  self:drawMatch3Text()
end

function StartState:drawMatch3Text()
  titleText = 'MATCH 3'
  
  love.graphics.setColor(COLORS.white_semitransparent)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 - 60 - 11, 150, 58, 6)
  
  love.graphics.setFont(FONTS.large)
  self:drawTextShadow('MATCH 3', VIRTUAL_HEIGHT / 2 - 60)
  for i = 1, titleText:len() do
    if i ~= 6 then
      love.graphics.setColor(self.colors[i])
      leftText = titleText:sub(1, i - 1)
      rightText = titleText:sub(i + 1)
      leftOffset = FONTS.large:getWidth(leftText)
      rightOffset = FONTS.large:getWidth(rightText)
      love.graphics.printf(titleText:sub(i, i), 0, VIRTUAL_HEIGHT / 2 - 60,
        VIRTUAL_WIDTH + leftOffset - rightOffset, 'center')
    end
  end
end

function StartState:drawTextShadow(text, y)
    love.graphics.setColor(COLORS.shadow)
    love.graphics.printf(text, 2, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 0, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 2, VIRTUAL_WIDTH, 'center')
end
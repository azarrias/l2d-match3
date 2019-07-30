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
local menuOptions = { "Start", "Quit Game" }

function StartState:init()
  self.currentMenuItem = 1
  
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
    [6] = COLORS.orange
  }
  
  self.colorTimer = Timer.every(0.075,  -- interval timer (in seconds)
    function()                          -- callback function to execute once every interval
      e = table.remove(self.colors, 1)
      table.insert(self.colors, e)
    end
  )
  
  -- used to tween animate state transition (fade out)
  self.transitionAlpha = 0
end  

function StartState:update(dt)
  -- handle input
  if love.keyboard.keysPressed.escape then
    love.event.quit()
  end
  
  if love.keyboard.keysPressed.up or love.keyboard.keysPressed.down then
    self.currentMenuItem = self.currentMenuItem == 1 and 2 or 1
    SOUNDS.select:play()
  end
  
  if love.keyboard.keysPressed.enter or love.keyboard.keysPressed['return'] then
    if self.currentMenuItem == 1 then
      -- make fade out tween animation to the begin game state
      Timer.tween(1, {
        [self] = {transitionAlpha = COLORS.white[4]}
      }):finish(function()
            gStateMachine:change('begin-game', { level = 1 })
            
            -- remove color timer from Timer
            self.colorTimer:remove()
      end)
    else
      love.event.quit()
    end
  end
  
  -- Update all timers in the default group
  Timer.update(dt)
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
  self:drawOptions()
  
  -- draw transition rect; normally fully transparent, to transition to another state
  love.graphics.setColor(COLORS.white[1], COLORS.white[2], COLORS.white[3], self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end

function StartState:drawMatch3Text()
  titleText = 'MATCH 3'
  
  love.graphics.setColor(COLORS.white_semitransparent)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 - 60 - 11, 150, 58, 6)
  
  love.graphics.setFont(FONTS.large)
  self:drawTextShadow('MATCH 3', VIRTUAL_HEIGHT / 2 - 60)
  idx = 1
  
  for i = 1, titleText:len() do
    -- if we have a space, we can skip it
    if titleText:sub(i, i) ~= " " then 
      love.graphics.setColor(self.colors[idx])
      leftText = titleText:sub(1, i - 1)
      rightText = titleText:sub(i + 1)
      leftOffset = FONTS.large:getWidth(leftText)
      rightOffset = FONTS.large:getWidth(rightText)
      love.graphics.printf(titleText:sub(i, i), 0, VIRTUAL_HEIGHT / 2 - 60,
        VIRTUAL_WIDTH + leftOffset - rightOffset, 'center')
      idx = idx + 1
    end
  end
end

function StartState:drawOptions()
  love.graphics.setColor(COLORS.white_semitransparent)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + 12, 150, 58, 6)
  
  love.graphics.setFont(FONTS.medium)
  self:drawTextShadow(menuOptions[1], VIRTUAL_HEIGHT / 2 + 12 + 8)
  
  if self.currentMenuItem == 1 then
    love.graphics.setColor(COLORS.blue)
  else
    love.graphics.setColor(COLORS.blue_dark)
  end
  
  love.graphics.printf(menuOptions[1], 0, VIRTUAL_HEIGHT / 2 + 12 + 8, VIRTUAL_WIDTH, 'center')
  
  self:drawTextShadow(menuOptions[2], VIRTUAL_HEIGHT / 2 + 12 + 33)
  
  if self.currentMenuItem == 2 then
    love.graphics.setColor(COLORS.blue)
  else
    love.graphics.setColor(COLORS.blue_dark)
  end
  
  love.graphics.printf(menuOptions[2], 0, VIRTUAL_HEIGHT / 2 + 12 + 33, VIRTUAL_WIDTH, 'center')
end
  

function StartState:drawTextShadow(text, y)
    love.graphics.setColor(COLORS.shadow)
    love.graphics.printf(text, 2, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 0, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 2, VIRTUAL_WIDTH, 'center')
end
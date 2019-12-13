PlayState = Class{__includes = BaseState}

function PlayState:init()
  -- grid position currently highlighted
  self.boardHighlightX = 0
  self.boardHighlightY = 0
  
  -- flag used to switch the highlight rect's color
  self.rectHighlighted = false
  
  -- flag used to control if we can input (not swapping or clearing)
  self.canInput = true
  
  -- tile we're currently highlighting (preparing to swap)
  self.hightlightedTile = nil
  
  -- transition alpha for the shining effect on shining tiles
  self.transitionAlpha = 0
  
  self.score = 0
  self.timer = 60
  
  -- toggle cursor highlight every 0.5 seconds
  Timer.every(0.5, function()
    self.rectHighlighted = not self.rectHighlighted
  end)

  -- subtract 1 from timer every second
  Timer.every(1, function()
    self.timer = self.timer - 1
  end)

  -- board deadlock label out of screen for tween animation
  self.levelLabelY = -64
  -- flag to keep track of the tweening animation when shuffling tiles
  self.isTweening = false

end

function PlayState:enter(params)
  self.level = params.level
  self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)
  self.score = params.score or 0
  self.scoreGoal = self.level * 1.25 * 1000
  
  -- tween alpha to make shining effect when rendering on top of the board
  Timer.every(1.2, function ()
    Timer.tween(0.2, {
      [self] = { transitionAlpha = V11 and 0.5 or 127 }
    }) 
    : finish(function()
        Timer.tween(0.2, {
          [self] = { transitionAlpha = 0 }
        })
      end)
  end) 
end

function PlayState:update(dt)
  if love.keyboard.keysPressed.escape then
    gStateMachine:change('start')
  end
  
  -- go to game over state if time runs out
  if self.timer <= 0 then
    -- clear timers from prior PlayStates
    Timer.clear()
    
    SOUNDS['game-over']:play()
    
    gStateMachine:change('game-over', {
      score = self.score
    })
  end
  
  if self.canInput then
      -- go to next level if score goal is surpassed
    if self.score >= self.scoreGoal then
      self.canInput = false
      -- clear timers from prior PlayStates
      Timer.clear()
      --gStateMachine:change('begin-game', {
      gStateMachine:change('level-clear', {
        --level = self.level + 1,
        level = self.level,
        board = self.board,
        score = self.score,
        scoreGoal = self.scoreGoal,
        timer = self.timer
      })
    end
    
    if love.keyboard.keysPressed.up then
      self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
      SOUNDS.select:play()
    elseif love.keyboard.keysPressed.down then
      self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
      SOUNDS.select:play()
    elseif love.keyboard.keysPressed.left then
      self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
      SOUNDS.select:play()
    elseif love.keyboard.keysPressed.right then
      self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
      SOUNDS.select:play()
    end
    
    if next(love.mouse.pressed) and love.mouse.pressed.x and love.mouse.pressed.y then
      local x = math.floor((love.mouse.pressed.x - self.board.x) / 32) + 1
      local y = math.floor((love.mouse.pressed.y - self.board.y) / 32) + 1
    
      if x >= 1 and x <= 8 and y >= 1 and y <= 8 then
        self.highlightedTile = self.board.tiles[y][x]
      end
    end
  
    if next(love.mouse.released) then
      if love.mouse.released.x and love.mouse.released.y then
        local x = math.floor((love.mouse.released.x - self.board.x) / 32) + 1
        local y = math.floor((love.mouse.released.y - self.board.y) / 32) + 1
      
        if x >= 1 and x <= 8 and y >= 1 and y <= 8 and self.highlightedTile then
          if self.highlightedTile == self.board.tiles[y][x] then
            self.highlightedTile = nil
          elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
            SOUNDS.error:play()
            self.highlightedTile = nil
          else
            self:commandSwapTiles(x, y)
          end
        else
          self.highlightedTile = nil
        end
      else
        self.highlightedTile = nil
      end
    end
  
    if love.keyboard.keysPressed.enter or love.keyboard.keysPressed['return'] then
      local x, y = self.boardHighlightX + 1, self.boardHighlightY + 1
    
      -- if nothing is highlighted, highlight current tile
      if not self.highlightedTile then
        self.highlightedTile = self.board.tiles[y][x]
      -- if the tile is already highlighted, deselect
      elseif self.highlightedTile == self.board.tiles[y][x] then
        self.highlightedTile = nil
      -- if the tile is not adjacent, remove highlight and play error sound
      elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
        SOUNDS.error:play()
        self.highlightedTile = nil
      -- otherwise all is good, swap the tiles
      else
        self:commandSwapTiles(x, y)
      end
    end
  end

  Timer.update(dt)
end

function PlayState:render()
  self.board:render()
  
  -- make shining effect for tiles that are of the shining type
  -- drawing on top of the board in additive blend mode
  for y = 1, #self.board.tiles do
    for x = 1, #self.board.tiles[1] do
      if self.board.tiles[y][x].shiny then
        love.graphics.setBlendMode('add')
        love.graphics.setColor(COLORS.white[1], COLORS.white[2], COLORS.white[3], self.transitionAlpha)
        love.graphics.draw(TEXTURES.main, FRAMES.tiles[self.board.tiles[y][x].color][self.board.tiles[y][x].variety], 
          self.board.tiles[y][x].x + self.board.x, self.board.tiles[y][x].y + self.board.y)
        love.graphics.setBlendMode('alpha')
      end
    end
  end
  
  -- render highlighted tile if it exists
  if self.highlightedTile then
    -- multiply so drawing white rect makes it brighter
    love.graphics.setBlendMode('add')
    love.graphics.setColor(COLORS.white_quite_transparent)
    love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
      (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)
    -- back to alpha
    love.graphics.setBlendMode('alpha')
  end  

  -- draw cursor rect
  if not MOBILE_OS then
    if self.rectHighlighted then
      love.graphics.setColor(COLORS.red_light)
    else
      love.graphics.setColor(COLORS.red)
    end
    love.graphics.setLineWidth(4)
    love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272), 
      self.boardHighlightY * 32 + 16, 32, 32, 4)
  end
  
  -- GUI text
  love.graphics.setColor(COLORS.gray)
  love.graphics.rectangle('fill', 16, 16, 186, 116, 4)
  
  love.graphics.setColor(COLORS.blue)
  love.graphics.setFont(FONTS.medium)
  love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
  love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
  love.graphics.printf('Goal: ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
  love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
  
  -- Display board deadlock UI message
  love.graphics.setColor(COLORS.cyan_light_muted_quite_opaque)
  love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
  
  love.graphics.setColor(COLORS.white)
  love.graphics.setFont(FONTS.large)
  love.graphics.printf('Rearranging tiles',
    0, self.levelLabelY, VIRTUAL_WIDTH, 'center')
end

-- Checks for matches on the board and performs tween animations as needed
function PlayState:handleMatches()
  self.highlightedTile = nil
  
  -- if matches are produced, remove them and tween the falling blocks
  local matches = self.board:searchMatches()
  
  if matches then
    -- don't allow any input when matches are being processed
    self.canInput = false
    SOUNDS.match:stop()
    SOUNDS.match:play()
    
    -- add points to score for each tile within the match
    for k, match in pairs(matches) do
      for i, tile in pairs(match) do
        self.score = self.score + 40 + tile.variety * 10
      end
      self.timer = self.timer + #match
    end
    
    self.board:removeMatches()
    
    -- gets a table with tween values for tiles that should fall
    local tilesToFall = self.board:getFallingTiles()
    
    -- tween the falling tiles
    Timer.tween(0.25, tilesToFall)
    :finish(function()
      -- recursively call this function in case that new matches have ben created
      self:handleMatches()
      local enterDeadlockTrigger = true
      while self.board:isDeadlock() do
        self.isTweening = true
        if enterDeadlockTrigger then
          enterDeadlockTrigger = false
          -- board deadlock message tween animation
          Timer.tween(0.25, {
            [self] = { levelLabelY = VIRTUAL_HEIGHT / 2 - 8 }
          })
          -- pause for one second with Timer.after
          :finish(function()
            Timer.after(1, function()
              -- then animate the label going down past the bottom edge
              Timer.tween(0.25, {
                [self] = { levelLabelY = VIRTUAL_HEIGHT + 30 }
              })
              :finish(function()
                self.isTweening = false
                self.canInput = true
              end)
            end)
          end)
        end
        print "There are no possible matches!!! Rearranging cells...."
        self.board:shuffle()
        self:handleMatches()
      end
    end)
  elseif not self.isTweening then
    -- if there are no matches or tweens going on, input is allowed again
    self.canInput = true
  end
end

function PlayState:commandSwapTiles(x, y)
  local tempX, tempY = self.highlightedTile.gridX, self.highlightedTile.gridY
  local newTile = self.board.tiles[y][x]

  self.highlightedTile.gridX, self.highlightedTile.gridY = newTile.gridX, newTile.gridY
  newTile.gridX, newTile.gridY = tempX, tempY

  self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] =
    self.highlightedTile
  self.board.tiles[newTile.gridY][newTile.gridX] = newTile

  -- check if the move produces a match
  local createsMatch = self.board:searchMatches()
      
  -- swap tween animation
  Timer.tween(0.1, {
    [self.highlightedTile] = { x = newTile.x, y = newTile.y },
    [newTile] =  { x = self.highlightedTile.x, y = self.highlightedTile.y }
  })
  :finish(function()
    -- if it is a match then handle it, otherwise undo the move
    if createsMatch then
      self:handleMatches()
    else
      SOUNDS.error:play()
      Timer.tween(0.1, {
        [self.highlightedTile] = { x = newTile.x, y = newTile.y },
        [newTile] =  { x = self.highlightedTile.x, y = self.highlightedTile.y }
      })
      :finish(function()
        newTile.gridX, newTile.gridY = self.highlightedTile.gridX, self.highlightedTile.gridY
        self.highlightedTile.gridX, self.highlightedTile.gridY = tempX, tempY
        self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile
        self.board.tiles[newTile.gridY][newTile.gridX] = newTile
        self.highlightedTile = nil
      end)
    end
  end)
end
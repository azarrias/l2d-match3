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
  
  -- toggle cursor highlight every 0.5 seconds
  Timer.every(0.5, function()
    self.rectHighlighted = not self.rectHighlighted
  end)
end

function PlayState:enter(params)
  self.level = params.level
  self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)
end

function PlayState:update(dt)
  if love.keyboard.keysPressed.escape then
    gStateMachine:change('start')
  end
  
  if love.keyboard.keysPressed.up then
    self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
  elseif love.keyboard.keysPressed.down then
    self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
  elseif love.keyboard.keysPressed.left then
    self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
  elseif love.keyboard.keysPressed.right then
    self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
  end
    
  Timer.update(dt)
end

function PlayState:render()
  self.board:render()
  
  -- draw cursor rect
  if self.rectHighlighted then
    love.graphics.setColor(COLORS.red_light)
  else
    love.graphics.setColor(COLORS.red)
  end
  love.graphics.setLineWidth(4)
  love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272),
    self.boardHighlightY * 32 + 16, 32, 32, 4)
end
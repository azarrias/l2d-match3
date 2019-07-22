BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()
  -- transition alpha for the foreground rectangle fade in
  self.transitionAlpha = V11 and 1 or 255
  
  -- spawn a board and place it to the right
  self.board = Board(VIRTUAL_WIDTH - 272, 16)
  self.levelLabelY = VIRTUAL_HEIGHT / 2 - 8
end

function BeginGameState:enter(param)
  self.level = param.level
  
  Timer.tween(1, {
    [self] = { transitionAlpha = 0 }
  })
end

function BeginGameState:update(dt)
  if love.keyboard.keysPressed.escape then
    gStateMachine:change('start')
  end
  
  Timer.update(dt)
end

function BeginGameState:render()
  self.board:render()
  
  love.graphics.setColor(COLORS.cyan_light_muted_quite_opaque)
  love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
  love.graphics.setColor(COLORS.white)
  love.graphics.setFont(FONTS.large)
  love.graphics.printf('Level ' .. tostring(self.level),
    0, self.levelLabelY, VIRTUAL_WIDTH, 'center')
  
  -- transition foreground rectangle
  love.graphics.setColor(COLORS.white[1], COLORS.white[2], COLORS.white[3], self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end
BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()
  -- spawn a board and place it to the right
  self.board = Board(VIRTUAL_WIDTH - 272, 16)
  self.levelLabelY = VIRTUAL_HEIGHT / 2 - 8
end

function BeginGameState:update(dt)
  if love.keyboard.keysPressed.escape then
    gStateMachine:change('start')
  end
end

function BeginGameState:enter(param)
  self.level = param.level
end

function BeginGameState:render()
  self.board:render()
  
  love.graphics.setColor(COLORS.cyan_light_muted_quite_opaque)
  love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
  love.graphics.setColor(COLORS.white)
  love.graphics.setFont(FONTS.large)
  love.graphics.printf('Level ' .. tostring(self.level),
    0, self.levelLabelY, VIRTUAL_WIDTH, 'center')
end
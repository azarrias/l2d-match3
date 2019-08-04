GameOverState = Class{__includes = BaseState}

function GameOverState:enter(params)
  self.score = params.score
end

function GameOverState:update(dt)
  if love.keyboard.keysPressed.escape or love.keyboard.keysPressed.enter or
    love.keyboard.keysPressed['return'] then
    gStateMachine:change('start')
  end
end

function GameOverState:render()
  love.graphics.setFont(FONTS.large)
  
  love.graphics.setColor(COLORS.gray)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 64 - 8, 64 - 8, 128 + 8 * 2, 136 + 8 * 2, 4)
  
  love.graphics.setColor(COLORS.blue)
  love.graphics.printf('GAME OVER', VIRTUAL_WIDTH / 2 - 64, 64, 128, 'center')
  love.graphics.setFont(FONTS.medium)
  love.graphics.printf('Your score: ' .. tostring(self.score), VIRTUAL_WIDTH / 2 - 64, 140, 128, 'center')
  love.graphics.printf('Press Enter', VIRTUAL_WIDTH / 2 - 64, 180, 128, 'center')
end
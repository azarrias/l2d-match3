GameOverState = Class{__includes = BaseState}

function GameOverState:update(dt)
  if love.keyboard.keysPressed.escape then
    gStateMachine:change('start')
  end
end

function GameOverState:render()
  love.graphics.setFont(FONTS.large)
  
  love.graphics.setColor(COLORS.gray)
  love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 64, 64, 128, 136, 4)
  
  love.graphics.setColor(COLORS.blue)
  love.graphics.printf('GAME OVER', VIRTUAL_WIDTH / 2 - 64, 64, 128, 'center')
end
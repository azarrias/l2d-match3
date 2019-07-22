PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
  self.level = params.level
  self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)
end

function PlayState:update(dt)
  if love.keyboard.keysPressed.escape then
    gStateMachine:change('start')
  end
end

function PlayState:render()
  self.board:render()
end
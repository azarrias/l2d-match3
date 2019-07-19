BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()
  -- spawn a board and place it to the right
  self.board = Board(VIRTUAL_WIDTH - 272, 16)
end

function BeginGameState:render()
  self.board:render()
end
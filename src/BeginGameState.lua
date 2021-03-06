BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()
  -- transition alpha for the foreground rectangle fade in
  self.transitionAlpha = V11 and 1 or 255
  
  -- starting level label out of screen for tween animation
  self.levelLabelY = -64
end

function BeginGameState:enter(param)
  self.level = param.level
  
  -- spawn a board and place it to the right
  self.board = Board(self.level, VIRTUAL_WIDTH - 272, 16)
  
  -- fade in 1 second using foreground rectangle alpha
  Timer.tween(1, {
    [self] = { transitionAlpha = 0 }
  }) 
  
  -- once finished, start tween animation of level label Y coord
  :finish(function()
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
        -- after the tween animation, transition to the play state
        :finish(function()
          gStateMachine:change('play', {
            level = self.level,
            board = self.board
          })
        end)
      end)
    end)
  end)
end

function BeginGameState:update(dt)
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
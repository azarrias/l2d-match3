LevelClearState = Class{__includes = BaseState}

function LevelClearState:init()
  -- transition alpha for the foreground rectangle fade in
  self.transitionAlpha = 0
  
  -- starting level label out of screen for tween animation
  self.levelLabelY = -64
end

function LevelClearState:enter(param)
  self.level = param.level
  self.board = param.board
  self.score = param.score
  self.scoreGoal = param.scoreGoal
  self.timer = param.timer
  
  -- level clear tween animation
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
      -- fade out 1 second using foreground rectangle alpha
      :finish(function()
        Timer.tween(1, {
          [self] = { transitionAlpha = V11 and 1 or 255 }
        })
        :finish(function()
          gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
          })
        end)
      end)
    end)
  end)
end

function LevelClearState:update(dt)
  Timer.update(dt)
end

function LevelClearState:render()
  self.board:render()
  
  -- GUI text
  love.graphics.setColor(COLORS.gray)
  love.graphics.rectangle('fill', 16, 16, 186, 116, 4)
  
  love.graphics.setColor(COLORS.blue)
  love.graphics.setFont(FONTS.medium)
  love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
  love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
  love.graphics.printf('Goal: ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
  love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')
  
  -- Level clear GUI element
  love.graphics.setColor(COLORS.cyan_light_muted_quite_opaque)
  love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
  
  love.graphics.setColor(COLORS.white)
  love.graphics.setFont(FONTS.large)
  love.graphics.printf('Level ' .. tostring(self.level) .. ' clear',
    0, self.levelLabelY, VIRTUAL_WIDTH, 'center')
  
  -- transition foreground rectangle
  love.graphics.setColor(COLORS.white[1], COLORS.white[2], COLORS.white[3], self.transitionAlpha)
  love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end
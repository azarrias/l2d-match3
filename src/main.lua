require 'globals'
push = require 'lib.push'
Class = require 'lib.class'
Timer = require 'lib.knife.timer'

require 'StateMachine'
require 'BaseState'
require 'StartState'
require 'BeginGameState'
require 'PlayState'

require 'Board'
require 'Tile'

local backgroundWidth
local backgroundX, backgroundScrollSpeed

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  -- use nearest-neighbor (point) filtering on upscaling and downscaling to prevent blurring of text and 
  -- graphics instead of the bilinear filter that is applied by default 
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle(GAME_TITLE)
  math.randomseed(os.time())
  
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    vsync = true,
    fullscreen = MOBILE_OS,
    resizable = not MOBILE_OS
  })
  
  backgroundWidth = TEXTURES.background:getDimensions()
  backgroundX = 0
  backgroundScrollSpeed = 80
  
  gStateMachine = StateMachine {
    start = function() return StartState() end,
    ['begin-game'] = function() return BeginGameState() end,
    play = function() return PlayState() end
  }
  gStateMachine:change('start')

  love.keyboard.keysPressed = {}
  
  -- Adapt colors to new range in V11 for compatibility
  if V11 then
    for k, v in pairs(COLORS) do
      for key, value in pairs(v) do
        COLORS[k][key] = value / 255
      end
    end
  end
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  -- scroll background to the left by decreasing its X position
  backgroundX = backgroundX - backgroundScrollSpeed * dt
  -- the background does not tile perfectly
  -- 51 is the width of the pattern
  -- 4 is the horizontal offset to the left in order to align it
  if backgroundX <= -backgroundWidth + VIRTUAL_WIDTH + 51 - 4 then
    backgroundX = 0
  end
  
  gStateMachine:update(dt)
  
  love.keyboard.keysPressed = {}
end

-- Callback that processes key strokes just once
-- Does not account for keys being held down
function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.draw()
  push:apply('start')
  
  -- draw background at X, 0 without scaling or rotating
  love.graphics.draw(TEXTURES.background,
    backgroundX, 0)
  
  gStateMachine:render()
  push:apply('end')
end
  
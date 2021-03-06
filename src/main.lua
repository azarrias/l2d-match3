require 'Globals'
push = require 'lib.push'
Class = require 'lib.class'
Timer = require 'lib.knife.timer'
Set = require 'lib.set'

require 'StateMachine'
require 'BaseState'
require 'StartState'
require 'BeginGameState'
require 'PlayState'
require 'GameOverState'
require 'LevelClearState'

require 'Board'
require 'Tile'

local backgroundWidth
local backgroundX, backgroundScrollSpeed

function love.load(arg)
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  -- turn off stdout buffering for debugging purposes
  --io.stdout:setvbuf('no')
  
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
    play = function() return PlayState() end,
    ['level-clear'] = function() return LevelClearState() end,
    ['game-over'] = function() return GameOverState() end
  }
  gStateMachine:change('start')

  love.keyboard.keysPressed = {}
  love.mouse.pressed = {}
  love.mouse.released = {}
  
  -- Adapt colors to new range in V11 for compatibility
  if V11 then
    for k, v in pairs(COLORS) do
      for key, value in pairs(v) do
        COLORS[k][key] = value / 255
      end
    end
  end
  
  -- set volume for sounds
  local masterVolume = 1
  local sfxVolume = 0.5
  local musicVolume = 1
  
  for k, v in pairs(SOUNDS) do
    if k == 'music' then
      SOUNDS['music']:setVolume(masterVolume * musicVolume)
    elseif k == 'next-level' then
      SOUNDS['next-level']:setVolume(masterVolume * sfxVolume / 2)
    else
      SOUNDS[k]:setVolume(masterVolume * sfxVolume)
    end
  end
  
  -- set music to loop and start
  SOUNDS.music:setLooping(true)
  SOUNDS.music:play()
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
  love.mouse.pressed = {}
  love.mouse.released = {}
end

-- Callback that processes key strokes just once
-- Does not account for keys being held down
function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.mousepressed(x, y, button, istouch)
  x, y = push:toGame(x, y)
  love.mouse.pressed = {
    x = x,
    y = y,
    button = button
  }
end

function love.mousereleased(x, y, button, istouch)
  x, y = push:toGame(x, y)
  love.mouse.released = {
    x = x,
    y = y,
    button = button
  }
end

function love.draw()
  push:apply('start')
  
  -- draw background at X, 0 without scaling or rotating
  love.graphics.draw(TEXTURES.background,
    backgroundX, 0)
  
  gStateMachine:render()
  push:apply('end')
end
  
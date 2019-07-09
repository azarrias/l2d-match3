require 'globals'
push = require 'lib.push'

local backgroundWidth, backgroundHeight

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
  
  backgroundWidth, backgroundHeight = TEXTURES.background:getDimensions()

  love.keyboard.keysPressed = {}
end

function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  if love.keyboard.keysPressed.escape then
    love.event.quit()
  end
  
  love.keyboard.keysPressed = {}
end

-- Callback that processes key strokes just once
-- Does not account for keys being held down
function love.keypressed(key)
  love.keyboard.keysPressed[key] = true
end

function love.draw()
  push:apply('start')
  
  love.graphics.draw(TEXTURES.background,
    0, 0, -- draw at 0, 0
    0,    -- no rotation
    VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))
    
  push:apply('end')
end
  
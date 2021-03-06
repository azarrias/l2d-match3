require 'Util'

-- OS checks in order to make necessary adjustments to support multiplatform
MOBILE_OS = (love._version_major > 0 or love._version_minor >= 9) and (love.system.getOS() == 'Android' or love.system.getOS() == 'OS X')
WEB_OS = (love._version_major > 0 or love._version_minor >= 9) and love.system.getOS() == 'Web'

GAME_TITLE = 'Match 3'
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 512, 288

V11 = love._version_major > 0 or love._version_major == 0 and love._version_minor >= 11

COLORS = {
  aquamarine = { 127, 255, 212 },
  black = { 0, 0, 0 },
  black_semitransparent = { 0, 0, 0, 128 },
  blue = { 99, 155, 255 },
  blue_dark = { 48, 96, 130 },
  cyan_light_muted_quite_opaque = { 95, 205, 228, 200 },
  gold = { 251, 242, 54 },
  gray = { 56, 56, 56, 234 },
  gray_transparent = { 56, 56, 56, 0 },
  green = { 106, 190, 47 },
  green_light = { 153, 229, 80 },
  mulberry = { 217, 87, 99 },
  orange = { 223, 113, 38 },
  pink = { 215, 123, 186 },
  purple = { 118, 66, 138 },
  red = { 172, 50, 50 },
  red_light = { 217, 87, 99 },
  shadow = { 34, 32, 52 },
  turquoise = { 95, 205, 228 },
  yellow = { 255, 255, 0 },
  white = { 255, 255, 255, 255 },
  white_transparent = { 255, 255, 255, 0 },
  white_semitransparent = { 255, 255, 255, 128 },
  white_quite_transparent = { 255, 255, 255, 96 },
  new_color
}

TEXTURES = {
  background = love.graphics.newImage('graphics/background.png'),
  main = love.graphics.newImage('graphics/match3.png')
}

FRAMES = {
  -- divided into sets for each tile type in this game, instead of one large
  -- table of Quads
  tiles = GenerateTileQuads(TEXTURES.main)
}

FONTS = {
  small = love.graphics.newFont('fonts/font.ttf', 8),
  medium = love.graphics.newFont('fonts/font.ttf', 16),
  large = love.graphics.newFont('fonts/font.ttf', 32)
}

SOUNDS = {
  select = love.audio.newSource('sounds/select.wav', 'static'),
  error = love.audio.newSource('sounds/error.wav', 'static'),
  match = love.audio.newSource('sounds/match.wav', 'static'),
  music = love.audio.newSource('sounds/music3.mp3', WEB_OS and 'static' or 'stream'),
  ['game-over'] = love.audio.newSource('sounds/game-over.wav', 'static'),
  ['clock'] = love.audio.newSource('sounds/clock.wav', 'static'),
  ['next-level'] = love.audio.newSource('sounds/next-level.wav', 'static')
}

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- It is important that only one argument is supplied to this version of the deepcopy function. 
-- Otherwise, it will attempt to use the second argument as a table, which can have unintended consequences. 
function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
require 'Util'

MOBILE_OS = love.system.getOS() == 'Android' or love.system.getOS() == 'OS X'
GAME_TITLE = 'Match 3'
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 512, 288

V11 = love._version_major > 0 or love._version_major == 0 and love._version_minor >= 11

COLORS = {
  aquamarine = { 127, 255, 212 },
  black = { 0, 0, 0 },
  black_semitransparent = { 0, 0, 0, 128 },
  blue = { 99, 155, 255 },
  gold = { 251, 242, 54 },
  green = { 106, 190, 47 },
  green_light = { 153, 229, 80 },
  mulberry = { 217, 87, 99 },
  pink = { 215, 123, 186 },
  purple = { 118, 66, 138 },
  red = { 217, 87, 99 },
  red_light = { 223, 113, 38 },
  shadow = { 34, 32, 52 },
  turquoise = { 95, 205, 228 },
  yellow = { 255, 255, 0 },
  white = { 255, 255, 255 },
  white_semitransparent = { 255, 255, 255, 128 }
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
require 'Util'

MOBILE_OS = love.system.getOS() == 'Android' or love.system.getOS() == 'OS X'
GAME_TITLE = 'Match 3'
WINDOW_WIDTH, WINDOW_HEIGHT = 1280, 720
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 512, 288

V11 = love._version_major > 0 or love._version_major == 0 and love._version_minor >= 11

COLORS = {
  aquamarine = { 127, 255, 212 },
  red = { 217, 87, 99 },
  green = { 106, 190, 47 },
  blue = { 99, 155, 255 },
  yellow = { 255, 255, 0 },
  white = { 255, 255, 255 },
  black = { 0, 0, 0 },
  purple = { 215, 123, 186 },
  gold = { 251, 242, 54 }
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
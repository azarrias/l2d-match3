--[[
    Given an "atlas" (a texture with multiple sprites), generate all of the
    quads for the different tiles therein, divided into tables for each set
    of tiles, since each color has 6 varieties.
]]
function GenerateTileQuads(atlas)
    local tiles = {}

    local x = 0
    local y = 0

    local counter = 1

    -- two sets of 6 cols, different tile varieties
    for set = 1, 2 do
        -- 9 rows of tiles
        for row = 1, 9 do
            tiles[counter] = {}
            x = (set - 1) * 6 * 32
            
            for col = 1, 6 do
                table.insert(tiles[counter], love.graphics.newQuad(
                    x, y, 32, 32, atlas:getDimensions()
                ))
                x = x + 32
            end

            y = y + 32
            counter = counter + 1
        end
        y = 0
    end

    return tiles
end
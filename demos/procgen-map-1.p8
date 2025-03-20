pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Procgen map
-- by akd

-- There is a series of different ways this can be implemented in increasing order of performance.
-- 1. (this cart) Calculate every tile on screen every frame.
--    Performance (Tile length 1): 30/60 23.79 20.9X (Last digit off-screen)
-- 2. Initialize the screen with an initial calculation of every tile.
--    Thereafter, only once the player has moved enough to render new tiles on screen do we move the tiles over and calculate the new edge tiles.
-- 3. Similar to no. 2, but instead of moving the tiles over, let all tiles stay where they are, and query into the myMap object using modulus 17.
--    This should save a lot of moving stuff around.
-- 4. Try number 3 but using the Pico-8 map feature.
--    17x17 map, indexing just as in no. 3, using modulo 17.
-- 5. Try using the spritesheet instead. This way we can generate sprites on the fly and get 1x1 size tiles instead of 8x8.
--    The width of the spritesheet is only 16 tiles, so we might need to get creative mapping the 17x17 map coords to the 16x32 spritesheet coords.

#include ../lib/with-temp-seed.lua
#include ../lib/get-text-width.lua
#include ../lib/overlay.lua

local tileLength = 16
local screenW = 128
local pixelsPerWorldCoord = 8
function getMaxTilesVisiblePerRow() return screenW \ tileLength + 1 end -- Because the character can stand in the center of a tile, such that we only see half of the edge tiles, we need to render one extra tile.
function getTilesPerWorldCoord() return pixelsPerWorldCoord / tileLength end

local character = {
  -- Its x and y coordinates are world coordinates.
  worldX = 0,
  worldY = 0,
  -- TODO: Add speed param?
  update = function(self)
    local dx = tonum(btn(➡️)) - tonum(btn(⬅️))
    local dy = tonum(btn(⬇️)) - tonum(btn(⬆️))
    local mag = 10 * max(1, sqrt(dx * dx + dy * dy))
    self.worldX += dx / mag
    self.worldY += dy / mag
  end,
  -- The character is always drawn in the center of on the screen.
  draw = function()
    spr(1, 60, 60)
    -- 0 ... 60 61 62 63 (63.5) 64 65 66 67 ... 127
    -- Character's center position is 63.5,63.5
  end
}

local myMap = {
  seed = 0,
  -- Grid: A 17x17 2D array of sprite IDs.
  -- The indices x and y are in the range 0-16. And, offset by the character's position, represent the world coordinates.
  -- The tile at 8,8 is always the tile under the character.
  grid = {},
  pixelOffsetX = 0,
  pixelOffsetY = 0,
  -- noise(x,y) returns a number between 0 and 1
  noise = function(worldX, worldY)
    local value = cos(worldX / 40) + sin(worldY / 40)
    -- Adjust from -2..2 to 0..1
    return (value + 2) / 4
  end,
  update = function(self)
    if btnp(❎) then self.seed = rnd(~0) end

    if btnp(🅾️) then
      tileLength = (tileLength == 1) and 16 or tileLength \ 2
    end

    local randomOffsetWorldX, randomOffsetWorldY = unpack(withTempSeed(
      self.seed, function()
        return { rnd(1000) \ 1, rnd(1000) \ 1 }
      end
    ))

    local centerScreenOffsetWorldX = 8
    local centerScreenOffsetWorldY = 8
    local maxTilesVisiblePerRow = getMaxTilesVisiblePerRow()
    local tilesPerWorldCoord = getTilesPerWorldCoord()

    for tileX = 0, maxTilesVisiblePerRow - 1 do
      self.grid[tileX] = {}
      for tileY = 0, maxTilesVisiblePerRow - 1 do
        local characterTileX = character.worldX * tilesPerWorldCoord
        local characterTileY = character.worldY * tilesPerWorldCoord
        local worldX = (tileX + characterTileX \ 1) / tilesPerWorldCoord - centerScreenOffsetWorldX
        local worldY = (tileY + characterTileY \ 1) / tilesPerWorldCoord - centerScreenOffsetWorldY
        local sprite = 16 * self.noise(worldX + randomOffsetWorldX, worldY + randomOffsetWorldY)
        self.pixelOffsetX = -(characterTileX % 1) * tileLength
        self.pixelOffsetY = -(characterTileY % 1) * tileLength
        self.grid[tileX][tileY] = mid(sprite, 0, 15) -- noise() is 0-1 inclusive, but we really need it to be exclusive, so we clamp.
      end
    end
  end,
  draw = function(self)
    local maxTilesVisiblePerRow = getMaxTilesVisiblePerRow()
    for tileX = 0, maxTilesVisiblePerRow - 1 do
      for tileY = 0, maxTilesVisiblePerRow - 1 do
        local screenX = tileX * tileLength + self.pixelOffsetX
        local screenY = tileY * tileLength + self.pixelOffsetY
        rectfill(
          screenX,
          screenY,
          screenX + tileLength - 1,
          screenY + tileLength - 1,
          flr(self.grid[tileX][tileY])
        )
      end
    end
  end
}

function _update60()
  character:update()
  myMap:update()
end

function _draw()
  cls()
  myMap:draw()
  character.draw()
  drawStats()
end

function drawStats()
  local string = "x: " .. character.worldX .. "\n"
      .. "y: " .. character.worldY .. "\n"
      .. "sEED: " .. myMap.seed .. "\n"
      .. "tILElEN: " .. tileLength .. "\n"
      .. "mEM: " .. stat(0)
  local stringHeight = 5 * 6 - 1
  local stringWidth = getTextWidth(string)
  local x, y = 128 - stringWidth - 7, 128 - stringHeight - 7
  overlay(x, y, stringWidth + 4, stringHeight + 4)
  print(string, x + 2, y + 2, 13)
end

__gfx__
00000000004444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004ffff400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f7171f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ff99ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

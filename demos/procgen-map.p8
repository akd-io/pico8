pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Procgen map
-- by akd

-- There is a series of different ways this can be implemented in increasing order of performance.
-- 1. (this cart) Calculate every tile on screen every frame.
-- 2. Initialize the screen with an initial calculation of every tile.
--    Thereafter, only once the player has moved enough to render new tiles on screen do we move the tiles over and calculate the new edge tiles.
-- 3. Similar to no. 2, but instead of moving the tiles over, let all tiles stay where they are, and query into the myMap object using modulus 17.
--    This should save a lot of moving stuff around.
-- 4. Try number 3 but using the Pico-8 map feature.
--    17x17 map, indexing just as in no. 3, using modulo 17.
-- 5. Try using the spritesheet instead. This way we can generate sprites on the fly and get 1x1 size tiles instead of 8x8.
--    The width of the spritesheet is only 16 tiles, so we might need to get creative mapping the 17x17 map coords to the 16x32 spritesheet coords.

#include ../lib/join.lua
#include ../lib/table_to_str.lua
#include ../lib/with_temp_seed.lua
#include ../lib/get_text_width.lua
#include ../lib/overlay.lua

local tileLength = 4
local screenW = 128
local maxTilesVisiblePerRow = screenW / tileLength + 1

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
  end
}

local myMap = {
  seed = 0,
  -- Grid: A 17x17 2D array of sprite IDs.
  -- The indices x and y are in the range 0-16. And, offset by the character's position, represent the world coordinates.
  -- The tile at 8,8 is always the tile under the character.
  grid = {},
  -- noise(x,y) returns a number between 0 and 1
  -- TODO: improve noise function
  noise = function(worldX, worldY)
    local value = cos(worldX / 40) + sin(worldY / 40)
    -- Adjust from -2..2 to 0..1
    return (value + 2) / 4
  end,
  update = function(self)
    if (btnp(❎)) self.seed = rnd(~0)
    withTempSeed(
      self.seed, function()
        local randomOffsetX = rnd(1000)
        local randomOffsetY = rnd(1000)
        for x = 0, maxTilesVisiblePerRow - 1 do
          self.grid[x] = {}
          for y = 0, maxTilesVisiblePerRow - 1 do
            local sprite = 16 * self.noise(
              flr(randomOffsetX) + flr(character.worldX) + x * (tileLength / 8) - 8,
              flr(randomOffsetY) + flr(character.worldY) + y * (tileLength / 8) - 8
            )
            self.grid[x][y] = mid(sprite, 0, 15) -- noise() is 0-1 inclusive, but we really needed it to be exclusive, so we clamp.
          end
        end
      end
    )
  end,
  draw = function(self)
    for worldX = 0, maxTilesVisiblePerRow - 1 do
      for worldY = 0, maxTilesVisiblePerRow - 1 do
        local screenX = tileLength * (worldX - (0x0000.ffff & character.worldX))
        local screenY = tileLength * (worldY - (0x0000.ffff & character.worldY))
        rectfill(screenX, screenY, screenX + tileLength - 1, screenY + tileLength - 1, flr(self.grid[worldX][worldY]))
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
      .. "seed: " .. myMap.seed .. "\n"
      .. "mem: " .. stat(0)
  local stringWidth = getTextWidth(string)
  local x, y = 128 - stringWidth - 7, 98
  overlay(x, y, stringWidth + 4, 27)
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

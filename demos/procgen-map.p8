pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Procgen map
-- by akd

#include ../lib/join.lua
#include ../lib/table_to_str.lua
#include ../lib/clamp.lua
#include ../lib/with_temp_seed.lua

local tileSize = 8

-- noise(x,y) returns a number between 0 and 1
-- TODO: improve noise function
function noise(x, y)
  return (cos(x / 40) + sin(y / 40) + 2) / 4
end

local character = {
  -- Its x and y coordinates are world coordinates.
  position = { x = 0, y = 0 },
  update = function(self)
    local dx = tonum(btn(➡️)) - tonum(btn(⬅️))
    local dy = tonum(btn(⬇️)) - tonum(btn(⬆️))
    local mag = 10 * max(1, sqrt(dx * dx + dy * dy))
    self.position.x += dx / mag
    self.position.y += dy / mag
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
  update = function(self)
    if (btnp(❎)) self.seed = rnd(~0)
    withTempSeed(
      self.seed, function()
        local randomOffsetX = rnd(1000)
        local randomOffsetY = rnd(1000)
        for x = 0, 16 do
          self.grid[x] = {}
          for y = 0, 16 do
            local sprite = 16 * noise(
              flr(randomOffsetX) + flr(character.position.x) + x - 8,
              flr(randomOffsetY) + flr(character.position.y) + y - 8
            )
            self.grid[x][y] = clamp(sprite, 0, 15) -- noise() is 0-1 inclusive, but we really needed it to be exclusive, so we clamp.
          end
        end
      end
    )
  end,
  draw = function(self)
    for tileX = 0, 16 do
      for tileY = 0, 16 do
        local x = 8 * (tileX - (0x0000.ffff & character.position.x))
        local y = 8 * (tileY - (0x0000.ffff & character.position.y))
        rectfill(x, y, x + 7, y + 7, flr(self.grid[tileX][tileY]))
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
  print("player x: " .. character.position.x, 0, 0, 7)
  print("player y: " .. character.position.y, 0, 6, 7)
  print("map seed: " .. myMap.seed, 0, 12, 7)
  print("mem: " .. stat(0), 0, 18, 7)
end

__gfx__
00000000004444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004ffff400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000f7171f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ff99ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

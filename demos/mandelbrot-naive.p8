pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Mandelbrot Naive
-- by akd

#include ../lib/get-text-width.lua
#include ../lib/overlay.lua

local pixelOffsetX = 0
local pixelOffsetY = 0
local zoom = 1

function mandelbrot(x, y)
  -- Scale and offset the coordinates
  local zx = 0
  local zy = 0
  local cx = (x - 64) / (32 * zoom)

  -- Calculate the Mandelbrot value
  for i = 1, 20 do
    local zx_squared = zx * zx
    local zy_squared = zy * zy
    if zx_squared + zy_squared > 4 then
      return i
    end
    zy = 2 * zx * zy + (y - 64) / (32 * zoom)
    zx = zx_squared - zy_squared + cx
  end
  return 0
end

function _update60()
  -- Handle zoom with O and X buttons
  if btnp(🅾️) then
    zoom *= 2
  end
  if btnp(❎) then
    zoom *= 0.5
  end

  -- Move exactly 1 pixel at a time
  pixelOffsetX += tonum(btn(➡️)) - tonum(btn(⬅️))
  pixelOffsetY += tonum(btn(⬇️)) - tonum(btn(⬆️))

  for x = 0, 127 do
    for y = 0, 127 do
      local value = mandelbrot(x + pixelOffsetX, y + pixelOffsetY)
    end
  end
end

function _draw()
  for x = 0, 127 do
    for y = 0, 127 do
      local value = mandelbrot(x + pixelOffsetX, y + pixelOffsetY)
      pset(x, y, value)
    end
  end
  drawStats()
end

function drawStats()
  local string = "x: " .. pixelOffsetX .. "\n"
      .. "y: " .. pixelOffsetY .. "\n"
      .. "zoom: " .. zoom .. "\n"
      .. "mEM: " .. stat(0)
  local lines = 4
  local stringHeight = lines * 6 - 1
  local stringWidth = getTextWidth(string)
  local x, y = 128 - stringWidth - 7, 128 - stringHeight - 7
  overlay(x, y, stringWidth + 4, stringHeight + 4)
  print(string, x + 2, y + 2, 13)
end

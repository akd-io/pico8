pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- mandelbrot 2d cache
-- by akd

#include ../lib/get_text_width.lua
#include ../lib/overlay.lua
#include ../lib/draw_to_spritesheet.lua

local pixelOffsetX = 0
local pixelOffsetY = 0
local zoom = 1

function mandelbrot(x, y)
  -- Scale and offset the coordinates
  local cx = (x - 64) / (32 * zoom)
  local cy = (y - 64) / (32 * zoom)

  -- Main cardioid test
  local cx_minus_0_25 = cx - 0.25
  local cy_squared = cy * cy
  local q = cx_minus_0_25 * cx_minus_0_25 + cy_squared
  if q * (q + cx_minus_0_25) <= 0.25 * cy_squared then
    return 0
  end

  -- Period-2 bulb test
  local cx_plus_1 = cx + 1
  if cx_plus_1 * cx_plus_1 + cy_squared <= 0.0625 then
    return 0
  end

  -- Calculate the Mandelbrot value
  local zx, zy = 0, 0
  for i = 1, 25 do
    local zx_squared = zx * zx
    local zy_squared = zy * zy
    if zx_squared + zy_squared > 4 then
      return i
    end
    zy = 2 * zx * zy + cy
    zx = zx_squared - zy_squared + cx
  end
  return 0
end

function drawFullSpritesheet()
  drawToSpritesheet(function()
    for screenX = 0, 127 do
      for screenY = 0, 127 do
        local x, y = screenX + pixelOffsetX, screenY + pixelOffsetY
        local value = mandelbrot(x, y)
        pset(x % 128, y % 128, value)
      end
    end
  end)
end

function _init()
  drawFullSpritesheet()
end

function _update60()
  -- Handle zoom with O and X buttons
  if btnp(🅾️) then
    zoom *= 2
    pixelOffsetX *= 2
    pixelOffsetY *= 2
    drawFullSpritesheet()
    return
  elseif btnp(❎) then
    local newZoom = zoom * 0.5
    zoom = newZoom == 0 and 0x0000.0001 or newZoom
    pixelOffsetX *= 0.5
    pixelOffsetY *= 0.5
    drawFullSpritesheet()
    return
  end

  -- Move exactly 1 pixel at a time
  local dx = tonum(btn(➡️)) - tonum(btn(⬅️))
  local dy = tonum(btn(⬇️)) - tonum(btn(⬆️))
  pixelOffsetX += dx
  pixelOffsetY += dy

  if 0 == dx and 0 == dy then
    return
  end

  drawToSpritesheet(function()
    -- Calculate and draw new pixels based on movement
    if dx > 0 or dx < 0 then
      local screenX = dx > 0 and 127 or 0
      local x = screenX + pixelOffsetX
      for screenY = 0, 127 do
        local y = screenY + pixelOffsetY
        local value = mandelbrot(x, y)
        pset(x % 128, y % 128, value)
      end
    end
    if dy > 0 or dy < 0 then
      local screenY = dy > 0 and 127 or 0
      local y = screenY + pixelOffsetY
      for screenX = 0, 127 do
        local x = screenX + pixelOffsetX
        local value = mandelbrot(x, y)
        pset(x % 128, y % 128, value)
      end
    end
  end)
end

function _draw()
  -- Calculate the source rectangles based on pixel offset
  local ox = pixelOffsetX % 128
  local oy = pixelOffsetY % 128

  -- Clear the screen
  cls()

  -- Draw up to 4 rectangles to cover the screen
  -- Top-left
  sspr(ox, oy, 128 - ox, 128 - oy, 0, 0)
  -- Top-right (if needed)
  if ox > 0 then
    sspr(0, oy, ox, 128 - oy, 128 - ox, 0)
  end
  -- Bottom-left (if needed)
  if oy > 0 then
    sspr(ox, 0, 128 - ox, oy, 0, 128 - oy)
  end
  -- Bottom-right (if needed)
  if ox > 0 and oy > 0 then
    sspr(0, 0, ox, oy, 128 - ox, 128 - oy)
  end

  drawStats()
end

function drawStats()
  local string = "x: " .. pixelOffsetX .. "\n"
      .. "y: " .. pixelOffsetY .. "\n"
      .. "zoom: " .. zoom .. "\n"
      .. "cpu: " .. stat(1) .. "\n"
      .. "mem: " .. stat(0)
  local lines = 5
  local letterHeight = 6
  local stringHeight = lines * letterHeight - 1
  local stringWidth = getTextWidth(string)
  local x, y = 128 - stringWidth - 7, 128 - stringHeight - 7
  overlay(x, y, stringWidth + 4, stringHeight + 4)
  print(string, x + 2, y + 2, 13)
end

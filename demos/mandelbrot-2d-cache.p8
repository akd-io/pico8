pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- mandelbrot 2d cache
-- by akd

#include ../lib/get_text_width.lua
#include ../lib/overlay.lua
#include ../lib/draw_to_spritesheet.lua
#include ../lib/mandelbrot.lua
#include ../lib/join.lua

local offsetX = 0
local offsetY = 0
local zoom = 1
local iterations = 25
local showHUD = false

function drawFullSpritesheet()
  drawToSpritesheet(function()
    for screenX = 0, 127 do
      for screenY = 0, 127 do
        local x, y = screenX + offsetX, screenY + offsetY
        local value = mandelbrot(x, y, zoom, iterations)
        pset(x % 128, y % 128, value)
      end
    end
  end)
end

function _init()
  drawFullSpritesheet()

  menuitem(
    1, "toggle hud", function()
      showHUD = not showHUD
    end
  )
end

function _update60()
  local dx = tonum(btn(➡️)) - tonum(btn(⬅️))
  local dy = tonum(btn(⬇️)) - tonum(btn(⬆️))

  -- Handle zoom with O and X buttons
  if btn(🅾️) then
    if btnp(⬆️) then
      zoom *= 2
      offsetX *= 2
      offsetY *= 2
      drawFullSpritesheet()
    elseif btnp(⬇️) then
      local newZoom = zoom * 0.5
      zoom = newZoom == 0 and 0x0000.0001 or newZoom
      offsetX *= 0.5
      offsetY *= 0.5
      drawFullSpritesheet()
    end
    return
  elseif btn(❎) then
    if btnp(⬆️) then
      local newIterations = iterations + 1
      iterations = newIterations > 255 and 255 or newIterations
      drawFullSpritesheet()
    elseif btnp(⬇️) then
      local newIterations = iterations - 1
      iterations = newIterations < 1 and 1 or newIterations
      drawFullSpritesheet()
    end
    return
  end

  offsetX += dx
  offsetY += dy

  if 0 == dx and 0 == dy then
    return
  end

  drawToSpritesheet(function()
    -- Calculate and draw new pixels based on movement
    if dx > 0 or dx < 0 then
      local screenX = dx > 0 and 127 or 0
      local x = screenX + offsetX
      for screenY = 0, 127 do
        local y = screenY + offsetY
        local value = mandelbrot(x, y, zoom, iterations)
        pset(x % 128, y % 128, value)
      end
    end
    if dy > 0 or dy < 0 then
      local screenY = dy > 0 and 127 or 0
      local y = screenY + offsetY
      for screenX = 0, 127 do
        local x = screenX + offsetX
        local value = mandelbrot(x, y, zoom, iterations)
        pset(x % 128, y % 128, value)
      end
    end
  end)
end

function _draw()
  -- Calculate the source rectangles based on pixel offset
  local ox = offsetX % 128
  local oy = offsetY % 128

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

  if showHUD then
    drawControls()
    drawStats()
  end
end

function drawControls()
  local lines = {
    "🅾️+⬆️: zoom in",
    "🅾️+⬇️: zoom out",
    "❎+⬆️: inc. iterations",
    "❎+⬇️: dec. iterations",
    "⬅️⬆️⬇️➡️: move"
  }
  local string = join(lines, "\n")
  local letterHeight = 6
  local stringHeight = #lines * letterHeight - 1
  local stringWidth = getTextWidth(string)
  local x, y = 3, 3
  overlay(x, y, stringWidth + 4, stringHeight + 4)
  print(string, x + 2, y + 2, 13)
end

function drawStats()
  local lines = {
    "x: " .. offsetX,
    "y: " .. offsetY,
    "zoom: " .. zoom,
    "iterations: " .. iterations,
    "cpu: " .. stat(1),
    "mem: " .. stat(0)
  }
  local string = join(lines, "\n")
  local letterHeight = 6
  local stringHeight = #lines * letterHeight - 1
  local stringWidth = getTextWidth(string)
  local x, y = 128 - stringWidth - 7, 128 - stringHeight - 7
  overlay(x, y, stringWidth + 4, stringHeight + 4)
  print(string, x + 2, y + 2, 13)
end

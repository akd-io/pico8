pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- mandelbrot 2d cache cpu threshold
-- by akd

#include ../lib/get-text-width.lua
#include ../lib/overlay.lua
#include ../lib/draw-to-spritesheet.lua
#include ../lib/mandelbrot.lua

local UNRESOLVED_COLOR = 15 -- white, or pick another unused color
local unresolvedPixels = {} -- {{x,y}, {x,y}, ...} table for tracking pixels that need to be resolved
local cpuThreshold = 0.7

local pixelOffsetX = 0
local pixelOffsetY = 0
local zoom = 1

function drawFullSpritesheet()
  drawToSpritesheet(function()
    for screenX = 0, 127 do
      for screenY = 0, 127 do
        if stat(1) >= cpuThreshold then
          -- Mark remaining pixels as unresolved
          local x, y = screenX + pixelOffsetX, screenY + pixelOffsetY
          pset(x % 128, y % 128, UNRESOLVED_COLOR)
          add(unresolvedPixels, { x, y })
        else
          local x, y = screenX + pixelOffsetX, screenY + pixelOffsetY
          local value = mandelbrot(x, y, zoom)
          pset(x % 128, y % 128, value)
        end
      end
    end
  end)
end

function processUnresolvedPixels()
  drawToSpritesheet(function()
    while #unresolvedPixels > 0 and stat(1) < cpuThreshold do
      local x, y = unpack(deli(unresolvedPixels, #unresolvedPixels))
      if pixelOffsetX <= x and x <= pixelOffsetX + 127 and pixelOffsetY <= y and y <= pixelOffsetY + 127 then
        local value = mandelbrot(x, y, zoom)
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
    zoom *= 0.5
    pixelOffsetX *= 0.5
    pixelOffsetY *= 0.5
    drawFullSpritesheet()
    return
  end

  -- Process any remaining unresolved pixels first
  if #unresolvedPixels > 0 then
    processUnresolvedPixels()
  end

  -- Move exactly 1 pixel at a time
  local dx = tonum(btn(➡️)) - tonum(btn(⬅️))
  local dy = tonum(btn(⬇️)) - tonum(btn(⬆️))

  if dx == 0 and dy == 0 then
    return
  end

  pixelOffsetX += dx
  pixelOffsetY += dy

  -- Calculate and draw new pixels based on movement
  drawToSpritesheet(function()
    if dx != 0 then
      local screenX = dx > 0 and 127 or 0
      local x = screenX + pixelOffsetX
      for screenY = 0, 127 do
        if stat(1) >= cpuThreshold then
          local y = screenY + pixelOffsetY
          pset(x % 128, y % 128, UNRESOLVED_COLOR)
          add(unresolvedPixels, { x, y })
        else
          local y = screenY + pixelOffsetY
          local value = mandelbrot(x, y, zoom)
          pset(x % 128, y % 128, value)
        end
      end
    end
    if dy != 0 then
      local screenY = dy > 0 and 127 or 0
      local y = screenY + pixelOffsetY
      for screenX = 0, 127 do
        if stat(1) >= cpuThreshold then
          local x = screenX + pixelOffsetX
          pset(x % 128, y % 128, UNRESOLVED_COLOR)
          add(unresolvedPixels, { x, y })
        else
          local x = screenX + pixelOffsetX
          local value = mandelbrot(x, y, zoom)
          pset(x % 128, y % 128, value)
        end
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
      .. "mem: " .. stat(0) .. "\n"
      .. "unresolved: " .. #unresolvedPixels
  local lines = 6
  local letterHeight = 6
  local stringHeight = lines * letterHeight - 1
  local stringWidth = getTextWidth(string)
  local x, y = 128 - stringWidth - 7, 128 - stringHeight - 7
  overlay(x, y, stringWidth + 4, stringHeight + 4)
  print(string, x + 2, y + 2, 13)
end

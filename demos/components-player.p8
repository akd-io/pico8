pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/components.lua

local function getRandomCoord()
  return rnd() * 128
end

local function PlayerComponent(isRunning)
  -- Update
  local x, setX = useState(getRandomCoord)
  local y, setY = useState(getRandomCoord)

  local dx = tonum(btn(➡️)) - tonum(btn(⬅️))
  local dy = tonum(btn(⬇️)) - tonum(btn(⬆️))

  local movementSpeed = isRunning and 2 or 1

  x = setX((x + dx * movementSpeed) % 128)
  y = setY((y + dy * movementSpeed) % 128)

  -- Draw
  local playerRadius = 4
  local darkGray = 5
  circfill(x, y, playerRadius, darkGray)
end

local function Game()
  -- Update
  local isRunning = btn(❎)

  -- Draw
  cls()

  -- Returned child components will be rendered top-to-bottom
  return {
    { PlayerComponent, isRunning }
  }
end

local function _update60() end
local function _draw()
  renderRoot(Game)
end

pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--[[
  React useSpring Test
]]
#include ../lib/react.lua
#include ../lib/react-motion.lua

local function App()
  local targetPosition = btn(❎) and 100 or 10

  local currentPositions, currentVelocities = useSpring({ targetPosition })

  local position = currentPositions[1]

  cls()
  rectfill(position, 20, position + 20, 40, 12)
end

function _update60() end
function _draw()
  renderRoot(App)
end

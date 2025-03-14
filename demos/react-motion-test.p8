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

  return {
    { Motion, rectfill, { targetPosition, 20, targetPosition + 20, 40, 12 } }
  }
end

function _update60() end
function _draw()
  cls()
  renderRoot(App)
end

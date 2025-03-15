pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- React Motion Test
-- by akd
#include ../lib/react.lua
#include ../lib/react-motion.lua

local function App()
  local targetPosition = btn(❎) and 88 or 20

  cls()
  print("❎", 60, 60, btn(❎) and 12 or 5)
  return {
    { Motion, rectfill, { targetPosition, 20, targetPosition + 20, 40, 12 } }
  }
end

function _update60() end
function _draw()
  renderRoot(App)
end

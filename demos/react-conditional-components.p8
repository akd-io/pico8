pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/react.lua

local Counter = createComponent(function(x, y, button)
  local ref = useRef(0)

  if btn(button) then
    ref.current += 1
  end

  print(ref.current, x, y, 7)
end)

local Root = createComponent(function()
  cls(15)

  local seconds = time() \ 1

  if seconds % 2 == 0 then Counter("Counter1", 30, 60, 🅾️) end
  if seconds % 2 == 1 then Counter("Counter2", 60, 60, ❎) end
end)

local function _update60() end
local function _draw()
  renderRoot(Root)
end

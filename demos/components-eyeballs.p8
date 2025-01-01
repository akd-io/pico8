pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/components.lua
#include ../lib/array_methods.lua
#include ../lib/range.lua

local circleComponent = createComponent(function(x, y, r, col)
  circfill(x, y, r, col)
end)

local eyeballComponent = createComponent(function()
  local x, setX = useState(rnd() * 128)
  local y, setY = useState(rnd() * 128)

  setX((x + 1) % 128)
  setY((y + 1) % 128)

  return {
    { circleComponent, x, y, 10, 7 },
    { circleComponent, x, y, 4, 0 }
  }
end)

local containerComponent = createComponent(function()
  cls(15)

  -- Because the last eyeball is only rendered 99% of the time, it will sometimes not be rendered and unmount.
  -- This will result in the last eyeball's getting cleaned up and be given a new initial position when re-mounted.
  -- Eyeballs 1-3 are not conditional, and their state is correctly persisted forever.

  local eyeballs = 3
  if (rnd() < 0.99) then
    eyeballs += 1
  end

  local shouldRenderCenterCircle = btn(❎)

  return {
    shouldRenderCenterCircle
        and { circleComponent, 64, 64, 10, 1 }
        or nil,
    unpack(arrayMap(
      range(eyeballs), function()
        return { eyeballComponent }
      end
    ))
  }
end)

local function _update60() end
local function _draw()
  renderRoot(containerComponent)

  print("mem: " .. stat(0), 0, 10)
end

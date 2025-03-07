pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/components.lua
#include ../lib/array_methods.lua
#include ../lib/range.lua

local black = 0
local darkBlue = 1
local brown = 4
local darkGray = 5
local lightGray = 6
local white = 7

local circleComponent = function(x, y, r, col)
  circfill(x, y, r, col)
end

local getRandomCoord = function() return rnd() * 128 end
local eyeballComponent = function(eyeColor, _x, _y)
  local x, setX = useState(getRandomCoord)
  local y, setY = useState(getRandomCoord)

  y = setY((y + 0.25) % 128)

  return {
    { circleComponent, _x or x, _y or y, 10, white },
    { circleComponent, _x or x, _y or y, 6, eyeColor },
    { circleComponent, _x or x, _y or y, 2, black }
  }
end

local containerComponent = function()
  cls(15)

  -- Because the last eyeball is only rendered 99% of the time, it will sometimes not be rendered and unmount.
  -- This will result in the last eyeball's getting cleaned up and be given a new initial position when re-mounted.
  -- Eyeballs 1-3 are not conditional, and their state is correctly persisted forever.

  local numEyeballs = 3
  if (rnd() < 0.99) then
    numEyeballs += 1
  end

  local shouldRenderCenterEyeball = btn(❎)

  local threeEyeballs = {
    { eyeballComponent, brown },
    { eyeballComponent, brown },
    { eyeballComponent, brown }
  }

  return {
    -- To render a component conditionally without affecting subsequent component keys,
    -- render nil for the negative case, to keep occupying the array index, and thereby key.
    shouldRenderCenterEyeball
        and { eyeballComponent, darkBlue, 64, 64 }
        or nil,
    -- To render a static array of components, simply add the array to the return array.
    threeEyeballs,
    -- To render a dynamic array of variable size, components must specify a key for identification.
    -- You can utilize an array map method to generate component arrays from data.
    -- Do NOT use unpack() to spread the array into the return array,
    -- as that would bump keys of subsequent components.
    arrayMap(
      range(numEyeballs), function(value)
        local key = value
        return { key, eyeballComponent, darkGray }
      end
    ),
    { eyeballComponent, lightGray }
  }
end

local function _update60() end
local function _draw()
  renderRoot(containerComponent)

  print("mem: " .. stat(0), 0, 10)
end

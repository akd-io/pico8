pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/react.lua
#include ../lib/array_methods.lua
#include ../lib/range.lua

local black = 0
local darkBlue = 1
local brown = 4
local darkGray = 5
local lightGray = 6
local white = 7

local CircleComponent = function(x, y, r, col)
  -- Draw
  circfill(x, y, r, col)
end

local getRandomCoord = function() return rnd() * 128 end
local EyeballComponent = function(eyeColor, _x, _y)
  -- Update
  local x, setX = useState(getRandomCoord)
  local y, setY = useState(getRandomCoord)

  y = setY((y + 0.25) % 128)

  -- Returned child components will be rendered top-to-bottom
  return {
    { CircleComponent, _x or x, _y or y, 10, white },
    { CircleComponent, _x or x, _y or y, 6, eyeColor },
    { CircleComponent, _x or x, _y or y, 2, black }
  }
end

local AppComponent = function()
  -- Update
  cls(15)

  -- Conditionally render the center eyeball based on the ❎ button
  local shouldRenderCenterEyeball = btn(❎)

  -- Because the last eyeball is only rendered 99% of the time, it will sometimes not be rendered and unmount.
  -- This will result in the last eyeball's state getting cleaned up and be given a new initial position when re-mounted.
  -- Eyeballs 1-3 are not conditional, and their state is correctly persisted forever.
  local numEyeballs = (rnd() < 0.99) and 4 or 3

  -- Define a static array of components to render
  local twoStaticBrownEyeballs = {
    { EyeballComponent, brown },
    { EyeballComponent, brown }
  }

  -- Returned child components will be rendered top-to-bottom
  return {
    -- To render a component conditionally without affecting subsequent component keys,
    -- render nil for the negative case, to keep occupying the array index, and thereby key.
    shouldRenderCenterEyeball
        and { EyeballComponent, darkBlue, 64, 64 }
        or nil,
    -- To render a static array of components, simply add the array to the return array.
    twoStaticBrownEyeballs,
    -- To render a dynamic array of variable size, components should specify a key for identification.
    -- Otherwise, the array index will be used as key, which can lead to unexpected behavior.
    -- You can utilize an array map method to generate component arrays from data.
    -- Do NOT use unpack() to spread the array into the return array,
    -- as that would bump keys of subsequent components.
    arrayMap(
      range(numEyeballs), function(value)
        local key = value
        return { key, EyeballComponent, darkGray }
      end
    ),
    -- This last component is rendered to show the previous component array doesn't affect this component.
    { EyeballComponent, lightGray }
  }
end

local function _update60() end
local function _draw()
  renderRoot(AppComponent)

  print("mem: " .. stat(0), 0, 10)
end

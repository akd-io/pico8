pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/join.lua
#include ../lib/table_to_str.lua

-- React library
local createComponent, render, useState = (function()
  local hooks = {}
  local hookIndex = 1
  function createComponent(func)
    return function(...)
      local props = pack(...)
      local propsString = props == nil and "nil" or tableToStr(props)
      --printh("Started rendering component with props " .. propsString)
      func(...)
      --printh("Finished rendering component with props " .. propsString)
    end
  end
  function render(root)
    --printh("\nStart render root")
    hookIndex = 1
    --printh("Reset hookIndex to " .. hookIndex)
    root()
    --printh("Finish render root")
  end
  function useState(initialValue)
    --printh("useState: initialValue = " .. initialValue)
    --printh("useState: hookIndex = " .. (hookIndex or "nil"))
    --printh("useState: hooks[hookIndex] = " .. (hooks[hookIndex] or "nil"))
    local value = hooks[hookIndex] or initialValue
    --printh("useState: value = " .. value)
    local _hookIndex = hookIndex
    function setValue(val)
      --printh("useState: setValue: val = " .. val or "nil")
      hooks[_hookIndex] = val
      --printh("useState: setValue: hooks[hookIndex] = " .. (hooks[_hookIndex] or "nil"))
    end
    hookIndex += 1
    --printh("useState: incremented hookIndex to " .. (hookIndex or "nil"))
    --printh("useState: returning value " .. (value or "nil"))
    return value, setValue
  end
  return createComponent, render, useState
end)()

-- Example usage
local frame = 1

local circleComponent = createComponent(function(x, y, r, col)
  circfill(x, y, r, col)
end)

local eyeballComponent = createComponent(function(x, y)
  circleComponent(x, y, 10, 7)
  circleComponent(x, y, 4, 0)
end)

local counterComponent = createComponent(function()
  local count, setCount = useState(0)
  setCount(count + 1)
  printh("count: " .. count)
end)

local containerComponent = createComponent(function()
  local x1, setX1 = useState(0)

  if (frame % 2 == 1) then
    counterComponent()
  end

  local x2, setX2 = useState(0)
  setX1((x1 + 1) % 20)
  setX2((x2 + 1) % 20)

  cls(15)
  eyeballComponent(x1, 64)
  eyeballComponent(x2, 64)
end)

function _update60() end
function _draw()
  render(containerComponent)
  frame += 1
end

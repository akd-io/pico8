pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/join.lua
#include ../lib/table_to_str.lua

-- React library
function initReact()
  local components = {}
  local currentComponent = nil

  function createComponent(func)
    return function(key, ...)
      -- Generate a unique ID for this component instance
      local instanceId = key or "default"

      -- Initialize component state if needed
      if not components[instanceId] then
        components[instanceId] = {
          hooks = {},
          hookIndex = 1
        }
      end

      -- Set current component context
      local prevComponent = currentComponent
      currentComponent = components[instanceId]
      currentComponent.hookIndex = 1

      -- Run component with remaining args
      local props = pack(...)
      local propsString = props == nil and "nil" or tableToStr(props)
      printh("Started rendering component " .. instanceId .. " with props " .. propsString)
      func(...)
      printh("Finished rendering component " .. instanceId .. " with props " .. propsString)

      -- Restore previous component context
      currentComponent = prevComponent
    end
  end

  function useState(initialValue)
    assert(currentComponent, "hooks can only be called inside components")

    local hooks = currentComponent.hooks
    printh("useState: hooks = " .. (tableToStr(hooks) or "nil"))

    local hookIndex = currentComponent.hookIndex
    printh("useState: hookIndex = " .. (hookIndex or "nil"))

    local value = hooks[hookIndex] or initialValue
    printh("useState: hooks[hookIndex] = " .. (hooks[hookIndex] or "nil"))
    printh("useState: initialValue = " .. initialValue)
    printh("useState: value = " .. value)

    local _component = currentComponent
    local _hookIndex = hookIndex

    function setValue(val)
      printh("useState: setValue: val = " .. val or "nil")

      _component.hooks[_hookIndex] = val
      printh("useState: setValue: _component.hooks[_hookIndex] = " .. (_component.hooks[_hookIndex] or "nil"))
    end

    currentComponent.hookIndex += 1
    printh("useState: incremented hookIndex to " .. (currentComponent.hookIndex or "nil"))

    printh("useState: returning value " .. (value or "nil"))
    return value, setValue
  end

  return createComponent, useState
end

local createComponent, useState = initReact()

-- Example usage
local frame = 1

local circleComponent = createComponent(function(x, y, r, col)
  circfill(x, y, r, col)
end)

local eyeballComponent = createComponent(function(x, y)
  circleComponent("circle1", x, y, 10, 7)
  circleComponent("circle2", x, y, 4, 0)
end)

local counterComponent = createComponent(function()
  local count, setCount = useState(0)
  setCount(count + 1)
  print("count: " .. count, 0, 0, 0)
end)

local containerComponent = createComponent(function()
  cls(15)
  local x1, setX1 = useState(0)

  if (frame % 2 == 1) then
    counterComponent("counter1")
  end

  local x2, setX2 = useState(64)
  setX1((x1 + 1) % 128)
  setX2((x2 + 1) % 128)

  eyeballComponent("eye1", x1, 64)
  eyeballComponent("eye2", x2, 64)
end)

function _update60() end
function _draw()
  containerComponent("root")
  frame += 1
end

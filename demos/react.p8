pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
#include ../lib/join.lua
#include ../lib/table_to_str.lua

-- React library
function initReact()
  local components = {}
  local currentComponent = nil
  local frame = 0

  local function createComponent(func)
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
      currentComponent.lastRenderFrame = frame

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

  local function useState(initialValue)
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

    local function setValue(val)
      printh("useState: setValue: val = " .. val or "nil")

      _component.hooks[_hookIndex] = val
      printh("useState: setValue: _component.hooks[_hookIndex] = " .. (_component.hooks[_hookIndex] or "nil"))
    end

    currentComponent.hookIndex += 1
    printh("useState: incremented hookIndex to " .. (currentComponent.hookIndex or "nil"))

    printh("useState: returning value " .. (value or "nil"))
    return value, setValue
  end

  local function renderRoot(rootComponent)
    rootComponent("root")

    -- Clean up any unmounted components
    for k, component in pairs(components) do
      -- If component wasn't rendered this frame, remove it completely
      if component.lastRenderFrame != frame then
        components[k] = nil
      end
    end

    -- Increment frame counter
    frame += 1
  end

  return createComponent, renderRoot, useState
end

local createComponent, renderRoot, useState = initReact()

-- Example usage
local frame = 1

local circleComponent = createComponent(function(x, y, r, col)
  circfill(x, y, r, col)
end)

local eyeballComponent = createComponent(function()
  local x, setX = useState(rnd() * 128)
  local y, setY = useState(rnd() * 128)

  circleComponent("circle1", x, y, 10, 7)
  circleComponent("circle2", x, y, 4, 0)

  setX((x + 1) % 128)
  setY((y + 1) % 128)
end)

local containerComponent = createComponent(function()
  cls(15)

  -- Because the fourth eyeball is only rendered 99% of the time, it will sometimes not be rendered and unmount.
  -- This will result in the fourth eyeball's getting cleaned up and be given a new initial position when re-mounted.
  -- Eyeballs 1-3 are not conditional, and their state is correctly persisted forever.

  local renderFourthEyeball = rnd() < 0.99
  local eyeballs = renderFourthEyeball and 4 or 3
  for i = 1, eyeballs do
    eyeballComponent("eye" .. i)
  end
end)

local function _update60() end
local function _draw()
  renderRoot(containerComponent)

  print(stat(0), 0, 10)

  frame += 1
end

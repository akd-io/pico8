-- Components library

function initComponents()
  local componentInstances = {}
  local currentComponentInstance = nil
  local frame = 0

  local function createComponent(func)
    return function(key, ...)
      assert(key != nil, "key must be provided")
      local instanceId = key

      -- Initialize component state if missing (initial render)
      if not componentInstances[instanceId] then
        componentInstances[instanceId] = {
          hooks = {},
          hookIndex = 1
        }
      end

      -- Set current component context
      local prevComponentInstance = currentComponentInstance
      currentComponentInstance = componentInstances[instanceId]
      currentComponentInstance.hookIndex = 1
      currentComponentInstance.lastRenderFrame = frame

      -- Run component with remaining args
      func(...)

      -- Restore previous component context
      currentComponentInstance = prevComponentInstance
    end
  end

  local stateMetatable = {
    __index = function(t)
      return t.current
    end,
    __newindex = function(t, k, v)
      if k == "current" then
        rawset(t, k, v)
      else
        t.current = v
      end
    end
  }
  -- useState's name is inspired by useState from React, but functions more like useRef, as it is mutable.
  -- In contrast to useRef, it hides its `.current` implementation from the user.
  local function useState(initialValue)
    assert(currentComponentInstance != nil, "hooks can only be called inside components")

    local hooks = currentComponentInstance.hooks
    local hookIndex = currentComponentInstance.hookIndex

    if (hooks[hookIndex] == nil) then
      -- Initial render
      local state = { current = initialValue }
      setmetatable(state, stateMetatable)
      hooks[hookIndex] = state
    end

    currentComponentInstance.hookIndex += 1
    return hooks[hookIndex]
  end

  local function renderRoot(rootComponent)
    rootComponent("__components_root")

    -- Clean up any unmounted component instances
    for k, component in pairs(componentInstances) do
      -- If component wasn't rendered this frame, remove it completely
      if component.lastRenderFrame != frame then
        componentInstances[k] = nil
      end
    end

    -- Increment frame counter
    frame += 1
  end

  return createComponent, renderRoot, useState
end

local createComponent, renderRoot, useState = initComponents()
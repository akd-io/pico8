-- Components library

function initComponents()
  local components = {}
  local currentComponent = nil
  local frame = 0

  local function createComponent(func)
    return function(key, ...)
      assert(key != nil, "key must be provided")
      local instanceId = key

      -- Initialize component state if missing
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
      func(...)

      -- Restore previous component context
      currentComponent = prevComponent
    end
  end

  -- Name is inspired by useState from React, but functions more like useRef.
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

  local function useState(initialValue)
    assert(currentComponent, "hooks can only be called inside components")

    local hooks = currentComponent.hooks
    local hookIndex = currentComponent.hookIndex

    if (hooks[hookIndex] == nil) then
      local state = { current = initialValue }
      setmetatable(state, stateMetatable)
      hooks[hookIndex] = state
    end

    local _component = currentComponent
    local _hookIndex = hookIndex

    currentComponent.hookIndex += 1
    return hooks[hookIndex]
  end

  local function renderRoot(rootComponent)
    rootComponent("__components_root")

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

local createComponent, renderRoot, useState = initComponents()
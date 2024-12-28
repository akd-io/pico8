-- Components library

-- Future TODOs:
-- TODO: Turn __initComponents into an immediately invoked anonymous function expression
--[[
  TODO: Add support for conditional component renders by specifying children in an array.
  - Component instances should then use their position in the children array to generate their instance id.
  - This way, child component instances will keep their ids between renders, even when some are rendered conditionally.
      (That is when specifying nil instead of a component in the children array.)
  - In turn, make the key prop optional. What API to specify kep prop has the nicest DX?
]]

function __initComponents()
  -- Holds the state of component instances
  local componentInstances = {}

  -- Used to generate component IDs during component creation
  local componentCreationCounter = 0

  -- Used during render
  local currentComponentInstance = nil
  local currentComponentInstanceId = nil
  local frame = 0

  local function createComponent(func)
    local componentId = componentCreationCounter
    componentCreationCounter += 1

    return function(key, ...)
      assert(key != nil, "key must be provided")

      -- Save parent/previous component instance and id
      local parentComponentInstanceId = currentComponentInstanceId
      local parentComponentInstance = currentComponentInstance

      -- Generate instance id
      local instanceId = parentComponentInstanceId .. "-" .. key

      -- Initialize component state if missing (initial render)
      if not componentInstances[instanceId] then
        componentInstances[instanceId] = {
          hooks = {},
          hookIndex = 1
        }
      end

      -- Update current component context
      currentComponentInstanceId = instanceId
      currentComponentInstance = componentInstances[instanceId]
      currentComponentInstance.hookIndex = 1
      currentComponentInstance.lastRenderFrame = frame

      -- Run component with remaining args
      func(...)

      printh("Rendering " .. currentComponentInstanceId)

      -- Restore parent component context
      currentComponentInstanceId = parentComponentInstanceId
      currentComponentInstance = parentComponentInstance
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
    for k, componentInstance in pairs(componentInstances) do
      -- If component wasn't rendered this frame, remove it completely
      if componentInstance.lastRenderFrame != frame then
        componentInstances[k] = nil
      end
    end

    -- Increment frame counter
    frame += 1
  end

  return createComponent, renderRoot, useState
end

local createComponent, renderRoot, useState = __initComponents()
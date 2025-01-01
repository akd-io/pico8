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
  local instances = {}

  -- Used to generate component IDs during component creation
  local componentCreationCounter = 0

  -- Used during render
  local currentInstance = nil
  local currentInstanceId = nil
  local frame = 0

  local function createComponent(func)
    local componentId = componentCreationCounter
    componentCreationCounter += 1

    return function(key, ...)
      assert(key != nil, "key must be provided")

      -- Save parent/previous component instance and id
      local parentInstanceId = currentInstanceId
      local parentInstance = currentInstance

      -- Generate instance id
      local prefix = parentInstanceId and parentInstanceId .. "-" or ""
      local instanceId = prefix .. key

      -- Initialize component state if missing (initial render)
      if not instances[instanceId] then
        instances[instanceId] = { hooks = {} }
      end

      -- Update current component context
      currentInstanceId = instanceId
      currentInstance = instances[instanceId]
      currentInstance.hookIndex = 1
      currentInstance.lastRenderFrame = frame

      -- Run component with remaining args
      local elements = func(...)

      printh("Rendering " .. currentInstanceId)

      -- Restore parent component context
      currentInstanceId = parentInstanceId
      currentInstance = parentInstance
    end
  end

  -- useState is inspired by useState from React.
  -- In contrast to React's useState, it is mutable, as this library doesn't rerender on state changes.
  -- Along with the state, the function returns a setState function to enable updates to non-table types, or complete overrides of tables.
  -- Tables can largely ignore the setState function by updating table properties directly.
  local function useState(initialValue)
    assert(currentInstance != nil, "hooks can only be called inside components")

    -- TODO: Support setter function argument

    local hooks = currentInstance.hooks
    local hookIndex = currentInstance.hookIndex

    if (hooks[hookIndex] == nil) then
      hooks[hookIndex] = initialValue
    end

    local function setState(newValue)
      hooks[hookIndex] = newValue
      return newValue
    end

    currentInstance.hookIndex += 1
    return hooks[hookIndex], setState
  end

  local function renderRoot(rootComponent)
    rootComponent("__components_root")

    -- Clean up any unmounted component instances
    for k, instance in pairs(instances) do
      -- If component wasn't rendered this frame, remove it completely
      if instance.lastRenderFrame != frame then
        instances[k] = nil
      end
    end

    -- Increment frame counter
    frame += 1
  end

  return createComponent, renderRoot, useState
end

local createComponent, renderRoot, useState = __initComponents()
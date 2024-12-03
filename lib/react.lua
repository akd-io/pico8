--[[
-- TODO: Remove key requirement. Build component tree. Fix conditional component rendering problem using insight from JSX output below. (Children needs to be specified in a tree for component indexes not to change during conditional rendering or loops)
<div>
  <h1>Using Context and useReducer</h1>
  {state}
  {state % 2 == 0 && <Counter />}
  {state % 2 == 1 && <Counter />}
</div>

/*#__PURE__*/_jsxs(
  "div",
  {
    children: [
      /*#__PURE__*/_jsx("h1", {
        children: "Using Context and useReducer"
      }),
      state,
      state % 2 == 0 && /*#__PURE__*/_jsx(Counter, {}),
      state % 2 == 1 && /*#__PURE__*/_jsx(Counter, {})
    ]
  }
);
]]

-- React library
function initReact()
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

  local function useState(initialValue)
    assert(currentComponent, "hooks can only be called inside components")

    local hooks = currentComponent.hooks
    local hookIndex = currentComponent.hookIndex

    local value = hooks[hookIndex] or initialValue

    local _component = currentComponent
    local _hookIndex = hookIndex

    local function setValue(val)
      _component.hooks[_hookIndex] = val
    end

    currentComponent.hookIndex += 1
    return value, setValue
  end

  local function useRef(initialValue)
    assert(currentComponent, "hooks can only be called inside components")

    local hooks = currentComponent.hooks
    local hookIndex = currentComponent.hookIndex

    if (hooks[hookIndex] == nil) then
      hooks[hookIndex] = { current = initialValue }
    end

    local _component = currentComponent
    local _hookIndex = hookIndex

    currentComponent.hookIndex += 1
    return hooks[hookIndex]
  end

  local function renderRoot(rootComponent)
    rootComponent("__react_root")

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

  return createComponent, renderRoot, useRef, useState
end

local createComponent, renderRoot, useRef, useState = initReact()
-- Components library

-- TODO: Turn __initComponents into an immediately invoked anonymous function expression
--[[
  TODO: Re-add key prop as optional. What API to specify kep prop has the nicest DX?
    - Maybe we can implement custom component keys by supporting element[1] == "number" as a test for keyed component elements of the form { 23, MyComponent, ...props }
]]
--[[
  TODO: Should we implement component wrappings for the different drawing operations?
    - Like the HTML elements in react-dom, we could provide components like Circle, Rect, Line, Text, etc..
]]
-- TODO: Should we provide a createLayoutComponent or something, that provides a default inset for drawing ops of child components? I have a feeling this could be made third party if useContext was supported. Maybe other hacks could make it work too.

--[[
  FYI, one might think, why aren't we just calling component render functions inside other component render functions directly.
  We return and render elements instead, as calling render functions directly can make children render before their parents.
  Imagine the following rendering implementation:
  Function calls:
  Container(
    Header(),
    Body(
      Paragraph("Hello world"),
      Paragraph("Goodbye world")
    )
  )
  Here, the Paragraph components would run before being passed to Body.
  And Header and Body would run before being passed to Container.
  This is problematic if, for example, Body is painting a background to be displays behind the Paragraphs.
  It is possible to implement a developer experience like the above, where we call components as functions.
  But the Container, Header, Body and Paragraph functions wouldn't be a render function but instead a small element creator function.
  And we would still need this renderElements function. The element syntax would just be hidden from users.
  Function calls:                   Resulting elements:
  Container({                       { Container, {
    Header(),                         { Header },
    Body({                            { Body, {
      Paragraph("Hello world"),         { Paragraph, "Hello world" },
      Paragraph("Goodbye world")        { Paragraph, "Goodbye world" }
    })                                }
  })                                }
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

  local function createComponent(externalComponentRenderFunc)
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

      printh("Rendering " .. instanceId)

      -- Initialize component state if missing (initial render)
      if not instances[instanceId] then
        instances[instanceId] = { hooks = {} }
      end

      -- Update current component context
      currentInstanceId = instanceId
      currentInstance = instances[instanceId]
      currentInstance.hookIndex = 1
      currentInstance.lastRenderFrame = frame

      -- Render component with remaining args
      local elements = externalComponentRenderFunc(...)
      if elements != nil then
        assert(type(elements) == "table", "Elements must be tables. Got type " .. type(elements) .. ".")

        -- Render elements
        -- An element is a table whose first value is an internal render function, and whose remaining values are component props.
        for elementKey, element in pairs(elements) do
          local internalComponentRenderFunc = element[1]
          local renderFuncType = type(internalComponentRenderFunc)
          assert(renderFuncType == "function", "Elements must be tables with a function as the first element. Got Type " .. renderFuncType .. ".")
          internalComponentRenderFunc(elementKey, select(2, unpack(element)))
        end
      end

      -- Restore parent component context
      currentInstanceId = parentInstanceId
      currentInstance = parentInstance
    end
  end

  -- useState is inspired by useState from React.
  -- In contrast to React's useState, it embraces mutability, as this library neither tracks nor rerenders on state changes.
  -- Along with the state, the function returns a setState function to enable updates to non-table types, or complete overrides of tables.
  -- Tables can largely ignore the setState function by updating table properties directly.
  -- TODO: Support setter function argument?
  local function useState(initialValue)
    assert(currentInstance != nil, "hooks can only be called inside components")

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

  local function renderRoot(component)
    component("root")

    -- Clean up any unmounted component instances
    for instanceId, instance in pairs(instances) do
      -- If component wasn't rendered this frame, remove it completely
      if instance.lastRenderFrame != frame then
        instances[instanceId] = nil
      end
    end

    frame += 1
  end

  return createComponent, renderRoot, useState
end

local createComponent, renderRoot, useState = __initComponents()
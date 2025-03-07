-- Components library

-- TODO: Hide element syntax by wrapping the returned internal render function in a createElement function that takes the same arguments as the external component render function, but returns the element syntax for internal use.
--       - I think this will require a change to the keyed element syntax; from {key,component,prop1,prop2,...} to {key,{component,prop1,prop2,...}}
-- TODO: Turn __initComponents into an immediately invoked anonymous function expression
-- TODO: Should we implement component wrappings for the different drawing operations?
--       - Like the HTML elements in react-dom, we could provide components like Circle, Rect, Line, Text, etc..
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
  The element syntax would just be hidden from users.
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

  -- Used during render
  local currentInstance = nil
  local currentInstanceId = nil
  local frame = 0

  local function internalRenderFunction(key, externalFunctionComponent, ...)
    assert(key != nil, "key must be provided")

    -- Save parent/previous component instance and id
    local parentInstance = currentInstance
    local parentInstanceId = currentInstanceId

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
    local elements = externalFunctionComponent(...)
    if elements != nil then
      assert(type(elements) == "table", "Elements array must be a table. Got " .. type(elements) .. ".")

      local function renderElements(elements, prefix)
        -- An element is a table whose first value is an internal render function, and whose remaining values are component props.
        for index, element in pairs(elements) do
          assert(type(element) == "table", "Element must be a table. Got " .. type(element) .. ".")
          local firstValue = element[1]
          local firstValueType = type(firstValue)

          assert(firstValueType == "table" or firstValueType == "number" or firstValueType == "string" or firstValueType == "function", "First value of an element must be a key (number or string), a render function, or another element when it is a fragment (array of elements). Got " .. firstValueType .. ".")

          if (firstValueType == "table") then
            -- If firstValueType == "table" then element is a fragment (array of elements)
            -- and should have all its elements rendered
            -- Their keys will be prefixed with the index of the fragment
            renderElements(element, index .. "-")
          else
            local isKeyedElement = firstValueType == "number" or firstValueType == "string"
            local key = isKeyedElement and firstValue or index
            local externalFunctionComponent = isKeyedElement and element[2] or firstValue

            local renderFuncType = type(externalFunctionComponent)
            assert(renderFuncType == "function", "Elements must be tables with a function as the first element. Got Type " .. renderFuncType .. ".")
            local indexOfFirstProp = isKeyedElement and 3 or 2
            internalRenderFunction((prefix or "") .. key, externalFunctionComponent, select(indexOfFirstProp, unpack(element)))
          end
        end
      end

      renderElements(elements)
    end

    -- Restore parent component context
    currentInstanceId = parentInstanceId
    currentInstance = parentInstance
  end

  -- useState is inspired by useState from React.
  -- In contrast to React's useState, it embraces mutability, as this library neither tracks nor rerenders on state changes.
  -- Along with the state, the function returns a setState function to enable updates to non-table types, or complete overrides of tables.
  -- Table states can largely ignore the setState function by updating table properties directly.
  -- useState can be called with a non-function value or a setter function.
  -- Storing functions can be achieved by wrapping the function in a table, or by returning the function from a setter function.
  local function useState(initialValue)
    assert(currentInstance != nil, "hooks can only be called inside components")

    local hooks = currentInstance.hooks
    local hookIndex = currentInstance.hookIndex

    if (hooks[hookIndex] == nil) then
      hooks[hookIndex] = type(initialValue) == "function" and initialValue() or initialValue
    end

    local function setState(newValue)
      hooks[hookIndex] = newValue
      return newValue
    end

    currentInstance.hookIndex += 1
    return hooks[hookIndex], setState
  end

  local function renderRoot(externalFunctionComponent)
    internalRenderFunction("1", externalFunctionComponent)

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
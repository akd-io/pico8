-- Components library

--[[
  TODOs:
  - Should we implement component wrappings for the different drawing operations?
    - Like the HTML elements in react-dom, we could provide components like Circle, Rect, Line, Text, etc..
  - Should we provide a createLayoutComponent or something, that provides a default inset for drawing ops of child components? I have a feeling this could be made third party if useContext was supported. Maybe other hacks could make it work too.
  - Benchmark library
  - Optimizations for minified production version:
    - Turn __initComponents into an immediately invoked anonymous function expression
    - Delete comments
    - Delete assertions
    - Save `local` tokens by initializing multiple variables on the same line

  One might think; Why aren't we just calling our function components directly?
  The reason we don't call function components directly, is because that would make children render before their parents.
  Imagine the following example:

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
  Therefore, we use the element syntax below.

  Function syntax:                  Element syntax:
  Container({                       { Container, {
    Header(),                         { Header },
    Body({                            { Body, {
      Paragraph("Hello world"),         { Paragraph, "Hello world" },
      Paragraph("Goodbye world")        { Paragraph, "Goodbye world" }
    })                                }
  })                                }

  It is possible to implement a developer experience like the function syntax above, where we seemingly call our function components directly.
  But this would require us to declare function components using a `createComponent()` wrapper function.
  The wrapper function would return simply return the element syntax hidden to the user.
  For now, I have chosen to embrace the simplicity and token/cpu savings of the element syntax.
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
    -- TODO: Consider not only accepting a fragment here, but also the different element types supported in renderElements
    if elements != nil then
      assert(type(elements) == "table", "Elements array must be a table. Got " .. type(elements) .. ".")

      local function renderElements(elements, prefix)
        -- An element is a table whose first value is an internal render function, and whose remaining values are component props.
        for index, element in pairs(elements) do
          -- TODO: Consider accepting type(element) == "table" in the case of a propless unkeyed components
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

  return renderRoot, useState
end

local renderRoot, useState = __initComponents()
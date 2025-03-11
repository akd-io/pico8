local renderRoot, useState = (function()
  local instances = {}
  local currentInstanceId = nil
  local frame = 0
  local function internalRenderFunction(key, externalFunctionComponent, ...)
    local parentInstanceId = currentInstanceId
    local prefix = parentInstanceId and parentInstanceId .. "-" or ""
    local instanceId = prefix .. sub(tostring(externalFunctionComponent), 13) .. "_" .. key
    if not instances[instanceId] then
      instances[instanceId] = { hooks = {} }
    end
    currentInstanceId = instanceId
    instances[instanceId].hookIndex = 1
    instances[instanceId].lastRenderFrame = frame
    local elements = externalFunctionComponent(...)
    if elements != nil then
      local function renderElements(elements, prefix)
        for index, element in pairs(elements) do
          local firstValue = element[1]
          local firstValueType = type(firstValue)
          if (firstValueType == "table") then
            renderElements(element, index .. "-")
          else
            local isKeyedElement = firstValueType == "number" or firstValueType == "string"
            local key = isKeyedElement and firstValue or index
            local externalFunctionComponent = isKeyedElement and element[2] or firstValue
            local renderFuncType = type(externalFunctionComponent)
            local indexOfFirstProp = isKeyedElement and 3 or 2
            internalRenderFunction((prefix or "") .. key, externalFunctionComponent, select(indexOfFirstProp, unpack(element)))
          end
        end
      end
      renderElements(elements)
    end
    currentInstanceId = parentInstanceId
  end
  local function useState(initialValue)
    local currentInstance = instances[currentInstanceId]
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
    for instanceId, instance in pairs(instances) do
      if instance.lastRenderFrame != frame then
        instances[instanceId] = nil
      end
    end
    frame += 1
  end
  return renderRoot, useState
end)()
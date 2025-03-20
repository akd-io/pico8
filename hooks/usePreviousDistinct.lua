--[[
  REQUIREMENTS:
  - react.lua
]]

-- usePreviousDistinct will return the last distinct value
local function usePreviousDistinct(current)
  local state = useState({
    prev = nil,
    current = nil
  })
  useMemo(
    function()
      state.prev = state.current
      state.current = current
    end, { current }
  )
  return state.prev
end
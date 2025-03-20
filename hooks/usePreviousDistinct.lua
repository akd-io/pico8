--[[
  usePreviousDistinct will return the previous distinct value.

  REQUIREMENTS:
  - react.lua
]]
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
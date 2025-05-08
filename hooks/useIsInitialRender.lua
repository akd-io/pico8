--[[
  useIsInitialRender returns true on the first render, and false on all subsequent renders.
  Basically an onMount lifecycle hook.

  REQUIREMENTS:
  - react.lua
]]

local function useIsInitialRender()
  local state, setState = useState(1)
  if (state == 0) then
    return false
  end
  setState(0)
  return true
end
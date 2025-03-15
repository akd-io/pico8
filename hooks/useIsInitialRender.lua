local function useIsInitialRender()
  local state, setState = useState(1)
  if (state == 0) then
    return false
  end
  setState(0)
  return true
end
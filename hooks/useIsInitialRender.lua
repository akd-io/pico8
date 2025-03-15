local function useIsInitialRender()
  local isInitialRender, set = useState(1)
  if (isInitialRender == 0) then
    return false
  end
  set(0)
  return true
end
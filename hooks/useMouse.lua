local function useMouse()
  useMemo(
    function()
      poke(0x5F2D, 0x1)
    end, {}
  )

  local x, y, buttonBitfield = stat(32), stat(33), stat(34)
  local leftButton = buttonBitfield & 1 > 0
  local rightButton = buttonBitfield & 2 > 0

  local leftDragStart = useMemo(
    function()
      return { x, y }
    end, { leftButton }
  )
  local rightDragStart = useMemo(
    function()
      return { x, y }
    end, { rightButton }
  )

  local showLeftSelection = leftButton and (x != leftDragStart[1] or y != leftDragStart[2])

  return {
    x = x,
    y = y,
    leftButton = leftButton,
    rightButton = rightButton,
    leftDragStart = leftDragStart,
    rightDragStart = rightDragStart,
    showLeftSelection = showLeftSelection
  }
end
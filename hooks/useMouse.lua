--[[
  REQUIREMENTS:
  - react.lua
  - usePrevious.lua
]]

__initMouseProvider = function()
  local MouseContext = createContext()

  local function MouseProvider(children)
    useMemo(function() poke(0x5F2D, 0x1) end, {})

    local x, y, buttonBitfield = stat(32), stat(33), stat(34)

    local leftDown = buttonBitfield & 0b01 > 0
    local rightDown = buttonBitfield & 0b10 > 0

    local leftDragStart = useMemo(
      function() return { x, y } end,
      { leftDown }
    )
    local rightDragStart = useMemo(
      function() return { x, y } end,
      { rightDown }
    )

    local leftHasMovedWhileDown = x != leftDragStart[1] or y != leftDragStart[2]
    local rightHasMovedWhileDown = x != rightDragStart[1] or y != rightDragStart[2]

    local leftJustReleased = usePrevious(leftDown) and not leftDown
    local rightJustReleased = usePrevious(rightDown) and not rightDown

    return {
      {
        MouseContext.Provider,
        {
          x = x,
          y = y,
          leftDown = leftDown,
          rightDown = rightDown,
          leftClicked = leftJustReleased and not leftHasMovedWhileDown,
          rightClicked = rightJustReleased and not rightHasMovedWhileDown,
          leftDragged = leftJustReleased and leftHasMovedWhileDown,
          rightDragged = rightJustReleased and rightHasMovedWhileDown,
          leftDragStart = leftDragStart,
          rightDragStart = rightDragStart,
          leftSelection = leftDown and leftHasMovedWhileDown and { x, y, leftDragStart[1], leftDragStart[2] },
          rightSelection = rightDown and rightHasMovedWhileDown and { x, y, rightDragStart[1], rightDragStart[2] }
        },
        children
      }
    }
  end

  local function useMouse()
    return useContext(MouseContext)
  end

  return MouseProvider, useMouse
end
local MouseProvider, useMouse = __initMouseProvider()
--[[
  useClickableArea handles mouse interactions with a clickable area.

  REQUIREMENTS:
  - react.lua
  - useMouse.lua
]]

local function useClickableArea(x1, y1, x2, y2)
  local mouse = useMouse()
  local isHovering = x1 <= mouse.x and mouse.x <= x2 and y1 <= mouse.y and mouse.y <= y2

  return {
    isHovering = isHovering,
    leftDown = isHovering and mouse.leftDown,
    rightDown = isHovering and mouse.rightDown,
    leftClicked = isHovering and mouse.leftClicked,
    rightClicked = isHovering and mouse.rightClicked
  }
end
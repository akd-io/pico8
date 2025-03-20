--[[
  useClickableArea handles mouse interactions with a clickable area.

  REQUIREMENTS:
  - react.lua
  - useMouse.lua
]]

local function useClickableArea(x1, y1, x2, y2)
  local mouse = useMouse()
  local isHovering = mouse.x >= x1 and mouse.x <= x2 and mouse.y >= y1 and mouse.y <= y2

  return {
    isHovering = isHovering,
    leftClicked = isHovering and mouse.leftClicked,
    rightClicked = isHovering and mouse.rightClicked
  }
end
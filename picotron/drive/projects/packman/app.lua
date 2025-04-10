--[[pod_format="raw",created="2025-04-09 22:01:06",modified="2025-04-09 22:12:56",revision=5]]
include("/hooks/usePrevious.lua")
include("/hooks/useMouse.lua")
MouseProvider, useMouse = __initMouseProvider()
include("/hooks/useClickableArea.lua")

---@param props { text: string, x: number, y: number, color: number }
local function Text(props)
  assert(type(props.text) == "string", "text must be a string, got " .. type(props.text))
  assert(type(props.x) == "number", "x must be a number, got " .. type(props.x))
  assert(type(props.y) == "number", "y must be a number, got " .. type(props.y))
  assert(type(props.color) == "number", "color must be a number, got " .. type(props.color))

  print(props.text, props.x, props.y, props.color or 0)
end

---@param props { x1: number, y1: number, x2: number, y2: number, color: number, children?: table }
local function Rectfill(props)
  assert(type(props.x1) == "number", "x1 must be a number, got " .. type(props.x1))
  assert(type(props.y1) == "number", "y1 must be a number, got " .. type(props.y1))
  assert(type(props.x2) == "number", "x2 must be a number, got " .. type(props.x2))
  assert(type(props.y2) == "number", "y2 must be a number, got " .. type(props.y2))
  assert(type(props.color) == "number", "color must be a number, got " .. type(props.color))

  rectfill(props.x1, props.y1, props.x2, props.y2, props.color)
  return {
    props.children
  }
end

local buttonXPadding = 4

---@param props { text: string, x1: number, y1: number, x2: number, y2: number, onClick: function }
local function Button(props)
  local text, x1, y1, x2, y2, bgColor = props.text, props.x1, props.y1, props.x2, props.y2, props.bgColor
  assert(type(text) == "string", "text must be a string, got " .. type(text))
  assert(type(x1) == "number", "x1 must be a number, got " .. type(x1))
  assert(type(y1) == "number", "y1 must be a number, got " .. type(y1))
  assert(type(x2) == "number", "x2 must be a number, got " .. type(x2))
  assert(type(y2) == "number", "y2 must be a number, got " .. type(y2))
  assert(type(props.onClick) == "function", "onClick must be a function, got " .. type(props.onClick))
  assert(x1 < x2, "x1 must be less than x2")
  assert(y1 < y2, "y1 must be less than y2")

  local clickArea = useClickableArea(x1, y1, x2, y2)

  if (clickArea.leftClicked) then
    props.onClick()
  end

  return {
    { Rectfill, {
      x1 = x1,
      y1 = y1,
      x2 = x2,
      y2 = y2,
      color = bgColor or clickArea.isHovering and 7 or 6,
      children = {
        { Text, {
          text = text,
          x = x1 + buttonXPadding,
          y = y1 + 4,
          color = 0
        } }
      }
    } }
  }
end

---@param props { x:number, y:number, tabs: { name: string, content: string }[] }
local function Tabs(props)
  local x, y, tabs, width = props.x, props.y, props.tabs, props.width, props.height
  assert(type(x) == "number", "x must be a number, got " .. type(x))
  assert(type(y) == "number", "y must be a number, got " .. type(y))
  assert(type(props.tabs) == "table", "tabs must be a table, got " .. type(props.tabs))
  assert(#props.tabs > 0, "tabs must have at least one tab, got " .. #props.tabs)
  assert(type(props.tabs[1].name) == "string", "tab name must be a string, got " .. type(props.tabs[1].name))
  assert(type(props.tabs[1].content) == "string", "tab content must be a string, got " .. type(props.tabs[1].content))
  assert(type(width) == "number", "width must be a number, got " .. type(width))

  local state = useState({
    selectedTabIndex = 1
  })

  local height = 14

  local xAccumulator = 0
  local buttonPadding = 2 * buttonXPadding
  local enrichedTabs = arrayMap(tabs, function(tab, i)
    local buttonWidth = print(tab.name, 0, 1000) - 1 + buttonPadding
    local result = { i, Button, {
      x1 = x + xAccumulator,
      y1 = y,
      x2 = x + xAccumulator + buttonWidth,
      y2 = y + height,
      text = tab.name,
      onClick = function()
        state.selectedTabIndex = i
      end,
      bgColor = state.selectedTabIndex == i and 7 or nil
    } }
    xAccumulator += buttonWidth
    return result
  end)

  return {
    { Rectfill, {
      x1 = x,
      y1 = y,
      x2 = x + width,
      y2 = y + height,
      color = 6
    } },

    enrichedTabs,

    { Text, {
      text = tabs[state.selectedTabIndex].content,
      x = x + 4,
      y = y + height + 4,
      color = 1
    } }
  }
end

printh(describe(ls("bbs://new")))
printh(describe(ls("bbs://new/0")))

local function useCarts(url)
  return useMemo(function()
    local carts = {}
    for _, pageDirectory in ipairs(ls(url)) do
      for _, cart in ipairs(ls(pageDirectory)) do
        add(carts, cart)
      end
    end
    return carts
  end, { url })
end

function App()
  cls(7)

  local new = useCarts("bbs://new")
  local featured = useCarts("bbs://featured")
  local wip = useCarts("bbs://wip")


  return {
    { MouseProvider, {
      { Tabs, {
        x = 0,
        y = 0,
        width = width,
        tabs = {
          {
            name = "New",
            content = "New carts go here",
          },
          {
            name = "Featured",
            content = "Featured carts go here",
          }
        }
      } },
    } }
  }
end

pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- inventory demo
-- by akd

#include ../../../lib/shallow_copy.lua
#include ../../../lib/round_rect.lua
#include ../../../lib/round_rectfill.lua
#include ../../../lib/get_text_width.lua
#include ../../../lib/simple_print_center.lua
#include ../../../lib/find.lua
#include ../../../lib/array_methods.lua
#include ../lib/items.lua
#include ../lib/generate_item.lua

function makeInventory(rows)
  return {
    rows = rows or 3,
    columns = 10,
    cellWidth = 10,
    cellHeight = 10,
    cellPadding = 1,
    items = {}
  }
end

function fillInventory(inventory)
  for row = 1, inventory.rows do
    for column = 1, inventory.columns do
      inventory.items[(row - 1) * inventory.columns + column] = rnd() > 0.1 and generateItem() or nil
    end
  end
end

function drawInventory(inventory, highlight, outerX, outerY, inventoryType)
  local cellPadding = inventory.cellPadding
  local cellWidth = inventory.cellWidth
  local cellHeight = inventory.cellHeight
  local columns = inventory.columns
  local rows = inventory.rows
  local items = inventory.items

  -- Draw background
  local width = cellPadding + columns * (cellWidth + cellPadding)
  local height = cellPadding + rows * (cellHeight + cellPadding)
  roundRectfill(outerX, outerY, outerX + width - 1, outerY + height - 1, 6)

  -- Draw item backgrounds and tiers
  for column = 1, columns do
    for row = 1, rows do
      local item = items[(row - 1) * columns + column]

      local x = outerX + cellPadding + (column - 1) * (cellWidth + cellPadding)
      local y = outerY + cellPadding + (row - 1) * (cellHeight + cellPadding)

      -- Draw gray item background
      roundRectfill(x, y, x + cellWidth - 1, y + cellHeight - 1, 5)
      if (item ~= nil) then
        -- Draw tiered item background
        roundRect(x, y, x + cellWidth - 1, y + cellHeight - 1, getTier(item) \ 6)

        -- Draw item sprite
        local spriteId = findi(item_types, item.equipment_type) - 1
        spr(spriteId, x + 1, y + 1)
      elseif inventoryType == "equipment" then
        -- Draw item sprite
        local spriteId = 15 + column
        spr(spriteId, x + 1, y + 1)
      elseif inventoryType == "safe" then
        local spriteId = 27
        spr(spriteId, x + 1, y + 1)
      end
    end
  end

  if (highlight ~= nil) then
    -- Draw highlight
    local highlightX = outerX + (highlight.x - 1) * (cellWidth + cellPadding)
    local highlightY = outerY + (highlight.y - 1) * (cellHeight + cellPadding)
    roundRect(highlightX, highlightY, highlightX + cellWidth + 1, highlightY + cellHeight + 1, 7, true)
  end
end

local equipmentInventory = makeInventory(1)
local safeInventory = makeInventory(2)
local volatileInventory = makeInventory(3)
local inventories = { equipmentInventory, safeInventory, volatileInventory }

local equipmentInventoryOffset = 0
local safeInventoryOffset = 1
local volatileInventoryOffset = 3
local rowOffsets = { equipmentInventoryOffset, safeInventoryOffset, volatileInventoryOffset }

local rowToInventory = { 1, 2, 2, 3, 3, 3 }

local totalColumns = inventories[1].columns
local totalRows = arrayReduce(inventories, function(acc, cur) return acc + cur.rows end, 0)

local selectedColumn, selectedRow = 1, 1

function _init()
  menuitem(
    1, "fill inventory", function()
      fillInventory(equipmentInventory)
      fillInventory(safeInventory)
      fillInventory(volatileInventory)
    end
  )
end

function _update60()
  local dx = tonum(btnp(➡️)) - tonum(btnp(⬅️))
  local dy = tonum(btnp(⬇️)) - tonum(btnp(⬆️))
  selectedColumn = mid(1, selectedColumn + dx, totalColumns)
  selectedRow = mid(1, selectedRow + dy, totalRows)
end

function _draw()
  cls(1)

  local currentInventoryIndex = rowToInventory[selectedRow]
  local currentInventory = currentInventoryIndex == 1 and equipmentInventory
      or currentInventoryIndex == 2 and safeInventory
      or currentInventoryIndex == 3 and volatileInventory

  local highlight = {
    x = selectedColumn,
    y = selectedRow
        - (currentInventoryIndex == 1 and equipmentInventoryOffset
          or currentInventoryIndex == 2 and safeInventoryOffset
          or currentInventoryIndex == 3 and volatileInventoryOffset)
  }

  drawInventory(
    equipmentInventory, currentInventoryIndex == 1 and highlight or nil,
    1, 1,
    "equipment"
  )
  drawInventory(
    safeInventory, currentInventoryIndex == 2 and highlight or nil,
    1, 14,
    "safe"
  )
  drawInventory(
    volatileInventory, currentInventoryIndex == 3 and highlight or nil,
    1, 38
  )

  -- Draw selected item
  local selectedItem = currentInventory.items[(highlight.y - 1) * currentInventory.columns + highlight.x]
  if (selectedItem ~= nil) then
    drawItem(selectedItem, 1, 73)
  end
end

__gfx__
000d00000000000000000000000000000000000000000000000000000000000000dde000000e8000000000000000000000000000000000000000000000000000
000d00000dddeee00000000000ddee00ddd00eee000000000d11d2e0000000000d11ee0000482400000000000000000000000000000000000000000000000000
000d00000d1122e000ddee000d0000e0d11de22e0dddeee00d11d2e00ddee0000d11e2e004a00a40000000000000000000000000000000000000000000000000
000d00000d1122e00d1122e00d0000e0d111222ed000000e0d11d2e00d12e0000d11e2e00a0000a0000000000000000000000000000000000000000000000000
000d00000d1122e00d1122e000d00e000d1122e0d000000e0d11d2e00d11ee000d1122e009000090000000000000000000000000000000000000000000000000
00dde00000d12e000dddeee0000a90000d1122e00dd9aee00d11d2e00d1122e000d12e0004a00a40000000000000000000000000000000000000000000000000
00010000000de000000000000004a0000d1122e0000000000ddddee000ddee0000ddee000049a400000000000000000000000000000000000000000000000000
0001000000000000000000000000000000ddee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00000000000000000000000000000000000000000000000000000000000000ddd000000dd000dddddddd0000000000000000000000000000000000000000
000d00000dddddd00000000000dddd00ddd00ddd000000000d00d0d0000000000d00dd0000dddd00d000000d0dddddd000000000000000000000000000000000
000d00000d0000d000dddd000d0000d0d00dd00d0dddddd00d00d0d00dddd0000d00d0d00dd00dd0d000000d0d0000d000000000000000000000000000000000
000d00000d0000d00d0000d00d0000d0d000000dd000000d0d00d0d00d00d0000d00d0d00d0000d0dddddddd0dddddd000000000000000000000000000000000
000d00000d0000d00d0000d000d00d000d0000d0d000000d0d00d0d00d00dd000d0000d00d0000d0d00dd00d0d0dd0d000000000000000000000000000000000
00ddd00000d00d000dddddd0000dd0000d0000d00dddddd00d00d0d00d0000d000d00d000dd00dd0d000000d0d0000d000000000000000000000000000000000
000d0000000dd00000000000000dd0000d0000d0000000000dddddd000dddd0000dddd0000dddd00d000000d0dddddd000000000000000000000000000000000
000d000000000000000000000000000000dddd000000000000000000000000000000000000000000dddddddd0000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000de000000d0000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000de000000d0000000d0000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000de000000d0000000d0000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000de000000d0000000d0000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000de000000d0000000d0000000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ddee0000dde000000d000000dde000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00012000000100000001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00012000000100000001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

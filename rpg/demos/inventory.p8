pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- inventory demo
-- by akd

#include ../../lib/shallow_copy.lua
#include ../../lib/round_rectfill.lua
#include ../../lib/get_text_width.lua
#include ../../lib/simple_print_center.lua
#include ../../lib/find.lua
#include ../../lib/join.lua
#include ../../lib/table_to_str.lua
#include ../lib/items.lua
#include ../lib/generate_item.lua

local inventory = {
  rows = 3,
  columns = 6,
  selectedRow = 1,
  selectedColumn = 1,
  cellWidth = 16,
  cellHeight = 16,
  cellPadding = 1,
  items = {},
  init = function(self)
    for row = 1, self.rows do
      for column = 1, self.columns do
        add(self.items, generateItem())
      end
    end
  end,
  update = function(self)
    local dx = tonum(btnp(➡️)) - tonum(btnp(⬅️))
    local dy = tonum(btnp(⬇️)) - tonum(btnp(⬆️))
    self.selectedColumn = mid(1, self.selectedColumn + dx, self.columns)
    self.selectedRow = mid(1, self.selectedRow + dy, self.rows)
  end,
  draw = function(self)
    -- Draw background
    local width = self.cellPadding + self.columns * (self.cellWidth + self.cellPadding)
    local height = self.cellPadding + self.rows * (self.cellHeight + self.cellPadding)
    local outerX = (128 - width) / 2
    local outerY = 0
    roundRectfill(outerX, outerY, outerX + width - 1, outerY + height - 1, 2)

    -- Draw item backgrounds and tiers
    for column = 1, self.columns do
      for row = 1, self.rows do
        local item = self.items[(row - 1) * self.columns + column]
        local tier = getTier(item)

        -- Draw item background
        local x = outerX + self.cellPadding + (column - 1) * (self.cellWidth + self.cellPadding)
        local y = outerY + self.cellPadding + (row - 1) * (self.cellHeight + self.cellPadding)
        roundRectfill(x, y, x + self.cellWidth - 1, y + self.cellHeight - 1, tier)
        local selected = self.selectedRow == row and self.selectedColumn == column
        if selected then
          rect(x, y, x + self.cellWidth - 1, y + self.cellHeight - 1, 7)
        end

        -- Draw item sprite
        local spriteId = findi(item_types, item.equipment_type) - 1
        local spriteX, spriteY = x + 1, y + 1
        spr(spriteId, spriteX, spriteY)

        -- Draw item tier
        local tier = getTier(item)
        print(tier, spriteX + 1, spriteY + 9, 15)
      end
    end

    -- Draw selected item
    local selectedItem = self.items[(self.selectedRow - 1) * self.columns + self.selectedColumn]
    local labelY = outerY + height + 2
    drawItem(selectedItem, outerX, labelY)
  end
}

function _init()
  inventory:init()
end

function _update60()
  inventory:update()
end

function _draw()
  cls()
  inventory:draw()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06660606066606060606066600066000006660000006060000060000066606660606066606660666000000000000000000000000000000000000000000000000
06660606060606060606060000060600006060000006060000060000060006000606060606000060000000000000000000000000000000000000000000000000
06060666060606660666066000060600006600000006060000060000066606600666066606660060000000000000000000000000000000000000000000000000
06060606060606060606060000060600006060000006660000060000060006000606060606000060000000000000000000000000000000000000000000000000
06060606066606060606066600060600006660000006660000066600060006660606060606000666000000000000000000000000000000000000000000000000

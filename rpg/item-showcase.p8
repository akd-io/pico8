pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Item showcase
-- by akd

#include ../lib/shallow_copy.lua
#include ../lib/round_rectfill.lua
#include ../lib/get_text_width.lua
#include lib/equipment.lua

function generateItem()
  local equipment_type = rnd(equipment_types)

  local availableAffixesBag = shallow_copy(affix_type_keys)
  local numAffixes = ceil(rnd(max_affixes_per_item))
  local affixes = {}
  for i = 1, numAffixes do
    local affix_type = rnd(availableAffixesBag)
    local tier = rnd(affix_tiers)
    affixes[affix_type] = tier
    del(availableAffixesBag, affix_type)
  end
  return {
    equipment_type = equipment_type,
    affixes = affixes
  }
end

local currentItem = generateItem()

function _update60()
  if btn(❎) or btn(🅾️) then
    currentItem = generateItem()
  end
end

function _draw()
  cls()
  drawItemLabel(currentItem, 1, 1)
  drawRawItemStats(currentItem, 3, 12)
end

function drawItemLabel(item, x, y)
  local tier = 0
  for key, val in pairs(item.affixes) do
    tier = tier + val
  end

  local text = "t" .. tier .. " " .. item.equipment_type

  local textWidth = getTextWidth(text)
  local textHeight = 5

  local padding = 2
  roundRectfill(x, y, x + padding + textWidth + padding - 1, y + padding + textHeight + padding - 1, 5)
  print(text, x + 2, y + 2, 6)
end

function drawItemTooltip(item, x, y)
  local tier = 0
  for key, val in pairs(item.affixes) do
    tier = tier + val
  end
  print("t" .. tier .. " " .. item.equipment_type, x, y)
  y += 7
  for affix_type, affix_tier in pairs(item.affixes) do
    local affix_data = affix_types[affix_type]
    local affix_value = affix_data.value(affix_tier)
    print("t" .. affix_tier .. " " .. affix_data.str(affix_tier, affix_value), x, y)
    y += 7
  end
end

function drawRawItemStats(item, x, y)
  local tier = 0
  for key, val in pairs(item.affixes) do
    tier = tier + val
  end
  for affix_type, affix_tier in pairs(item.affixes) do
    local affix_data = affix_types[affix_type]
    local affix_value = affix_data.value(affix_tier)
    print("t" .. affix_tier .. " " .. affix_data.str(affix_tier, affix_value), x, y)
    y += 7
  end
end

__gfx__
00000000080800000000700000007000000070000000700000007000000700006777600000000000000000000000000000000000000000000000000000000000
00000000888880000007000000070000000700000007000000070000067660007ccc700000000000000000000000000000000000000000000000000000000000
0000000088888000f0700000f0700000f0700000f0700000f0700000007000007ccc700000000000000000000000000000000000000000000000000000000000
00000000088800000f0000000f0000000f0000000f0000000f0000007776000007c7000000000000000000000000000000000000000000000000000000000000
0000000000800000f0f00000f0f00000f0f00000f0f00000f0f00000000700000070000000000000000000000000000000000000000000000000000000000000

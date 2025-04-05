--[[
Affix ideas:
- attributes
  - strength
  - dexterity
  - intelligence
- Mana
- Rage
- Defence
  - health
  - health regen
  - longer invincibility frames
  - deterministic damage mitigation
    - armor
    - less damage taken
  - chance-based damage mitigation
    - evasion
    - block
    - dodge
- Offense
  - attack speed
  - reduced cooldowns
  - Critical hits
    - crit chance
    - crit damage
  - multicast (cast again immediately afterwards)
  - multiple projectiles (cast multiple spells at once)
  - slow
    - frost damage
  - DoT
    - fire/ignite damage
  - AoE
    - lightning damage
    - size of attacks/spells
  - knockback
- Utility
  - movement speed
]]

local itemTypes = { "main-hand", "off-hand", "head", "neck", "body", "waist", "legs", "feet", "hands", "finger" }
local affixTiers = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }
local affixTypeKeys = {
  "health",
  "flatDamage",
  "percentDamage",
  "attackSpeed",
  "criticalChance",
  "criticalDamage",
  "movementSpeed",
  "dodgeChance",
  "stat9",
  "stat10",
  "stat11",
  "stat12",
  "stat13",
  "stat14",
  "stat15",
  "stat16"
}
local numAffixTypes = #affixTypeKeys
local maxAffixesPerItem = 6
local affixTypes = {
  health = {
    shortName = function(tier) return "t" .. tier .. " hp" end,
    value = function(tier) return 5 * tier end,
    str = function(tier, value) return "+" .. value .. " hp" end,
    longStr = function(tier, value) return "+" .. value .. " health points" end
  },
  flatDamage = {
    shortName = function(tier) return "t" .. tier .. " fd" end,
    value = function(tier) return 3 * tier end,
    str = function(tier, value) return "+" .. value .. " dmg" end,
    longStr = function(tier, value) return "+" .. value .. " damage" end
  },
  percentDamage = {
    shortName = function(tier) return "t" .. tier .. " pd" end,
    value = function(tier) return 3 * tier end,
    str = function(tier, value) return "+" .. value .. "% dmg" end,
    longStr = function(tier, value) return "+" .. value .. "% damage" end
  },
  attackSpeed = {
    shortName = function(tier) return "t" .. tier .. " as" end,
    value = function(tier) return 1 * tier end,
    str = function(tier, value) return "+" .. value .. "% att. sp." end,
    longStr = function(tier, value) return "+" .. value .. "% attack speed" end
  },
  criticalChance = {
    shortName = function(tier) return "t" .. tier .. " cc" end,
    value = function(tier) return 1 * tier end,
    str = function(tier, value) return "+" .. value .. "% crit ch." end,
    longStr = function(tier, value) return "+" .. value .. "% critical chance" end
  },
  criticalDamage = {
    shortName = function(tier) return "t" .. tier .. " cd" end,
    value = function(tier) return 3 * tier end,
    str = function(tier, value) return "+" .. value .. "% crit dmg" end,
    longStr = function(tier, value) return "+" .. value .. "% critical damage" end
  },
  movementSpeed = {
    shortName = function(tier) return "t" .. tier .. " ms" end,
    value = function(tier) return 2 * tier end,
    str = function(tier, value) return "+" .. value .. "% move sp." end,
    longStr = function(tier, value) return "+" .. value .. "% movement speed" end
  },
  dodgeChance = {
    shortName = function(tier) return "t" .. tier .. " dc" end,
    value = function(tier) return ceil(0.5 * tier) end,
    str = function(tier, value) return "+" .. value .. "% dodge ch." end,
    longStr = function(tier, value) return "+" .. value .. "% dodge chance" end
  },
  stat9 = {
    shortName = function(tier) return "t" .. tier .. " stat9" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat9" end,
    longStr = function(tier, value) return "+" .. value .. " stat9" end
  },
  stat10 = {
    shortName = function(tier) return "t" .. tier .. " stat10" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat10" end,
    longStr = function(tier, value) return "+" .. value .. " stat10" end
  },
  stat11 = {
    shortName = function(tier) return "t" .. tier .. " stat11" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat11" end,
    longStr = function(tier, value) return "+" .. value .. " stat11" end
  },
  stat12 = {
    shortName = function(tier) return "t" .. tier .. " stat12" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat12" end,
    longStr = function(tier, value) return "+" .. value .. " stat12" end
  },
  stat13 = {
    shortName = function(tier) return "t" .. tier .. " stat13" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat13" end,
    longStr = function(tier, value) return "+" .. value .. " stat13" end
  },
  stat14 = {
    shortName = function(tier) return "t" .. tier .. " stat14" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat14" end,
    longStr = function(tier, value) return "+" .. value .. " stat14" end
  },
  stat15 = {
    shortName = function(tier) return "t" .. tier .. " stat15" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat15" end,
    longStr = function(tier, value) return "+" .. value .. " stat15" end
  },
  stat16 = {
    shortName = function(tier) return "t" .. tier .. " stat16" end,
    value = function(tier) return tier end,
    str = function(tier, value) return "+" .. value .. " stat16" end,
    longStr = function(tier, value) return "+" .. value .. " stat16" end
  }
}

function getTier(item)
  local tier = 0
  for key, val in pairs(item.affixes) do
    tier += val
  end
  return tier
end

function drawItem(item, x, y)
  drawItemLabel(item, x, y)
  drawItemStats(item, x + 2, y + 11)
end

function drawItemLabel(item, x, y)
  local text = "t" .. getTier(item) .. " " .. item.equipmentType

  local textWidth = getTextWidth(text)
  local textHeight = 5

  local padding = 2
  roundRectfill(x, y, x + padding + textWidth + padding - 1, y + padding + textHeight + padding - 1, 5)
  print(text, x + 2, y + 2, 6)
end

function drawItemStats(item, x, y)
  for affixType, affixTier in pairs(item.affixes) do
    local affixData = affixTypes[affixType]
    local affixValue = affixData.value(affixTier)
    print("t" .. affixTier .. " " .. affixData.str(affixTier, affixValue), x, y)
    y += 7
  end
end
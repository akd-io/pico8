pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- React pairs() order test
-- by akd
-- This cart was made to test if replacing react's renderElements loop's ipairs() with pairs() to allow nil values in element arrays would break anything.
-- I have not been able to break anything here.
-- But the results of other pairs-*.p8 points to the conclusion that pairs() is not a good idea.
-- So I'm sticking with ipairs().
-- TODO: Try using extractIndicesUsingPairs and extractIndicesUsingFor from pairs-array-stress-test.p8 to see if that makes a difference.

#include ../lib/react.lua
#include ../lib/table-methods.lua
#include ../lib/range.lua

local function pairsValues(table)
  local result = {}
  for _, v in pairs(table) do
    --printh("i: " .. tostr(i) .. " v: " .. tostr(v))
    add(result, v)
  end
  return result
end

-- TODO: Consider using arrayToString from table-methods.lua instead.
local function arrayToString(array)
  local result = ""
  for v in all(array) do
    result ..= tostr(v) .. " "
  end
  return result
end

local function Circfill(x1, y1, r, color)
  circfill(x1, y1, r, color)
end

local function Game()
  local num = 50
  local elementArray = arrayMap(
    range(num), function(v)
      local key = v
      local x1 = 64 + 48 * cos(v / num)
      local y1 = 64 + 48 * sin(v / num)
      local r = 6
      --printh(v * 2 .. " " .. v * 2 .. " " .. v * 2 + 10 .. " " .. v * 2 + 10 .. " " .. v % 16)
      return { key, Circfill, x1, y1, r, v % 15 + 1 }
    end
  )
  local nilledIndices = {}
  for i = 1, 20 do
    local rndi = flr(rnd(num))
    elementArray[rndi] = nil
    add(nilledIndices, rndi)
  end
  printh("Nilled indices: " .. arrayToString(nilledIndices))

  local expectedValues = {}
  for i = 1, num do
    if elementArray[i] != nil then
      add(expectedValues, elementArray[i])
    end
  end

  -- Unreliable with tables.
  printh("elementArray length: " .. #elementArray .. " count(elementArray): " .. count(elementArray))
  -- Unreliable with tables.
  printh("Nils: " .. count(elementArray, nil))

  local pairOrder = pairsValues(elementArray)
  assert(#pairOrder == #expectedValues, "pairOrder length: " .. #pairOrder .. " expectedValues length: " .. #expectedValues)
  for i = 1, #pairOrder do
    assert(pairOrder[i] == expectedValues[i], "pairOrder[" .. i .. "] = " .. tostr(pairOrder[i]) .. " expectedValues[" .. i .. "] = " .. tostr(expectedValues[i]))
  end

  cls()

  return {
    { Circfill, 10, 10, 6, 1 },
    elementArray,
    { Circfill, 117, 117, 6, 1 }
  }
end

local function _update60() end
local function _draw()
  renderRoot(Game)
end

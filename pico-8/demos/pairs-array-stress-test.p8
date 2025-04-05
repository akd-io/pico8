pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- pairs array stress test
-- by akd

local values = { 1, 2, 3, "a", "b", "c", nil, false, true, {}, function() end }

local arrayLength = 20

function generateArray(length)
  local result = {}
  for i = 1, length do
    result[i] = rnd(values)
  end
  return result
end

function extractIndicesUsingPairs(table)
  local result = {}
  for i, v in pairs(table) do
    --printh("i: " .. tostr(i) .. " v: " .. tostr(v))
    add(result, i)
  end
  return result
end

function extractIndicesUsingFor(table)
  local result = {}
  for i = 1, arrayLength do
    --printh("i: " .. tostr(i) .. " v: " .. tostr(v))
    -- TODO: Is this correct? extractIndicesUsingPairs doesn't check for nil values.
    -- TODO: Can adding nil have side effects? Test.
    if (table[i] ~= nil) then
      add(result, i)
    end
  end
  return result
end

function arrayToStringUsingIpairs(array)
  local result = ""
  for i, v in ipairs(array) do
    result ..= tostr(v) .. " "
  end
  return result
end

function arrayToStringUsingFor(array)
  local result = ""
  for i = 1, arrayLength do
    result ..= tostr(array[i]) .. " "
  end
  return result
end

function compareArraysUsingIpairs(array1, array2)
  for i, v in ipairs(array1) do
    if (v ~= array2[i]) then
      return false
    end
  end
  return true
end

local minFailingArrayLength = arrayLength
local maxFailingArrayLength = 0
local failingArrays = {}
local numTests = 1000
for testi = 1, 1000 do
  local array = generateArray(arrayLength)
  --printh("array: " .. arrayToStringUsingFor(array))
  local pairsIndices = extractIndicesUsingPairs(array)
  --printh("pairs: " .. arrayToStringUsingIpairs(pairsIndices))
  local forIndices = extractIndicesUsingFor(array)
  --printh("for:   " .. arrayToStringUsingIpairs(forIndices))
  if not compareArraysUsingIpairs(pairsIndices, forIndices) then
    failingArrays[#failingArrays + 1] = array
    if #pairsIndices < minFailingArrayLength then
      minFailingArrayLength = #pairsIndices
    end
    if #pairsIndices > maxFailingArrayLength then
      maxFailingArrayLength = #pairsIndices
    end
  end
end

printh("")

-- printh("Failing arrays (" .. #failingArrays .. "):")
-- for i, array in ipairs(failingArrays) do
--   printh("array: " .. arrayToStringUsingFor(array))
--   local pairsIndices = extractIndicesUsingPairs(array)
--   printh("pairs: " .. arrayToStringUsingIpairs(pairsIndices))
--   local forIndices = extractIndicesUsingFor(array)
--   printh("for:   " .. arrayToStringUsingIpairs(forIndices))
-- end
printh("Total failing arrays: " .. #failingArrays .. "/" .. numTests .. " (" .. (#failingArrays / numTests * 100) .. "%)")
printh("Min failing array length: " .. minFailingArrayLength)
printh("Max failing array length: " .. maxFailingArrayLength)

-- local array = { 1, 2, 3, nil, nil, nil, 4, 5, 6, nil, nil, nil, "a", "b", "c", nil, nil, nil, 7, 8 }
-- printh("array: " .. arrayToStringUsingFor(array))
-- local pairsIndices = extractIndicesUsingPairs(array)
-- printh("pairs: " .. arrayToStringUsingIpairs(pairsIndices))
-- local forIndices = extractIndicesUsingFor(array)
-- printh("for:   " .. arrayToStringUsingIpairs(forIndices))

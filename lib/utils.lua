-- TODO: Consider using iterator patterns instead for some of these? For example, why isn't range() an iterator?

local function range(n)
  local result = {}
  for i = 1, n do
    add(result, i)
  end
  return result
end

local function shallowCopy(sourceTable)
  local destTable = {}
  for k, v in pairs(sourceTable) do
    destTable[k] = v
  end
  return destTable
end

-- sortedArray by Werxyz from https://discord.com/channels/215267007245975552/1168158710372241498/1168158710372241498
local function sortedArray(array)
  local sorted = {}
  for d in all(array) do
    local i = 1
    while (sorted[i] and sorted[i] < d) do
      i += 1
    end
    add(sorted, d, i)
  end
  return sorted
end

-- pad() takes a positive integer, a length, and optionally a symbol.
-- It converts the integer to a string, and pads it with the specified symbol or 0s to match the specified length.
local function pad(num, length, symbol)
  local length = length or 2
  local symbol = symbol or "0"
  local str = tostr(num)
  while #str < length do
    str = symbol .. str
  end
  return str
end

local function endsWidth(str, suffix)
  return sub(str, -#suffix) == suffix
end

local function isArray(table)
  if (type(table) != "table") then return false end
  local i = 1
  for _ in pairs(table) do
    if table[i] == nil then return false end
    i += 1
  end
  return true
end

local function join(elements, separator)
  separator = separator or ", "
  local result = ""
  for k, v in ipairs(elements) do
    if (k > 1) then result ..= separator end
    result ..= tostr(v)
  end
  return result
end

local function arrayToString(array)
  return "{ " .. join(array) .. " }"
end

local function objectToString(object, indent)
  depth = depth or 0

  local function getIndent(d)
    local spaces = ""
    for i = 1, d * 2 do
      spaces = spaces .. " "
    end
    return spaces
  end

  local indent = getIndent(depth)
  local strings = {}

  add(strings, "{")
  local first = true

  for key, value in pairs(object) do
    if not first then
      add(strings, ",")
    end
    first = false

    add(strings, "\n" .. indent .. "  " .. key .. ": ")

    if type(value) == "table" then
      add(strings, objectToString(value, depth + 1))
    else
      add(strings, tostr(value))
    end
  end

  if #strings > 1 then
    add(strings, "\n" .. indent)
  end
  add(strings, "}")

  return join(strings, "")
end

local function map(table, callback, iterator)
  local newTable = {}
  for i, v in iterator(table) do
    newTable[i] = callback(v, i)
  end
  return newTable
end
local function arrayMap(array, callback)
  return map(array, callback, ipairs)
end
local function objectMap(object, callback)
  return map(object, callback, pairs)
end

local function filter(table, callback, iterator)
  local newTable = {}
  for i, v in iterator(table) do
    if callback(v, i) then
      table.insert(newTable, v)
    end
  end
  return newTable
end
local function arrayFilter(array, callback)
  return filter(array, callback, ipairs)
end
local function objectFilter(object, callback)
  return filter(object, callback, pairs)
end

local function __reduce(table, callback, initialValue, iterator)
  local accumulator = initialValue
  for i, v in iterator(table) do
    accumulator = callback(accumulator, v, i)
  end
  return accumulator
end
local function arrayReduce(array, callback, initialValue)
  return __reduce(array, callback, initialValue, ipairs)
end

local function objectReduce(object, callback, initialValue)
  return __reduce(object, callback, initialValue, pairs)
end

local function __find(table, callback, iterator)
  for i, v in iterator(table) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil
end
local function arrayFind(array, callback)
  return __find(array, callback, ipairs)
end
local function objectFind(object, callback)
  return __find(object, callback, pairs)
end

local function __findIndex(table, callback, iterator)
  for i, v in iterator(table) do
    if callback(v, i) then
      return i
    end
  end
  return nil
end
local function arrayFindIndex(array, callback)
  return __findIndex(array, callback, ipairs)
end
local function objectFindIndex(object, callback)
  return __findIndex(object, callback, pairs)
end

local function __every(table, callback, iterator)
  for i, v in iterator(table) do
    if not callback(v, i) then
      return false
    end
  end
  return true
end
local function arrayEvery(array, callback)
  return __every(array, callback, ipairs)
end
local function objectEvery(object, callback)
  return __every(object, callback, pairs)
end

local function __some(table, callback, iterator)
  for i, v in iterator(table) do
    if callback(v, i) then
      return true
    end
  end
  return false
end
local function arraySome(array, callback)
  return __some(array, callback, ipairs)
end
local function objectSome(object, callback)
  return __some(object, callback, pairs)
end

local function __includes(table, value, iterator)
  for i, v in iterator(table) do
    if v == value then
      return true
    end
  end
  return false
end
local function arrayIncludes(array, value)
  return __includes(array, value, ipairs)
end
local function objectIncludes(object, value)
  return __includes(object, value, pairs)
end

local function __indexOf(table, value, iterator)
  for i, v in iterator(table) do
    if v == value then
      return i
    end
  end
  return -1
end
local function arrayIndexOf(array, value)
  return __indexOf(array, value, ipairs)
end
local function objectIndexOf(object, value)
  return __indexOf(object, value, pairs)
end

local function arrayLastIndexOf(array, value)
  for i = #array, 1, -1 do
    if array[i] == value then
      return i
    end
  end
  return -1
end

local function __keys(table, iterator)
  local keys = {}
  for k, _ in iterator(table) do
    table.insert(keys, k)
  end
  return keys
end
local function arrayKeys(array)
  return __keys(array, ipairs)
end
local function objectKeys(object)
  return __keys(object, pairs)
end

local function __values(table, iterator)
  local values = {}
  for _, v in iterator(table) do
    table.insert(values, v)
  end
  return values
end
local function arrayValues(array)
  return __values(array, ipairs)
end
local function objectValues(object)
  return __values(object, pairs)
end

local function __entries(table, iterator)
  local entries = {}
  for k, v in iterator(table) do
    table.insert(entries, { k, v })
  end
  return entries
end
local function arrayEntries(array)
  return __entries(array, ipairs)
end
local function objectEntries(object)
  return __entries(object, pairs)
end

local function arrayFrom(iterator)
  assert(false, "arrayFrom is not implemented")
  -- TODO: Find out how to use iterators in lua. https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from
end

local function arraySlice(array, start, end_)
  assert(false, "Use sub() instead.")
end

local function arraySplice(array, start, deleteCount, ...)
  local removed = {}
  for i = start, start + deleteCount - 1 do
    array.insert(removed, array[i])
    array[i] = nil
  end
  for i = start, start + select("#", ...) - 1 do
    array[i] = select(i - start + 1, ...)
  end
  for i = start + select("#", ...), #array do
    array[i - select("#", ...)] = array[i]
    array[i] = nil
  end
  return removed
end

local function arrayPush(array, ...)
  for i = 1, select("#", ...) do
    array[#array + 1] = select(i, ...)
  end
  return #array
end

local function arrayPop(array)
  local value = array[#array]
  array[#array] = nil
  return value
end

local function arrayUnshift(array, ...)
  for i = select("#", ...), 1, -1 do
    array[#array + 1] = array[i]
    array[i] = select(i, ...)
  end
  return #array
end

local function arrayShift(array)
  local value = array[1]
  for i = 1, #array - 1 do
    array[i] = array[i + 1]
  end
  array[#array] = nil
  return value
end
function map(table, callback, iterator)
  local newTable = {}
  for i, v in iterator(table) do
    newTable[i] = callback(v, i)
  end
  return newTable
end
function arrayMap(array, callback)
  return map(array, callback, ipairs)
end
function objectMap(object, callback)
  return map(object, callback, pairs)
end

function filter(table, callback, iterator)
  local newTable = {}
  for i, v in iterator(table) do
    if callback(v, i) then
      table.insert(newTable, v)
    end
  end
  return newTable
end
function arrayFilter(array, callback)
  return filter(array, callback, ipairs)
end
function objectFilter(object, callback)
  return filter(object, callback, pairs)
end

function __reduce(table, callback, initialValue, iterator)
  local accumulator = initialValue
  for i, v in iterator(table) do
    accumulator = callback(accumulator, v, i)
  end
  return accumulator
end
function arrayReduce(array, callback, initialValue)
  return __reduce(array, callback, initialValue, ipairs)
end

function objectReduce(object, callback, initialValue)
  return __reduce(object, callback, initialValue, pairs)
end

function find(table, callback, iterator)
  for i, v in iterator(table) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil
end
function arrayFind(array, callback)
  return find(array, callback, ipairs)
end
function objectFind(object, callback)
  return find(object, callback, pairs)
end

function __findIndex(table, callback, iterator)
  for i, v in iterator(table) do
    if callback(v, i) then
      return i
    end
  end
  return nil
end
function arrayFindIndex(array, callback)
  return __findIndex(array, callback, ipairs)
end
function objectFindIndex(object, callback)
  return __findIndex(object, callback, pairs)
end

function __every(table, callback, iterator)
  for i, v in iterator(table) do
    if not callback(v, i) then
      return false
    end
  end
  return true
end
function arrayEvery(array, callback)
  return __every(array, callback, ipairs)
end
function objectEvery(object, callback)
  return __every(object, callback, pairs)
end

function __some(table, callback, iterator)
  for i, v in iterator(table) do
    if callback(v, i) then
      return true
    end
  end
  return false
end
function arraySome(array, callback)
  return __some(array, callback, ipairs)
end
function objectSome(object, callback)
  return __some(object, callback, pairs)
end

function __includes(table, value, iterator)
  for i, v in iterator(table) do
    if v == value then
      return true
    end
  end
  return false
end
function arrayIncludes(array, value)
  return __includes(array, value, ipairs)
end
function objectIncludes(object, value)
  return __includes(object, value, pairs)
end

function __indexOf(table, value, iterator)
  for i, v in iterator(table) do
    if v == value then
      return i
    end
  end
  return -1
end
function arrayIndexOf(array, value)
  return __indexOf(array, value, ipairs)
end
function objectIndexOf(object, value)
  return __indexOf(object, value, pairs)
end

function arrayLastIndexOf(array, value)
  for i = #array, 1, -1 do
    if array[i] == value then
      return i
    end
  end
  return -1
end

function __keys(table, iterator)
  local keys = {}
  for k, _ in iterator(table) do
    table.insert(keys, k)
  end
  return keys
end
function arrayKeys(array)
  return __keys(array, ipairs)
end
function objectKeys(object)
  return __keys(object, pairs)
end

function __values(table, iterator)
  local values = {}
  for _, v in iterator(table) do
    table.insert(values, v)
  end
  return values
end
function arrayValues(array)
  return __values(array, ipairs)
end
function objectValues(object)
  return __values(object, pairs)
end

function __entries(table, iterator)
  local entries = {}
  for k, v in iterator(table) do
    table.insert(entries, { k, v })
  end
  return entries
end
function arrayEntries(array)
  return __entries(array, ipairs)
end
function objectEntries(object)
  return __entries(object, pairs)
end

function arrayFrom(iterator)
  assert(false, "arrayFrom is not implemented")
  -- TODO: Find out how to use iterators in lua. https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/from
end

-- isArray returns true if the value is a table and all keys are consecutive numbers.
function isArray(value)
  if (type(value) != "table") then
    return false
  end
  local arrayLength = #value
  for k in pairs(value) do
    if (type(k) != "number" or k > arrayLength) then
      return false
    end
  end
  return true
end

function arraySlice(array, start, end_)
  assert(false, "Use sub() instead.")
end

function arraySplice(array, start, deleteCount, ...)
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

function arrayPush(array, ...)
  for i = 1, select("#", ...) do
    array[#array + 1] = select(i, ...)
  end
  return #array
end

function arrayPop(array)
  local value = array[#array]
  array[#array] = nil
  return value
end

function arrayUnshift(array, ...)
  for i = select("#", ...), 1, -1 do
    array[#array + 1] = array[i]
    array[i] = select(i, ...)
  end
  return #array
end

function arrayShift(array)
  local value = array[1]
  for i = 1, #array - 1 do
    array[i] = array[i + 1]
  end
  array[#array] = nil
  return value
end
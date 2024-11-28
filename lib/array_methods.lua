function arrayMap(table, callback)
  local newTable = {}
  for i, v in pairs(table) do
    newTable[i] = callback(v, i)
  end
  return newTable
end

function arrayFilter(table, callback)
  local newTable = {}
  for i, v in pairs(table) do
    if callback(v, i) then
      table.insert(newTable, v)
    end
  end
  return newTable
end

function arrayReduce(table, callback, initialValue)
  local accumulator = initialValue
  for i, v in pairs(table) do
    accumulator = callback(accumulator, v, i)
  end
  return accumulator
end

function arrayFind(table, callback)
  for i, v in pairs(table) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil
end

function arrayFindIndex(table, callback)
  for i, v in pairs(table) do
    if callback(v, i) then
      return i
    end
  end
  return nil
end

function arrayEvery(table, callback)
  for i, v in pairs(table) do
    if not callback(v, i) then
      return false
    end
  end
  return true
end

function arraySome(table, callback)
  for i, v in pairs(table) do
    if callback(v, i) then
      return true
    end
  end
  return false
end

function arrayIncludes(table, value)
  for i, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

function arrayIndexOf(table, value)
  for i, v in pairs(table) do
    if v == value then
      return i
    end
  end
  return -1
end

function arrayLastIndexOf(table, value)
  for i = #table, 1, -1 do
    if table[i] == value then
      return i
    end
  end
  return -1
end

function arrayKeys(table)
  local keys = {}
  for k, _ in pairs(table) do
    table.insert(keys, k)
  end
  return keys
end

function arrayValues(table)
  local values = {}
  for _, v in pairs(table) do
    table.insert(values, v)
  end
  return values
end

function arrayEntries(table)
  local entries = {}
  for k, v in pairs(table) do
    table.insert(entries, { k, v })
  end
  return entries
end

function arrayFrom(table)
  local newTable = {}
  for i, v in pairs(table) do
    newTable[i] = v
  end
  return newTable
end

function arrayIsArray(table)
  return type(table) == "table" and #table > 0 and #table == table.n
end

function arraySlice(table, start, end_)
  local newTable = {}
  for i = start or 1, end_ or #table do
    table.insert(newTable, table[i])
  end
  return newTable
end

function arraySplice(table, start, deleteCount, ...)
  local removed = {}
  for i = start, start + deleteCount - 1 do
    table.insert(removed, table[i])
    table[i] = nil
  end
  for i = start, start + select("#", ...) - 1 do
    table[i] = select(i - start + 1, ...)
  end
  for i = start + select("#", ...), #table do
    table[i - select("#", ...)] = table[i]
    table[i] = nil
  end
  return removed
end

function arrayPush(table, ...)
  for i = 1, select("#", ...) do
    table[#table + 1] = select(i, ...)
  end
  return #table
end

function arrayPop(table)
  local value = table[#table]
  table[#table] = nil
  return value
end

function arrayUnshift(table, ...)
  for i = select("#", ...), 1, -1 do
    table[#table + 1] = table[i]
    table[i] = select(i, ...)
  end
  return #table
end

function arrayShift(table)
  local value = table[1]
  for i = 1, #table - 1 do
    table[i] = table[i + 1]
  end
  table[#table] = nil
  return value
end
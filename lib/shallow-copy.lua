function shallowCopy(sourceTable)
  local destTable = {}
  for k, v in pairs(sourceTable) do
    destTable[k] = v
  end
  return destTable
end
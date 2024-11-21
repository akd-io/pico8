function join(array, separator)
  separator = separator or ","
  local result = ""
  for i, value in pairs(array) do
    if (i > 1) then result ..= separator end
    result ..= tostr(value)
  end
  return result
end
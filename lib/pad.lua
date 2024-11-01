-- pad() takes a positive integer, a length, and optionally a symbol.
-- It converts the integer to a string, and pads it with the specified symbol or 0s to match the specified length.
function pad(num, length, symbol)
  local length = length or 2
  local symbol = symbol or "0"
  local str = tostr(num)
  while #str < length do
    str = symbol .. str
  end
  return str
end
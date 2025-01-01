function tableToStr(tbl, depth)
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

  for key, value in pairs(tbl) do
    if not first then
      add(strings, ",")
    end
    first = false

    add(strings, "\n" .. indent .. "  " .. key .. ": ")

    if type(value) == "table" then
      add(strings, tableToStr(value, depth + 1))
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
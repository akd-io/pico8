function tableToStr(tbl)
  local strings = {}
  for key, value in pairs(tbl) do
    add(strings, key .. ": " .. value)
  end
  return join(strings, " | ")
end
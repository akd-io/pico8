function tableToStr(tbl)
  local strings = {}
  for k, v in pairs(tbl) do
    add(strings, k .. ": " .. v)
  end
  return join(strings, " | ")
end
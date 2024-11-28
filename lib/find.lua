function find(table, arg)
  if (type(arg) == "function") then
    for i, v in pairs(table) do
      if arg(v) then return v end
    end
  else
    for i, v in pairs(table) do
      if v == arg then return v end
    end
  end
end

function findi(table, arg)
  if (type(arg) == "function") then
    for i, v in pairs(table) do
      if arg(v) then return i end
    end
  else
    for i, v in pairs(table) do
      if v == arg then return i end
    end
  end
end
--[[pod_format="raw",created="2025-04-01 10:19:31",modified="2025-04-01 10:19:31",revision=0]]
include("/lib/utils.lua")
include("/lib/describe.lua")

local min_width = 200
local min_height = 100

window({
  width = min_width,
  height = min_height,
  min_width = min_width,
  min_height = min_height,
  resizeable = true,
  moveable = true,
  has_frame = true,
  title = tostr(pid())
})

local processAttributes = { "id", "prog", "pwd", "cpu", "priority", "memory", "name" }

function _init()
  local processes = fetch "/ram/system/processes.pod"
  local firstProcess = processes[1]
  local actualProcessAttributes = objectKeys(firstProcess)
  assert(#processAttributes == #actualProcessAttributes)
  for actualProcessAttribute in all(actualProcessAttributes) do
    assert(arrayIncludes(processAttributes, actualProcessAttribute))
  end
end

function _draw()
  cls(0)
  local processes = fetch "/ram/system/processes.pod"

  local columnWidth = {}
  foreach(processAttributes, function(key)
    local keyWidth = print(key, 0, -1000)
    for process in all(processes) do
      keyWidth = max(keyWidth, print(process[key], 0, -1000))
    end
    columnWidth[key] = keyWidth
  end)

  local x = 0
  local y = 0
  local xPadding = 8
  foreach(processAttributes, function(key)
    print(key, x, y)
    x += columnWidth[key] + xPadding
  end)

  for process in all(processes) do
    x = 0
    y += 8
    for key in all(processAttributes) do
      print(tostr(process[key]), x, y)
      x += columnWidth[key] + xPadding
    end
    -- print(string.format(" %4d %-" .. keyWidth .. "s %0.3f  %0.0fk", process.id, process.name, process.cpu, process.memory / 1024))
  end
end

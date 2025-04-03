--[[pod_format="raw",created="2025-04-01 07:44:58",modified="2025-04-01 07:45:01",revision=1]]

local input = env().argv[1]
local asNumber = tonum(input)
if (asNumber) then
  send_message(2, { event = "kill_process", proc_id = asNumber })
else
  -- Find processes with the name of input
  local processes = fetch "/ram/system/processes.pod"
  for process in all(processes) do
    if (process.name == input) then
      send_message(2, { event = "kill_process", proc_id = process.id })
    end
  end
end

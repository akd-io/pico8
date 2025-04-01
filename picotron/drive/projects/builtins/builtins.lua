--[[pod_format="raw",created="2025-03-30 21:12:50",modified="2025-03-31 00:58:25",revision=31]]

include("/lib/describe.lua")

local defaultDest = "/projects/builtins/builtins.txt"
local dest = env().argv[1]
if (dest == nil) then
  print("No destination specified. Saving to default path: " .. defaultDest)
end

local result = describe(_ENV)
store(dest, result)
print(result)

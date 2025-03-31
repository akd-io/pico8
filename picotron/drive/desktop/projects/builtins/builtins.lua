--[[pod_format="raw",created="2025-03-30 21:12:50",modified="2025-03-31 00:58:25",revision=31]]

include("/lib/describe.lua")

-- TODO: Remove these prinths when it's clear whether create_process in new version of picotron still overrides the whole argv object, including argv[0].
printh("builtins.lua argv:")
printh(describe(env().argv))

local defaultDest = "/desktop/projects/builtins/builtins.txt"
local dest = env().argv[1]
if (dest == nil) then
  print("No destination specified. Saving to default path: " .. defaultDest)
end

local result = describe(_ENV)
store(dest, result)
print(result)

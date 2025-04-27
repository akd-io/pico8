--[[pod_format="raw",created="2025-03-31 15:08:47",modified="2025-03-31 15:08:47",revision=0]]

include("/lib/describe.lua")

local destinationArg = env().argv[1]
assert(destinationArg == nil or type(destinationArg) == "string", "Usage: dump [destination]")

print("Dumping...")

local systemMetadata = fetch_metadata("/system")
local systemVersion = systemMetadata.version

local targetDir = "/dumps/" .. (destinationArg or systemVersion)

-- Dump builtins (_ENV)
rm(targetDir .. "/builtins.txt")
create_process("/projects/builtins/builtins.lua", { argv = { targetDir .. "/builtins.txt" } })

-- Dump env()
rm(targetDir .. "/env.txt")
create_process("/projects/env/env.lua", { argv = { targetDir .. "/env.txt" } })

-- Dump /system
rm(targetDir .. "/system")
cp("/system", targetDir .. "/system")

-- Dump /ram
rm(targetDir .. "/ram")
cp("/ram", targetDir .. "/ram")

-- Dump system metadata
rm(targetDir .. "/system-metadata.txt")
store(targetDir .. "/system-metadata.txt", describe(systemMetadata))

print("Done.")

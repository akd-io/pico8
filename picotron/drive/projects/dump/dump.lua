--[[pod_format="raw",created="2025-03-31 15:08:47",modified="2025-03-31 15:08:47",revision=0]]

include("/lib/describe.lua")

print("Dumping...")

-- TODO: Suppoert version argument

local targetDir = "/dumps/latest"

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
local systemMetadata = fetch_metadata("/system")
store(targetDir .. "/system-metadata.txt", describe(systemMetadata))

print("Done.")

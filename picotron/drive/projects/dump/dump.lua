--[[pod_format="raw",created="2025-03-31 15:08:47",modified="2025-03-31 15:08:47",revision=0]]

include("/lib/describe.lua")

print("Dumping...")

rm("/dumps/builtins.txt")
create_process("/projects/builtins/builtins.lua", { argv = { "/dumps/builtins.txt" } })

rm("/dumps/env.txt")
create_process("/projects/env/env.lua", { argv = { "/dumps/env.txt" } })

rm("/dumps/system")
cp("/system", "/dumps/system")

rm("/dumps/ram")
cp("/ram", "/dumps/ram")

-- Dump version of Picotron
rm("/dumps/version.txt")

local metadata = fetch_metadata("/system")

store("/dumps/version.txt", describe(metadata))

print("Done.")

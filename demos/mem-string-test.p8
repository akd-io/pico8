pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- String Memory Test
-- by akd
-- Test to document the memory usage of strings

--[[
  Output:
  len:1   mem (16:16): 25.2646   mem (i32): 1655744   diff (i32): 0
  len:2   mem (16:16): 25.3301   mem (i32): 1660032   diff (i32): 4288
  len:3   mem (16:16): 25.3311   mem (i32): 1660096   diff (i32): 64
  len:4   mem (16:16): 25.332   mem (i32): 1660160   diff (i32): 64
  len:5   mem (16:16): 25.333   mem (i32): 1660224   diff (i32): 64
  max memory (16:16): 2048 (2^11)
  max memory (i32): 16777216 bytes (2^24)
  max memory (i32): 134217728 bits (2^27)
  max memory (i32)(hex): 0x08000000 bits
]]

printh("")
local str = ""
local prevMem = stat(0)
for i = 1, 5 do
  str ..= "a"
  local mem = stat(0)
  local diff = mem - prevMem
  printh("len:" .. #str .. "   mem (16:16): " .. mem .. "   mem (i32): " .. tostr(mem, 0x2) .. "   diff (i32): " .. tostr(diff, 0x2))
  prevMem = mem
end

printh("max memory (16:16): " .. 2048 .. " (2^11)")
printh("max memory (i32): " .. tostr(2048 / 8, 0x2) .. " bytes (2^24)")
printh("max memory (i32): " .. tostr(2048, 0x2) .. " bits (2^27)")
printh("max memory (i32)(hex): " .. tostr(2048, 0x3) .. " bits")

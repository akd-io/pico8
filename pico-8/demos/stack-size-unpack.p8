pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- stack size unpack demo
-- by akd

-- This script was made to test if `unpack()` was more optimized than a simple
-- recursive function. Using the stack size estimate we gathered in
-- stack-size.p8, we test to see if `unpack()` can handle unpacking an array
-- bigger than the stack size.
-- And it seems to! It successfully unpacks arrays of size 65536 (0x0000ffff).
-- It does however error out, if we set the limit to 65537 (0x0001.0001).
-- Mouse mentioned this might be a result of the 0x10000 limit on function
-- arguments. But we run out of memory before even getting to the unpack call.

--[[
  Output:
  ...
  65535 (0x0000ffff) - Mem: 1304.1514
  Unpacking...
  Unpacked.
]]
-- Safe limit:
local limit = 0x0001.0001 -- (65537) Success!
-- Unsafe limit:
--local limit = 0x0001.0002 -- (65538) Out of memory error!
local array = {}
-- Stack size is about 42741 (0x0000a6f5) (See stack-size.p8 for details)
for i = 0x0000.0001, limit, 0x0000.0001 do
  array[i] = i
  local mem = stat(0)
  printh(tostr(i, 0b10) .. " (" .. tostr(i, 0b11) .. ") - Mem: " .. mem)
end

printh("Unpacking...")
unpack(array)
printh("Unpacked.")

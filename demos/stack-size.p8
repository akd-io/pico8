pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- stack size demo
-- by akd

-- In Pico-8, the stack is as large as the memory.
-- As the stack grows, the memory usage increases.
-- As such, the stack never overflows, but out of memory errors occur instead.
-- As you can see at the end of the output, the stack size ends up at about
-- 42741 (0x0000a6f5), before the script runs out of memory at 2048.
--[[
  Output:
  ...
  42741 (0x0000a6f5) - Mem: 2047.8379
]]

local stackSize = 0
local function printStackSize()
  stackSize = stackSize + 0x0000.0001
  printh(tostr(stackSize, 0b10) .. " (" .. tostr(stackSize, 0b11) .. ") - Mem: " .. stat(0))
  -- Below, we make sure NOT to `return` the printStackSize() call,
  -- as that would solve the stack overflow problem by tail call optimization.
  -- But you can try temporarily adding the return before `printStackSize()` to experience the performance gain.
  printStackSize()
end
printStackSize()

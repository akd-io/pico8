pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- 32-bit integer demo
-- by akd

function printCalculation(a, opFunc, opSign, b)
  local result = opFunc(a, b)
  printh("0x1: " .. tostr(a, 0x1) .. " " .. opSign .. " " .. tostr(b, 0x1) .. " = " .. tostr(result, 0x1) .. " (0x2: " .. tostr(result, 0x2) .. ")")
  printh("0x3: " .. tostr(a, 0x3) .. "  " .. opSign .. " " .. tostr(b, 0x3) .. "  = " .. tostr(result, 0x3) .. " (0x2: " .. tostr(result, 0x2) .. ")")
end

printh("32-bit integer demo")
printh("")
printh("Numbers in PICO-8 are all 16:16 fixed point. They range from -32768.0 to 32767.99999.")
printh("But we can pretend they are 32-bit, and many of the arithmetic operators will still work.")
printh("And tostr(val,bitfield) allows printing them as signed 32-bit integers via a bitfield in its second parameter.")
printh("")
printh("tostr bitfield:")
printh("           | 16:16 fixed point | 32-bit integer")
printh("Decimal    |               0x0 |            0x2")
printh("Hexdecimal |               0x1 |            0x3")
printh("")
printh("0x0: 16:16 fixed point")
printh("0x1: Hexadecimal 16:16 fixed point")
printh("0x2: 32-bit integer")
printh("0x3: Hexadecimal 32-bit integer")
printh("")
printh("Max values:")
printh("16-bit int        | Input: 0x7fff      | tostr (0x1): " .. tostr(0x7fff, 0x1) .. " | tostr (0x0): " .. tostr(0x7fff))
printh("16:16 fixed point | Input: 0x7fff.ffff | tostr (0x1): " .. tostr(0x7fff.ffff, 0x1) .. " | tostr (0x0): " .. tostr(0x7fff.ffff))
printh("32-bit int        | Input: 0x7fff.ffff | tostr (0x3): " .. tostr(0x7fff.ffff, 0x3) .. "  | tostr (0x2): " .. tostr(0x7fff.ffff, 0x2))
printh("")
printh("Add:")
local plus = function(a, b) return a + b end
printCalculation(0x0000.0001, plus, "+", 0x0000.0002) -- 0x00000003
printh("")
printh("Subtract:")
local minus = function(a, b) return a - b end
printCalculation(0x0000.0003, minus, "-", 0x0000.0001) -- 0x00000002
printh("")
printh("Multiply: (Use 32bit int AND 16:16 fixed point for multiplication)")
local mul = function(a, b) return a * b end
printCalculation(0x0000.0002, mul, "*", 0x0003.0000) -- 0x00000006
printh("")
printh("Divide: (Use 32bit int AND 16:16 fixed point for division)")
local div = function(a, b) return a / b end
printCalculation(0x0000.0008, div, "/", 0x0002.0000) -- 0x00000004
printh("")
printh("Mod:")
local mod = function(a, b) return a % b end
printCalculation(0x0000.0005, mod, "%", 0x0000.0002) -- 0x00000001

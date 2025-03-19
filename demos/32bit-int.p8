pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- 32-bit integer demo
-- by akd

function printCalculation(a, opFunc, opSign, b)
  local result = opFunc(a, b)
  printh("0b01: " .. tostr(a, 0b01) .. " " .. opSign .. " " .. tostr(b, 0b01) .. " = " .. tostr(result, 0b01) .. " (0b10: " .. tostr(result, 0b10) .. ")")
  printh("0b11: " .. tostr(a, 0b11) .. "  " .. opSign .. " " .. tostr(b, 0b11) .. "  = " .. tostr(result, 0b11) .. "  (0b10: " .. tostr(result, 0b10) .. ")")
end

printh("32-bit integer demo")
printh("")
printh("Numbers in PICO-8 are all 16:16 fixed point. They range from -32768.0 to 32767.99999.")
printh("But we can pretend they are i32, and many of the arithmetic operators will still work.")
printh("And tostr(val,bitfield) allows printing them as signed i32 integers via a bitfield in its second parameter.")
printh("")
printh("tostr bitfield:")
printh("Bit         | False | True")
printh("0b01 or 0x1 | Dec   | Hex ")
printh("0b10 or 0x2 | 16:16 | i32 ")
printh("")
printh("    \\ 0b10 | 16:16          | i32         ")
printh("0b01 \\     |                |             ")
printh("-----------|----------------|-------------")
printh("Dec        | 0b00 Dec 16:16 | 0b10 Dec i32")
printh("Hex        | 0b01 Hex 16:16 | 0b11 Hex i32")
printh("")
printh("0b00 or 0x0: Dec 16:16")
printh("0b01 or 0x1: Hex 16:16")
printh("0b10 or 0x2: Dec i32")
printh("0b11 or 0x3: Hex i32")
printh("")
printh("Max values:")
printh("16-bit int        | Input: 0x7fff      | tostr (0b01): " .. tostr(0x7fff, 0b01) .. " | tostr (0b00): " .. tostr(0x7fff))
printh("16:16 fixed point | Input: 0x7fff.ffff | tostr (0b01): " .. tostr(0x7fff.ffff, 0b01) .. " | tostr (0b00): " .. tostr(0x7fff.ffff))
printh("i32 int           | Input: 0x7fff.ffff | tostr (0b11): " .. tostr(0x7fff.ffff, 0b11) .. "  | tostr (0b10): " .. tostr(0x7fff.ffff, 0b10))
printh("")
printh("Add:")
local plus = function(a, b) return a + b end
printCalculation(0x0000.0001, plus, "+", 0x0000.0002) -- 0x00000003
printh("")
printh("Subtract:")
local minus = function(a, b) return a - b end
printCalculation(0x0000.0003, minus, "-", 0x0000.0001) -- 0x00000002
printh("")
printh("Multiply: (Use i32 int AND 16:16 fixed point for multiplication)")
local mul = function(a, b) return a * b end
printCalculation(0x0000.0002, mul, "*", 0x0003.0000) -- 0x00000006
printh("")
printh("Divide: (Use i32 int AND 16:16 fixed point for division)")
local div = function(a, b) return a / b end
printCalculation(0x0000.0008, div, "/", 0x0002.0000) -- 0x00000004
printh("")
printh("Mod:")
local mod = function(a, b) return a % b end
printCalculation(0x0000.0005, mod, "%", 0x0000.0002) -- 0x00000001

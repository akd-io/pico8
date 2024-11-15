pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- 32-bit integer demo
-- by akd

printh("Max values:")
printh("16-bit int        | Input: 0x7fff      | tostr (0x1): " .. tostr(0x7fff, 0x1) .. " | tostr (0x0): " .. tostr(0x7fff))
printh("16:16 fixed point | Input: 0x7fff.ffff | tostr (0x1): " .. tostr(0x7fff.ffff, 0x1) .. " | tostr (0x0): " .. tostr(0x7fff.ffff))
printh("32-bit int        | Input: 0x7fff.ffff | tostr (0x3): " .. tostr(0x7fff.ffff, 0x3) .. "  | tostr (0x2): " .. tostr(0x7fff.ffff, 0x2))

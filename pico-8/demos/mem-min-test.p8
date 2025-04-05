pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Aprox Minimum Memory Test
-- by akd
-- Code is stored in Lua memory, so you need to remove these comments when running the code.
-- Without comments, printh(tostr(stat(0), 0x2)) yields 1522688      stat(0) max is 134217728 bits  1522688 / 134217728 = 0.0113449097
-- Without comments, printh(stat(0))             yields 23.1797      stat(0) max is 2048 KiB        23.1797 / 2048 = 0.0113182129
printh(tostr(stat(0), 0x2))

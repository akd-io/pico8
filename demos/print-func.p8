pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Print func
-- by akd

local function myFunc() end

-- printh("myFunc: " .. myFunc) -- Error: attempt to concatenate global 'myFunc' (a function value)
printh(myFunc) -- [function]
printh(tostr(myFunc)) -- [function]
printh(tostr(myFunc, 0x1)) -- function: 0x30604e8c
printh(tostring(myFunc)) -- function: 0x30604e8c
printh(type(myFunc)) -- function

pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Print func
-- by akd

function myFunc() end

-- printh("myFunc: " .. myFunc) -- Error: attempt to concatenate global 'myFunc' (a function value)
printh(myFunc) -- [function]
printh(tostr(myFunc)) -- [function]
printh(type(myFunc)) -- function

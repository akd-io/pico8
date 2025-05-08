pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- truthy
-- by akd

--[[ Output:
true: true
-1: true
0: true
1: true
1.0: true
1.1: true
"": true
"1": true
"0": true
"true": true
{}: true
cocreate(function() end): true

false: false
nil: false
]]

printh("true: " .. tostr(not not true)) -- true is truthy
printh("-1: " .. tostr(not not -1)) -- 1 is truthy
printh("0: " .. tostr(not not 0)) -- 0 is truthy
printh("1: " .. tostr(not not 1)) -- 1 is truthy
printh("1.0: " .. tostr(not not 1.0)) -- 1.0 is truthy
printh("1.1: " .. tostr(not not 1.1)) -- 1.1 is truthy
printh("\"\": " .. tostr(not not "")) -- "" is truthy
printh("\"1\": " .. tostr(not not "1")) -- "1" is truthy
printh("\"0\": " .. tostr(not not "0")) -- "0" is truthy
printh("\"true\": " .. tostr(not not "true")) -- "true" is truthy
printh("{}: " .. tostr(not not {})) -- "false" is truthy
printh("cocreate(function() end): " .. tostr(not not cocreate(function() end))) -- "false" is truthy
printh("")
printh("false: " .. tostr(not not false)) -- false is falsy
printh("nil: " .. tostr(not not nil)) -- nil is falsy

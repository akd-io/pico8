pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- builtins
-- by akd

#include ../lib/utils.lua

-- TODO: Assert all known builtins are not nil

local functionKeys = {}
local numberKeys = {}
local tableKeys = {}
local otherKeys = {}

for k, v in pairs(_ENV) do
  if type(v) == "function" then
    add(functionKeys, k)
  elseif type(v) == "number" then
    add(numberKeys, k)
  elseif type(v) == "table" then
    add(tableKeys, k)
  else
    add(otherKeys, k)
  end
end

printh("Functions:")
printh(join(sortedArray(functionKeys), ", "))

printh("Numbers:")
for k in all(sortedArray(numberKeys)) do
  printh(k .. ": " .. tostr(_ENV[k]))
end

printh("Tables:")
for k in all(sortedArray(tableKeys)) do
  printh(k .. ": " .. objectToString(_ENV[k]))
end

printh("Others:")
if (#otherKeys == 0) then
  printh("None")
else
  for k in all(sortedArray(otherKeys)) do
    printh(k .. ": " .. type(_ENV[k]))
  end
end

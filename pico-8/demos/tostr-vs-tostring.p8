pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- toStr vs toString

printh("String:")
local myString = "abc"
printh("myString: " .. myString) -- myString: abc
printh(myString) -- abc
printh(type(myString)) -- string
printh(tostr(myString)) -- abc
printh(tostr(myString, 0x1)) -- abc
printh(tostring(myString)) -- abc

printh("")

printh("Number:")
local myNumber = 123
printh("myNumber: " .. myNumber) -- myNumber: 123
printh(myNumber) -- 123
printh(type(myNumber)) -- number
printh(tostr(myNumber)) -- 123
printh(tostr(myNumber, 0x1)) -- 0x007b.0000
printh(tostring(myNumber)) -- 123

printh("")

printh("Function:")
local function myFunc() end
-- printh("myFunc: " .. myFunc) -- attempt to concatenate global 'myFunc' (a function value)
printh(myFunc) -- [function]
printh(type(myFunc)) -- function
printh(tostr(myFunc)) -- [function]
printh(tostr(myFunc, 0x1)) -- function: 0x30604e8c
printh(tostring(myFunc)) -- function: 0x30604e8c

printh("")

printh("Table:")
local myTable = {}
-- printh("myTable: " .. myTable) -- attempt to concatenate local 'myTable' (a table value)
printh(myTable) -- [table]
printh(type(myTable)) -- table
printh(tostr(myTable)) -- [table]
printh(tostr(myTable, 0x1)) -- table: 0x170923ec
printh(tostring(myTable)) -- table: 0x170923ec

printh("")

printh("Metatable with __tostring:")
local myMetaTable = {}
setmetatable(
  myMetaTable, {
    __tostring = function(t) return "abc" end
  }
)
-- printh("myMetaTable: " .. myMetaTable) -- attempt to concatenate local 'myMetaTable' (a table value)
printh(myMetaTable) -- abc
printh(type(myMetaTable)) -- table
printh(tostr(myMetaTable)) -- abc
printh(tostr(myMetaTable, 0x1)) -- abc
printh(tostring(myMetaTable)) -- abc

printh("")

printh("Boolean:")
local myBoolean = true
-- printh("myBoolean: " .. myBoolean) -- attempt to concatenate local 'myBoolean' (a boolean value)
printh(myBoolean) -- true
printh(type(myBoolean)) -- boolean
printh(tostr(myBoolean)) -- true
printh(tostr(myBoolean, 0x1)) -- true
printh(tostring(myBoolean)) -- true

printh("")

printh("Nil:")
local myNil = nil
-- printh("myNil: " .. myNil) -- attempt to concatenate local 'myNil' (a nil value)
printh(myNil) -- [nil]
printh(type(myNil)) -- nil
printh(tostr(myNil)) -- [nil]
printh(tostr(myNil, 0x1)) -- [nil]
printh(tostring(myNil)) -- nil

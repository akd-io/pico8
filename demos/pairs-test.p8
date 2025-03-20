pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- pairs test
-- by akd

local function pairsOrder(table)
  local result = {}
  for _, v in pairs(table) do
    --printh("i: " .. tostr(i) .. " v: " .. tostr(v))
    result[#result + 1] = v
  end
  return result
end

-- TODO: Consider using arrayToString from table-methods.lua instead.
local function arrayToString(array)
  local result = ""
  for v in all(array) do
    result ..= tostr(v) .. " "
  end
  return result
end

local numArray = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }
printh("num declaration: { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 }")
printh("num pairs() 1:   " .. arrayToString(pairsOrder(numArray)))
printh("num pairs() 2:   " .. arrayToString(pairsOrder(numArray)))

local reverseNumArray = { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 }
printh("reverseNum declaration: { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 }")
printh("reverseNum pairs() 1:   " .. arrayToString(pairsOrder(reverseNumArray)))
printh("reverseNum pairs() 2:   " .. arrayToString(pairsOrder(reverseNumArray)))

local lettersArray = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j" }
printh("letters declaration: { a, b, c, d, e, f, g, h, i, j }")
printh("letters pairs() 1:   " .. arrayToString(pairsOrder(lettersArray)))
printh("letters pairs() 2:   " .. arrayToString(pairsOrder(lettersArray)))

local reverseLettersArray = { "j", "i", "h", "g", "f", "e", "d", "c", "b", "a" }
printh("reverseLetters declaration: { j, i, h, g, f, e, d, c, b, a }")
printh("reverseLetters pairs() 1:   " .. arrayToString(pairsOrder(reverseLettersArray)))
printh("reverseLetters pairs() 2:   " .. arrayToString(pairsOrder(reverseLettersArray)))

local mixedArray = { 10, "a", 3, nil, nil, 3, "abc", nil, false, true, "34", 32, 1, 2 }
printh("mixedArray declaration: { 10, a, 3, nil, nil, 3, abc, nil, false, true, 34, 32, 1, 2 }")
printh("mixedArray pairs() 1:   " .. arrayToString(pairsOrder(mixedArray)))
printh("mixedArray pairs() 2:   " .. arrayToString(pairsOrder(mixedArray)))

local letterToNumber = { a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7, h = 8, i = 9, j = 10 }
printh("letterToNumber declaration: { a=1, b=2, c=3, d=4, e=5, f=6, g=7, h=8, i=9, j=10 }")
printh("letterToNumber pairs() 1:   " .. arrayToString(pairsOrder(letterToNumber)))
printh("letterToNumber pairs() 2:   " .. arrayToString(pairsOrder(letterToNumber)))

local reverseLetterToNumber = { j = 10, i = 9, h = 8, g = 7, f = 6, e = 5, d = 4, c = 3, b = 2, a = 1 }
printh("reverseLetterToNumber declaration: { j=10, i=9, h=8, g=7, f=6, e=5, d=4, c=3, b=2, a=1 }")
printh("reverseLetterToNumber pairs() 1:   " .. arrayToString(pairsOrder(reverseLetterToNumber)))
printh("reverseLetterToNumber pairs() 2:   " .. arrayToString(pairsOrder(reverseLetterToNumber)))

local numberToLetter = { [1] = "a", [2] = "b", [3] = "c", [4] = "d", [5] = "e", [6] = "f", [7] = "g", [8] = "h", [9] = "i", [10] = "j" }
printh("numberToLetter declaration: { [1]=a, [2]=b, [3]=c, [4]=d, [5]=e, [6]=f, [7]=g, [8]=h, [9]=i, [10]=j }")
printh("numberToLetter pairs() 1:   " .. arrayToString(pairsOrder(numberToLetter)))
printh("numberToLetter pairs() 2:   " .. arrayToString(pairsOrder(numberToLetter)))

local reverseNumberToLetter = { [10] = "j", [9] = "i", [8] = "h", [7] = "g", [6] = "f", [5] = "e", [4] = "d", [3] = "c", [2] = "b", [1] = "a" }
printh("reverseNumberToLetter declaration: { [10]=j, [9]=i, [8]=h, [7]=g, [6]=f, [5]=e, [4]=d, [3]=c, [2]=b, [1]=a }")
printh("reverseNumberToLetter pairs() 1:   " .. arrayToString(pairsOrder(reverseNumberToLetter)))
printh("reverseNumberToLetter pairs() 2:   " .. arrayToString(pairsOrder(reverseNumberToLetter)))

printh("Nils break #: #{ 1, 2, 3, nil, 5, nil } -> " .. #{ 1, 2, 3, nil, 5, nil })

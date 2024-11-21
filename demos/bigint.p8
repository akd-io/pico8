pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- big integer demo
-- by akd

#include ../lib/bigint.lua

function testAdd(aStr, bStr, expected)
  local actual = bi_tostring(bi_add(bi_new(aStr), bi_new(bStr)))
  local success = actual == expected
  local successStr = success and "SUCCESS" or "FAILURE"
  printh(successStr .. " ADD: a=" .. aStr .. " b=" .. bStr .. " expected=" .. expected .. " actual=" .. actual)
  assert(success)
end

function testMultiply(aStr, bStr, expected)
  local actual = bi_tostring(bi_multiply(bi_new(aStr), bi_new(bStr)))
  local success = actual == expected
  local successStr = success and "SUCCESS" or "FAILURE"
  printh(successStr .. " MULTIPLY: a=" .. aStr .. " b=" .. bStr .. " expected=" .. expected .. " actual=" .. actual)
  assert(success)
end

function testDivide(aStr, bStr, expectedQuotient, expectedRemainder)
  local quotient, remainder = bi_divide(bi_new(aStr), bi_new(bStr))
  local actualQuotient, actualRemainder = bi_tostring(quotient), bi_tostring(remainder)
  local success = actualQuotient == expectedQuotient and actualRemainder == expectedRemainder
  local successStr = success and "SUCCESS" or "FAILURE"
  printh(successStr .. " DIVIDE: a=" .. aStr .. " b=" .. bStr .. " expectedQuotient=" .. expectedQuotient .. " expectedRemainder=" .. expectedRemainder .. " actualQuotient=" .. actualQuotient .. " actualRemainder=" .. actualRemainder)
  assert(success)
end

-- Test the implementation
function _init()
  testAdd("5", "100", "105")
  testAdd("1234", "4321", "5555")
  testAdd("123456789", "987654321", "1111111110")
  testAdd("-5", "100", "95")
  testAdd("-1234", "4321", "3087")
  testAdd("5", "-100", "-95")
  testAdd("1234", "-4321", "-3087")
  testAdd("-5", "-100", "-105")
  testAdd("-1234", "-4321", "-5555")
  testMultiply("5", "100", "500")
  testMultiply("1234", "4321", "5332114")
  testMultiply("123456789", "987654321", "121932631112635269")
  testMultiply("-5", "100", "-500")
  testMultiply("1234", "-4321", "-5332114")
  testMultiply("-5", "-100", "500")
  testMultiply("-1234", "-4321", "5332114")
  testMultiply(
    "3847562389476529837465928376459827364523049857203948523948570923847509823745",
    "5283746598237645982736459872364598272394857029384755928374509827345098723",
    "20329544686903723274743083705476880972770341168444807445475875405973626135762459661431321794505414721093912651978329966088871732326246329019354577635"
  )
  testDivide("123456789", "987654321", "0", "123456789")
  testDivide("987654321", "123456789", "8", "9")
  testDivide(
    "3847562389476529837465928376459827364523049857203948523948570923847509823745",
    "5283746598237645982736459872364598272394857029384755928374509827345098723",
    "728",
    "994865959523562033785589378399822219593939811846208091927769540277953401"
  )
end

pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Temp PRNG seed demo
-- by akd

#include ../lib/with_temp_seed.lua

local debug = true

function getPrngStateString()
  return sub(tostr($0x5f44, 0x3), 3) .. sub(tostr($0x5f48, 0x3), 3)
end

printh("")
printh("withTempSeed() takes a seed and a callback function and calls the callback")
printh("function with the seed set to the given value. Before and after the callback")
printh("function is called, the current PRNG state is saved and restored, so the")
printh("program can continue non-deterministically. Read about the PRNG state in")
printh("memory here: https://pico-8.fandom.com/wiki/Memory#Hardware_state")
printh("")

printh("Initial PRNG state: " .. getPrngStateString())

printh("Example non-deterministic value between 0 and 1 (random between runs): " .. rnd())

printh("PRNG state before callback: " .. getPrngStateString())

withTempSeed(
  0, function()
    printh("Temp PRNG state: " .. getPrngStateString())
    printh("Deterministic value between 0 and 1 (same between runs): " .. rnd())
  end
)

printh("PRNG state (after callback): " .. getPrngStateString())

printh("Example non-deterministic value between 0 and 1 (random between runs): " .. rnd())

printh("PRNG state (finally): " .. getPrngStateString())

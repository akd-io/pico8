pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- peek poke multiple test
-- by akd

-- pico8 -x demos/peek-poke-multiple-test.p8

poke4(0x8000, 0x1234.5678, 0x2345.6789)
a, b = peek4(0x8000, 2)
printh("a: " .. tostr(a, 0b01) .. " b: " .. tostr(b, 0b01))

peekSingle = peek(0x8000)
printh("peekSingle: " .. tostr(peekSingle, 0b01))
peek2Single = peek2(0x8000)
printh("peek2Single: " .. tostr(peek2Single, 0b01))
peek4Single = peek4(0x8000)
printh("peek4Single: " .. tostr(peek4Single, 0b01))

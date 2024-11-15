pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Number edge cases
-- by akd

#include ../lib/pad.lua

function logHexStringStats(hex)
  local val = tonum(hex, 0x3)
  local calcedHex = tostr(val, 0x1)
  printh("Input: " .. hex .. " Decimal: " .. pad(val, 11, " ") .. " Hex: " .. calcedHex)
end

function logDecStringStats(decStr)
  local dec = tonum(decStr)
  local calcedHex = tostr(dec, 0x1)
  printh("Input: " .. pad(decStr, 8, " ") .. " Decimal: " .. pad(dec, 6, " ") .. " Hex: " .. calcedHex)
end

logHexStringStats("7ffffff9") -- Input: 7ffffff9 Decimal:  32767.9999 Hex: 0x7fff.fff9
logHexStringStats("7ffffffa") -- Input: 7ffffffa Decimal:       32768 Hex: 0x7fff.fffa
logHexStringStats("7ffffffb") -- Input: 7ffffffb Decimal:       32768 Hex: 0x7fff.fffb
logHexStringStats("7ffffffc") -- Input: 7ffffffc Decimal:       32768 Hex: 0x7fff.fffc
logHexStringStats("7ffffffd") -- Input: 7ffffffd Decimal:       32768 Hex: 0x7fff.fffd
logHexStringStats("7ffffffe") -- Input: 7ffffffe Decimal:       32768 Hex: 0x7fff.fffe
logHexStringStats("7fffffff") -- Input: 7fffffff Decimal:       32768 Hex: 0x7fff.ffff -- This is rounded to 32768, but is actually around 32767.99999
logHexStringStats("80000000") -- Input: 80000000 Decimal:      -32768 Hex: 0x8000.0000 -- This is actually, correctly, -32768.
logHexStringStats("80000001") -- Input: 80000001 Decimal:      -32768 Hex: 0x8000.0001 -- This is rounded to -32768, but is actually around -32767.99999
logHexStringStats("80000002") -- Input: 80000002 Decimal:      -32768 Hex: 0x8000.0002
logHexStringStats("80000003") -- Input: 80000003 Decimal:      -32768 Hex: 0x8000.0003
logHexStringStats("80000004") -- Input: 80000004 Decimal:      -32768 Hex: 0x8000.0004
logHexStringStats("80000005") -- Input: 80000005 Decimal:      -32768 Hex: 0x8000.0005
logHexStringStats("80000006") -- Input: 80000006 Decimal:      -32768 Hex: 0x8000.0006
logHexStringStats("80000007") -- Input: 80000007 Decimal: -32767.9999 Hex: 0x8000.0007

logHexStringStats("fffffff9") -- Input: fffffff9 Decimal:     -0.0001 Hex: 0xffff.fff9
logHexStringStats("fffffffa") -- Input: fffffffa Decimal:          -0 Hex: 0xffff.fffa
logHexStringStats("fffffffb") -- Input: fffffffb Decimal:          -0 Hex: 0xffff.fffb
logHexStringStats("fffffffc") -- Input: fffffffc Decimal:          -0 Hex: 0xffff.fffc
logHexStringStats("fffffffd") -- Input: fffffffd Decimal:          -0 Hex: 0xffff.fffd
logHexStringStats("fffffffe") -- Input: fffffffe Decimal:          -0 Hex: 0xffff.fffe
logHexStringStats("ffffffff") -- Input: ffffffff Decimal:          -0 Hex: 0xffff.ffff -- This is rounded to -0, but is actually around -0.00001. Also, -0 doesn't exist in two's complement.
logHexStringStats("00000000") -- Input: 00000000 Decimal:           0 Hex: 0x0000.0000 -- This is actually, correctly, 0.
logHexStringStats("00000001") -- Input: 00000001 Decimal:           0 Hex: 0x0000.0001 -- This is rounded to 0, but is actually around 0.00001.
logHexStringStats("00000002") -- Input: 00000002 Decimal:           0 Hex: 0x0000.0002
logHexStringStats("00000003") -- Input: 00000003 Decimal:           0 Hex: 0x0000.0003
logHexStringStats("00000004") -- Input: 00000004 Decimal:           0 Hex: 0x0000.0004
logHexStringStats("00000005") -- Input: 00000005 Decimal:           0 Hex: 0x0000.0005
logHexStringStats("00000006") -- Input: 00000006 Decimal:           0 Hex: 0x0000.0006
logHexStringStats("00000007") -- Input: 00000007 Decimal:      0.0001 Hex: 0x0000.0007

logDecStringStats("-1") --       Input:       -1 Decimal:     -1 Hex: 0xffff.0000
logDecStringStats("-0.1") --     Input:     -0.1 Decimal:   -0.1 Hex: 0xffff.e667
logDecStringStats("-0.01") --    Input:    -0.01 Decimal:  -0.01 Hex: 0xffff.fd71
logDecStringStats("-0.001") --   Input:   -0.001 Decimal: -0.001 Hex: 0xffff.ffbf
logDecStringStats("-0.0001") --  Input:  -0.0001 Decimal:     -0 Hex: 0xffff.fffa
logDecStringStats("-0.00004") -- Input: -0.00004 Decimal:     -0 Hex: 0xffff.fffe
logDecStringStats("-0.00003") -- Input: -0.00003 Decimal:     -0 Hex: 0xffff.ffff
logDecStringStats("-0.00002") -- Input: -0.00002 Decimal:     -0 Hex: 0xffff.ffff
logDecStringStats("-0.00001") -- Input: -0.00001 Decimal:      0 Hex: 0x0000.0000
logDecStringStats("-0") --       Input:       -0 Decimal:      0 Hex: 0x0000.0000 -- Note this line can mislead you there is no -0 in two's complement. So ignore this line if trying to understand the -32768.0 to 32767.99999 number range's skew in values.
logDecStringStats("0") --        Input:        0 Decimal:      0 Hex: 0x0000.0000 -- middle
logDecStringStats("0.00001") --  Input:  0.00001 Decimal:      0 Hex: 0x0000.0000
logDecStringStats("0.00002") --  Input:  0.00002 Decimal:      0 Hex: 0x0000.0001
logDecStringStats("0.00003") --  Input:  0.00003 Decimal:      0 Hex: 0x0000.0001
logDecStringStats("0.00004") --  Input:  0.00004 Decimal:      0 Hex: 0x0000.0002
logDecStringStats("0.0001") --   Input:   0.0001 Decimal:      0 Hex: 0x0000.0006
logDecStringStats("0.001") --    Input:    0.001 Decimal:  0.001 Hex: 0x0000.0041
logDecStringStats("0.01") --     Input:     0.01 Decimal:   0.01 Hex: 0x0000.028f
logDecStringStats("0.1") --      Input:      0.1 Decimal:    0.1 Hex: 0x0000.1999
logDecStringStats("1") --        Input:        1 Decimal:      1 Hex: 0x0001.0000

-- The bitwise not operator ~ can be used `~0` as a shortcut to 0xffff.ffff
printh("Input: " .. pad("~0", 8, " ") .. " Decimal: " .. pad(~0, 6, " ") .. " Hex: " .. tostr(~0, 0x1))

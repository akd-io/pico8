pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Number edge cases
-- by akd

function logHexStringStats(hex)
  local val = tonum(hex, 0x3)
  local calcedHex = tostr(val, 0x1)
  printh("Input: " .. hex .. " Decimal: " .. val .. " Hex: " .. calcedHex)
end

logHexStringStats("7ffffff9") -- Input: 7ffffff9 Decimal: 32767.9999 Hex: 0x7fff.fff9
logHexStringStats("7ffffffa") -- Input: 7ffffffa Decimal: 32768 Hex: 0x7fff.fffa
logHexStringStats("7ffffffb") -- Input: 7ffffffb Decimal: 32768 Hex: 0x7fff.fffb
logHexStringStats("7ffffffc") -- Input: 7ffffffc Decimal: 32768 Hex: 0x7fff.fffc
logHexStringStats("7ffffffd") -- Input: 7ffffffd Decimal: 32768 Hex: 0x7fff.fffd
logHexStringStats("7ffffffe") -- Input: 7ffffffe Decimal: 32768 Hex: 0x7fff.fffe
logHexStringStats("7fffffff") -- Input: 7fffffff Decimal: 32768 Hex: 0x7fff.ffff
logHexStringStats("80000000") -- Input: 80000000 Decimal: -32768 Hex: 0x8000.0000
logHexStringStats("80000001") -- Input: 80000001 Decimal: -32768 Hex: 0x8000.0001
logHexStringStats("80000002") -- Input: 80000002 Decimal: -32768 Hex: 0x8000.0002
logHexStringStats("80000003") -- Input: 80000003 Decimal: -32768 Hex: 0x8000.0003
logHexStringStats("80000004") -- Input: 80000004 Decimal: -32768 Hex: 0x8000.0004
logHexStringStats("80000005") -- Input: 80000005 Decimal: -32768 Hex: 0x8000.0005
logHexStringStats("80000006") -- Input: 80000006 Decimal: -32768 Hex: 0x8000.0006
logHexStringStats("80000007") -- Input: 80000007 Decimal: -32767.9999 Hex: 0x8000.0007

logHexStringStats("fffffff9") -- Input: fffffff9 Decimal: -0.0001 Hex: 0xffff.fff9
logHexStringStats("fffffffa") -- Input: fffffffa Decimal: -0 Hex: 0xffff.fffa
logHexStringStats("fffffffb") -- Input: fffffffb Decimal: -0 Hex: 0xffff.fffb
logHexStringStats("fffffffc") -- Input: fffffffc Decimal: -0 Hex: 0xffff.fffc
logHexStringStats("fffffffd") -- Input: fffffffd Decimal: -0 Hex: 0xffff.fffd
logHexStringStats("fffffffe") -- Input: fffffffe Decimal: -0 Hex: 0xffff.fffe
logHexStringStats("ffffffff") -- Input: ffffffff Decimal: -0 Hex: 0xffff.ffff
logHexStringStats("00000000") -- Input: 00000000 Decimal: 0 Hex: 0x0000.0000
logHexStringStats("00000001") -- Input: 00000001 Decimal: 0 Hex: 0x0000.0001
logHexStringStats("00000002") -- Input: 00000002 Decimal: 0 Hex: 0x0000.0002
logHexStringStats("00000003") -- Input: 00000003 Decimal: 0 Hex: 0x0000.0003
logHexStringStats("00000004") -- Input: 00000004 Decimal: 0 Hex: 0x0000.0004
logHexStringStats("00000005") -- Input: 00000005 Decimal: 0 Hex: 0x0000.0005
logHexStringStats("00000006") -- Input: 00000006 Decimal: 0 Hex: 0x0000.0006
logHexStringStats("00000007") -- Input: 00000007 Decimal: 0.0001 Hex: 0x0000.0007

printh(0x1234.1234)
printh(0x1234.1234 + 0x1234.1234)

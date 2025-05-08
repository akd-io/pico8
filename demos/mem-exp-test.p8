pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Exponential Memory Test
-- by akd

--[[
  Output:
  frame: 1   strLen32:1   #str:1   mem:25.8955   mem (i32):1697088
  frame: 2   strLen32:2   #str:2   mem:25.9141   mem (i32):1698304
  frame: 3   strLen32:4   #str:4   mem:25.916   mem (i32):1698432
  frame: 4   strLen32:8   #str:8   mem:25.9199   mem (i32):1698688
  frame: 5   strLen32:16   #str:16   mem:25.9287   mem (i32):1699264
  frame: 6   strLen32:32   #str:32   mem:25.9443   mem (i32):1700288
  frame: 7   strLen32:64   #str:64   mem:25.9756   mem (i32):1702336
  frame: 8   strLen32:128   #str:128   mem:26.0391   mem (i32):1706496
  frame: 9   strLen32:256   #str:256   mem:26.1641   mem (i32):1714688
  frame: 10   strLen32:512   #str:512   mem:26.4141   mem (i32):1731072
  frame: 11   strLen32:1024   #str:1024   mem:26.915   mem (i32):1763904
  frame: 12   strLen32:2048   #str:2048   mem:27.915   mem (i32):1829440
  frame: 13   strLen32:4096   #str:4096   mem:29.915   mem (i32):1960512
  frame: 14   strLen32:8192   #str:8192   mem:33.915   mem (i32):2222656
  frame: 15   strLen32:16384   #str:16384   mem:41.916   mem (i32):2747008
  frame: 16   strLen32:32768   #str:-32768   mem:57.916   mem (i32):3795584
  frame: 17   strLen32:65536   #str:0   mem:89.916   mem (i32):5892736
  frame: 18   strLen32:131072   #str:0   mem:153.917   mem (i32):10087104
  frame: 19   strLen32:262144   #str:0   mem:281.917   mem (i32):18475712
  frame: 20   strLen32:524288   #str:0   mem:537.917   mem (i32):35252928
  frame: 21   strLen32:1048576   #str:0   mem:1049.918   mem (i32):68807424
]]

printh("")
local str = "a"
-- Track length separately as i32, because #str overflows
local strLen32 = 0x0000.0001
local frame = 1
while true do
  printh("frame: " .. frame .. "   strLen32:" .. tostr(strLen32, 0x2) .. "   #str:" .. #str .. "   mem:" .. stat(0) .. "   mem (i32):" .. tostr(stat(0), 0x2))
  str ..= str
  strLen32 *= 2
  frame += 1
end

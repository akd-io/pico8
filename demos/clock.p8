pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Clock
-- by akd

#include ../lib/utils.lua
#include ../lib/smart-print-center.lua

function _draw()
  cls()
  local h, m, s = stat(93), stat(94), stat(95)
  h, m, s = pad(h), pad(m), pad(s)
  local fontHeight = 10
  smartPrintCenter("\^w\^t" .. h .. ":" .. m .. ":" .. s, 128 / 2 - fontHeight / 2)
end

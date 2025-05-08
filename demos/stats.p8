pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Stats
-- by akd

#include ../lib/utils.lua

function _draw()
  cls()

  if btn(❎) then
    color(7)
  else
    color(6)
  end

  -- TODO: Draw and document undocumented stats, and enable scrolling with up an down buttons.

  print("(0) memory: " .. stat(0))
  print("(1) cpu: " .. stat(1))
  print("(4) clipboard: " .. stat(4))
  print("(6) parameter str: " .. stat(6))
  print("(7) frame rate: " .. stat(7))

  print("(46..49) sfx's " .. stat(46) .. " " .. stat(47) .. " " .. stat(48) .. " " .. stat(49))
  print("(50..53) notes " .. stat(50) .. " " .. stat(51) .. " " .. stat(52) .. " " .. stat(53))
  print("(54) current pattern " .. stat(54))
  print("(55) total patterns " .. stat(55))
  print("(56) ticks " .. stat(56))
  print("(57) playing " .. tostr(stat(57)))

  local year, month, day = pad(stat(80), 4), pad(stat(81)), pad(stat(82))
  print("(80..82) utc date: " .. year .. "-" .. month .. "-" .. day)
  local hour, minute, second = pad(stat(83)), pad(stat(84)), pad(stat(85))
  print("(83..85) utc time: " .. hour .. ":" .. minute .. ":" .. second)
  local year, month, day = pad(stat(90), 4), pad(stat(91)), pad(stat(92))
  print("(90..92) local date: " .. year .. "-" .. month .. "-" .. day)
  local hour, minute, second = pad(stat(93)), pad(stat(94)), pad(stat(95))
  print("(93..95) local time: " .. hour .. ":" .. minute .. ":" .. second)

  print("(100) breadcrumb: " .. tostr(stat(100)))
  print("(110) frame by frame: " .. tostr(stat(110)))
end

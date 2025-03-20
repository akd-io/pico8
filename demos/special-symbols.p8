pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Clock
-- by akd

#include ../lib/smart-print-center.lua

function _draw()
  cls()
  local fontHeight = 5
  smart_print_center("HOLD ❎ TO SEE THE SPECIAL", 64 - fontHeight / 2 - 18)
  smart_print_center("CHARACTERS WRITTEN WHEN HOLDING", 64 - fontHeight / 2 - 12)
  smart_print_center("shift IN THE EDITOR", 64 - fontHeight / 2 - 6)
  smart_print_center(btn(❎) and "…∧░➡️⧗▤⬆️☉🅾️◆" or "\^wqwertyuiop", 64 - fontHeight / 2 + 6)
  smart_print_center(btn(❎) and "█★⬇️✽●♥웃⌂⬅️" or "\^wasdfghjkl", 64 - fontHeight / 2 + 12)
  smart_print_center(btn(❎) and "▥❎🐱ˇ▒♪😐" or "\^wzxcvbnm", 64 - fontHeight / 2 + 18)
end

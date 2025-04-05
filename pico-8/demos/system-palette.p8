pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- System palette
-- by akd

local show_undocuemnted_colors = false

function _init()
  for i = 0, 15 do
    local colorWidth = 128 / 16
    rectfill(i * colorWidth, 0, (i + 1) * colorWidth, 127, i)
  end
end

function _update()
  if btnp(❎) then
    show_undocuemnted_colors = not show_undocuemnted_colors
  end
end

function _draw()
  if show_undocuemnted_colors then
    pal({ -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1 }, 1)
  else
    pal({ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }, 1)
  end
end

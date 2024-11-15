-- smart_print_center() takes a string, an optional y-coordinate, and an optional color as arguments.
-- It prints the string centered on the x-axis at the specified y-coordinate in the specified color.
-- It support all font widths by calculating the width of the text using an off-screen print().
-- y defaults to 0.
-- color defaults to 7 (white).
function smart_print_center(text, y, color)
  local textWidth = print(text, 0, -100) - 1
  local y = y or 0
  local color = color or 7
  print(text, 64 - textWidth / 2, y, color)
end
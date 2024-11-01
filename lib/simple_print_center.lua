-- simple_print_center() takes a string of text, an optional y-coordinate, and an optional color.
-- It assumes each letter takes up 4 pixels; 3 for the letter and 1 for the space.
-- y defaults to 0.
-- color defaults to 7 (white).
function simple_print_center(text, y, color)
  local y = y or 0
  local color = color or 7
  local textWidth = #text * 4 - 1
  print(text, 64 - textWidth / 2, y, color)
end

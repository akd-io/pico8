-- roundRect() takes the same parameters as rect(), and draws a similar
-- rectangle, but without the pixels at the corners to simulate a rounded rectangle.
function roundRect(x0, y0, x1, y1, col, drawInnerCorners)
  line(x0 + 1, y0, x1 - 1, y0, col)
  line(x0 + 1, y1, x1 - 1, y1, col)
  line(x0, y0 + 1, x0, y1 - 1, col)
  line(x1, y0 + 1, x1, y1 - 1, col)
  if drawInnerCorners then
    pset(x0 + 1, y0 + 1, col)
    pset(x0 + 1, y1 - 1, col)
    pset(x1 - 1, y0 + 1, col)
    pset(x1 - 1, y1 - 1, col)
  end
end
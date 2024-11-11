-- roundRectfill() takes the same parameters as rectfill(), and draws a similar
-- rectangle, but without the pixels at the corners to simulate a rounded rectangle.
function roundRectfill( x0, y0, x1, y1, col )
  rectfill(x0+1, y0, x1-1, y1,col)
  rectfill(x0, y0+1, x1, y1-1,col)
end

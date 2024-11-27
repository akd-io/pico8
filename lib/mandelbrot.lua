function mandelbrot(x, y, zoom)
  -- Scale and offset the coordinates
  local cx = (x - 64) / (32 * zoom)
  local cy = (y - 64) / (32 * zoom)

  -- Main cardioid test
  local cx_minus_0_25 = cx - 0.25
  local cy_squared = cy * cy
  local q = cx_minus_0_25 * cx_minus_0_25 + cy_squared
  if q * (q + cx_minus_0_25) <= 0.25 * cy_squared then
    return 0
  end

  -- Period-2 bulb test
  local cx_plus_1 = cx + 1
  if cx_plus_1 * cx_plus_1 + cy_squared <= 0.0625 then
    return 0
  end

  -- Calculate the Mandelbrot value
  local zx, zy = 0, 0
  for i = 1, 25 do
    local zx_squared = zx * zx
    local zy_squared = zy * zy
    if zx_squared + zy_squared > 4 then
      return i
    end
    zy = 2 * zx * zy + cy
    zx = zx_squared - zy_squared + cx
  end
  return 0
end
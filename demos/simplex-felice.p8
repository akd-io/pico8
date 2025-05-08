pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Simplex-Felice demo
-- by akd

-- Felice's Simplex noise function from https://www.lexaloffle.com/bbs/?pid=54336#p
local _os2d_grd = {
  [0] = 5, 2, 2, 5,
  -5, 2, -2, 5,
  5, -2, 2, -5,
  -5, -2, -2, -5
}
function os2dNoiseFunc(seed, width)
  width = width or 256
  assert(
    width >= 1
        and width & width - 1 == 0,
    "width must be a power of 2"
  )
  local mask = width - 1
  local perm = {}
  for i = 0, mask do
    perm[i] = i
  end
  srand(seed)
  for i = mask, 0, -1 do
    local r = flr(rnd(i + 1))
    perm[i], perm[r] = perm[r], perm[i]
  end
  return function(x, y)
    local sto = (x + y) * -0.211324865405187
    local xs = x + sto
    local ys = y + sto
    local xsb = flr(xs)
    local ysb = flr(ys)
    local sqo = (xsb + ysb) * 0.366025403784439
    local xins = xs - xsb
    local yins = ys - ysb
    local insum = xins + yins
    local dx0 = x - xsb - sqo
    local dy0 = y - ysb - sqo
    local dx_ext, dy_ext, xsv_ext, ysv_ext
    local val = 0
    local dx1 = dx0 - 1.366025403784439
    local dy1 = dy0 - 0.366025403784439
    local at1 = 2 - dx1 * dx1 - dy1 * dy1
    if at1 > 0 then
      at1 *= at1
      local i = perm[perm[xsb + 1 & mask] + ysb & mask] & 0x0e
      val += at1 * at1 * (_os2d_grd[i] * dx1 + _os2d_grd[i + 1] * dy1)
    end
    local dx2 = dx0 - 0.366025403784439
    local dy2 = dy0 - 1.366025403784439
    local at2 = 2 - dx2 * dx2 - dy2 * dy2
    if at2 > 0 then
      at2 *= at2
      local i = perm[perm[xsb & mask] + ysb + 1 & mask] & 0x0e
      val += at2 * at2 * (_os2d_grd[i] * dx2 + _os2d_grd[i + 1] * dy2)
    end
    if insum <= 1 then
      local zins = 1 - insum
      if zins > xins or zins > yins then
        if xins > yins then
          xsv_ext = xsb + 1
          ysv_ext = ysb - 1
          dx_ext = dx0 - 1
          dy_ext = dy0 + 1
        else
          xsv_ext = xsb - 1
          ysv_ext = ysb + 1
          dx_ext = dx0 + 1
          dy_ext = dy0 - 1
        end
      else
        xsv_ext = xsb + 1
        ysv_ext = ysb + 1
        dx_ext = 1.73205080756887729
        dy_ext = 1.73205080756887729
      end
    else
      local zins = 2 - insum
      if zins < xins or zins < yins then
        if xins > yins then
          xsv_ext = xsb + 2
          ysv_ext = ysb
          dx_ext = dx0 - 2.73205080756887729
          dy_ext = dy0 - 0.73205080756887729
        else
          xsv_ext = xsb
          ysv_ext = ysb + 2
          dx_ext = dx0 - 0.73205080756887729
          dy_ext = dy0 - 2.73205080756887729
        end
      else
        dx_ext = dx0
        dy_ext = dy0
        xsv_ext = xsb
        ysv_ext = ysb
      end
      xsb += 1
      ysb += 1
      dx0 = dx0 - 1.73205080756887729
      dy0 = dy0 - 1.73205080756887729
    end
    local at0 = 2 - dx0 * dx0 - dy0 * dy0
    if at0 > 0 then
      at0 *= at0
      local i = perm[perm[xsb & mask] + ysb & mask] & 0x0e
      val += at0 * at0 * (_os2d_grd[i] * dx0 + _os2d_grd[i + 1] * dy0)
    end
    local atx = 2 - dx_ext * dx_ext - dy_ext * dy_ext
    if atx > 0 then
      atx *= atx
      local i = perm[perm[xsv_ext & mask] + ysv_ext & mask] & 0x0e
      val += atx * atx * (_os2d_grd[i] * dx_ext + _os2d_grd[i + 1] * dy_ext)
    end
    return val / 47
  end
end

f = 0
function _update60()
  f += 1
end

function makeCachable(val)
  local factor = 1000
  return flr(val * factor) / factor
end

local noiseFunc = os2dNoiseFunc(0, 128)

function _draw()
  cls()
  local tileWidth = 1
  local tilesPerRow = 128 / tileWidth

  local noiseOffset = f / 100
  local noiseScaling = 1 / 100
  for tileX = 0, tilesPerRow - 1 do
    for tileY = 0, tilesPerRow - 1 do
      local x = tileX * tileWidth
      local y = tileY * tileWidth
      local noiseValue = noiseFunc(makeCachable(x * noiseScaling + noiseOffset), makeCachable(y * noiseScaling + noiseOffset))
      local color = 15 * noiseValue
      rectfill(x, y, x + tileWidth - 1, y + tileWidth - 1, color)
    end
  end

  print("Memory: " .. stat(0), 0, 0, 7)
end

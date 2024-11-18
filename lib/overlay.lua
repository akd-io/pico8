-- Fill a rect like the profiling overlay available on the PICO-8 by pressing CTRL+P
function overlay(x, y, w, h)
  -- Draw border
  rect(x, y, x + w - 1, y + h - 1, 0)
  -- Draw inner overlay
  -- Substitute dark colors with 0 and light colors with 1.
  pal({ 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 })

  -- REDRAW SCREEN-BUFFER
  -- Spritesheet remapping address (Where to specify location to find the spritesheet)
  local gfxRemappingAddr = 0X5F54
  -- Screen buffer address. Is actually 0x6000, but the remapping memory takes a 1-byte shorthand (thus 0x60)
  local screenBufferAddr = 0x60
  -- Use screen as spritesheet
  poke(gfxRemappingAddr, screenBufferAddr)
  -- Draw screen buffer
  local xp1, yp1 = x + 1, y + 1
  sspr(xp1, yp1, w - 2, h - 2, xp1, yp1)
  -- Restore screen buffer
  local gfxBufferAddr = 0x00
  poke(gfxRemappingAddr, gfxBufferAddr)

  -- Restore palette
  pal()
end
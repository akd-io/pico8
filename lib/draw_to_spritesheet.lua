function drawToSpritesheet(callback)
  -- Remapping addresses
  local screenRemappingAddr = 0x5f55
  -- Default screen buffer address (0x60 maps to 0x6000)
  local screenBufferAddr = 0x60
  -- Default spritesheet buffer address (0x00 maps to 0x0000)
  local sheetBufferAddr = 0x00

  -- Draw to spritesheet
  poke(screenRemappingAddr, sheetBufferAddr)
  callback()
  -- Restore screen remapping
  poke(screenRemappingAddr, screenBufferAddr)
end
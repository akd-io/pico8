pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- spiderman
-- by akd

#include ../lib/utils.lua
#include ../lib/react.lua

local numLatches = 100
local latches = {}
for i = 1, numLatches do
  latches[i] = rnd(16)
end

printh(arrayToString(latches))

local function Game()
  cls(12)

  local playerState = useState({ x = 60, height = 20, velocityX = 0, velocityY = 0, recordHeight = 64 })
  local x = btn(❎)

  -- Update player position
  -- Calculate x acceleration
  local leftButtonAcceleration = btn(⬅️) and -0.1111 or 0
  local rightButtonAcceleration = btn(➡️) and 0.1111 or 0
  local xAcceleration = leftButtonAcceleration + rightButtonAcceleration
  -- Apply x acceleration
  playerState.velocityX += xAcceleration
  -- Add air resistance
  playerState.velocityX *= 0.9
  -- Cap velocity
  playerState.velocityX = mid(-1, playerState.velocityX, 1)
  -- Apply velocity
  playerState.x += playerState.velocityX

  -- Handle height
  if btnp(⬆️) then
    playerState.velocityY = 1.5
  end
  playerState.velocityY -= 0.05
  playerState.height = playerState.height + playerState.velocityY
  if playerState.height <= 0 then
    playerState.height = 0
    playerState.velocityY = 0
  end
  playerState.recordHeight = max(playerState.recordHeight, playerState.height)

  -- Set camera to world coords
  local cameraY = min(-113, -playerState.height - 64)
  camera(0, cameraY)
  -- Draw player
  spr(1, playerState.x, -playerState.height)
  -- Draw ground
  for i = 0, 15 do
    spr(2, i * 8, 7)
  end

  -- Set camera to screen coords
  camera()
  -- Draw UI
  print("⬆️ max: " .. playerState.recordHeight, 1, 1)
  print("⬆️ cur: " .. playerState.height)
  print("⬆️ vel: " .. playerState.velocityY)
  print("➡️ cur: " .. playerState.x)
  print("➡️ vel: " .. playerState.velocityX)
  print("⬆️ cameraY: " .. cameraY)
end

local function _update60() end
local function _draw()
  renderRoot(Game)
end

__gfx__
00000000091922900b303b0300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555a5249333b333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000024d122513333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009222d11d4444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001da51d444444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e41ddad545d4444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000009141ded94444545400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000009441490454554d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- movement demo
-- by akd

local player = {
  x = 64,
  y = 64,
  movementSpeed = 1,
  update = function(self)
    local dx = tonum(btn(➡️)) - tonum(btn(⬅️))
    local dy = tonum(btn(⬇️)) - tonum(btn(⬆️))
    local mag = max(1, sqrt(dx * dx + dy * dy))
    self.x += self.movementSpeed * dx / mag
    self.y += self.movementSpeed * dy / mag
    -- TODO: Fix cobblestoning
  end,
  draw = function(self)
    circfill(self.x, self.y, 4, 7)
  end
}

function _update60()
  player:update()
end

function _draw()
  cls()
  player:draw()
end

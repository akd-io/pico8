pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- Profiling tests
-- by akd

local f = 1

local options = {
  {
    name = "128 128x1 rectfills",
    func = function()
      -- 60/60 0.04 0.04
      for y = 0, 127 do
        rectfill(0, y, 127, y, y % 16)
      end
    end
  },
  {
    name = "128x128 psets. y % 16",
    func = function()
      -- 30/60 1.2 1.18
      for y = 0, 127 do
        for x = 0, 127 do
          pset(x, y, y % 16)
        end
      end
    end
  },
  {
    name = "128x128 psets. 2",
    func = function()
      -- 30/60 1.08 1.06
      for y = 0, 127 do
        for x = 0, 127 do
          pset(x, y, 2)
        end
      end
    end
  },
  {
    name = "128x128 psets. flr(rnd(16))",
    func = function()
      -- 30/60 2.84 2.79
      for y = 0, 127 do
        for x = 0, 127 do
          pset(x, y, flr(rnd(16)))
        end
      end
    end
  },
  {
    name = "21x31 prints. a",
    func = function()
      -- 60/60 0.54 0.53
      for y = 1, 128 - 6, 6 do
        for x = 2, 128 - 4, 4 do
          print("a", x, y, 1)
        end
      end
    end
  },
  {
    name = "21 31-len prints",
    func = function()
      -- 60/60 0.15 0.15
      local string = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
      for y = 1, 128 - 6, 6 do
        print(string, 2, y, 2)
      end
    end
  },
  {
    name = "128x128 custom chars",
    func = function()
      -- 60/60 0.36 0.35
      for y = 0, 127, 8 do
        for x = 0, 127, 8 do
          print(
            "\^:447cb67c3e7f0106",
            x, y, 3
          )
        end
      end
    end
  },
  {
    name = "128x128 uniform random chars",
    func = function()
      -- 30/60 1.48 1.46
      for y = 0, 127, 8 do
        for x = 0, 127, 8 do
          local hexes = {
            tostr(flr(rnd(0xff)), true),
            tostr(flr(rnd(0xff)), true),
            tostr(flr(rnd(0xff)), true),
            tostr(flr(rnd(0xff)), true),
            tostr(flr(rnd(0xff)), true),
            tostr(flr(rnd(0xff)), true),
            tostr(flr(rnd(0xff)), true),
            tostr(flr(rnd(0xff)), true)
          }
          local string = "\^:"
          for i = 1, #hexes do
            string ..= hexes[i][5] .. hexes[i][6]
          end
          print(string, x, y, 3)
        end
      end
    end
  },
  {
    name = "poke() screen fill. col=0xf",
    func = function()
      -- 2 rnd-calls: 60/60 0.98 0.97
      -- 4 rnd-calls: 60/60 0.94 0.93
      -- 8 rnd-calls: 60/60 0.92 0.90
      -- 16 rnd-calls: 60/60 0.91 0.89
      for i = 0, 0x1fff, 16 do
        poke(
          0x6000 + i,
          0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff,
          0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
        )
      end
    end
  },
  {
    name = "poke4() random screen fill",
    func = function()
      for mem = 0x6000, 0x8000 - 4, 4 do
        poke4(mem, rnd(-1))
      end
    end
  },
  {
    name = "broken poke4() random fill",
    func = function()
      local x = rnd(0xffff)
      for mem = 0x6000, 0x7fff, 4 do
        x = x >> 8
        x = x * (0x100 - x)
        poke4(mem, x)
      end
    end
  },
  {
    name = "broken poke2() gradients?",
    func = function()
      for mem = 0x6000, 0x7fff, 1 do
        local apixeli = 2 * (mem - 0x6000)
        local bpixeli = apixeli + 1
        local a = ((1 + cos(apixeli / 0x2000)) / 2 * f << 8 & 0xf) << 4
        local b = (1 + cos(bpixeli / 0x2000)) / 2 * f << 8 & 0xf
        poke2(mem, a | b)
      end
    end
  },
  {
    name = "poke4() gradient",
    func = function()
      for mem = 0x6000, 0x7fff, 4 do
        local apixeli = mem - 0x6000
        local bpixeli = apixeli + 0.5
        local cpixeli = apixeli + 1
        local dpixeli = apixeli + 1.5
        local epixeli = apixeli + 2
        local fpixeli = apixeli + 2.5
        local gpixeli = apixeli + 3
        local hpixeli = apixeli + 3.5

        local a = ((1 + cos(apixeli / 0x2000 / 2)) / 2 & 0x0000.f000) >> 12
        local b = ((1 + cos(bpixeli / 0x2000 / 2)) / 2 & 0x0000.f000) >> 8
        local c = ((1 + cos(cpixeli / 0x2000 / 2)) / 2 & 0x0000.f000) >> 4
        local d = (1 + cos(dpixeli / 0x2000 / 2)) / 2 & 0x0000.f000
        local e = ((1 + cos(epixeli / 0x2000 / 2)) / 2 & 0x0000.f000) << 4
        local f = ((1 + cos(fpixeli / 0x2000 / 2)) / 2 & 0x0000.f000) << 8
        local g = ((1 + cos(gpixeli / 0x2000 / 2)) / 2 & 0x0000.f000) << 12
        local h = ((1 + cos(hpixeli / 0x2000 / 2)) / 2 & 0x0000.f000) << 16

        local val = a | b | c | d | e | f | g | h
        poke4(mem, val)

        --printh("val: " .. tostr(val, true) .. " - %: " .. apixeli / 0x2000)
      end
    end
  }
}

local optionIndex = 0

function _update60()
  if btnp(❎) then
    optionIndex = (optionIndex + 1) % #options
  elseif btnp(🅾️) then
    optionIndex = (optionIndex - 1) % #options
  end
end

function printLabel(str)
  rectfill(1, 120, 126, 126, 2)
  print(str, 2, 121, 0)
end

function _draw()
  f *= 1.01

  cls()

  local option = options[optionIndex + 1]
  local name = option.name
  option.func()
  printLabel(optionIndex .. ": " .. name)
end

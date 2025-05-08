pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- builtins
-- by akd

--[[ Output:
Functions:
__flip, __trace, __type, _get_menu_item_selected, _map_display, _mark_cpu,
_menuitem, _set_fps, _set_mainloop_exists, _startframe, _update_buttons,
_update_framerate, abs, add, all, assert, atan2, backup, band, bbsreq, bnot,
bor, btn, btnp, bxor, camera, cartdata, cd, ceil, chr, circ, circfill, clip,
cls, cocreate, color, coresume, cos, costatus, count, cstore, cursor, del,
deli, dget, dir, dset, exit, export, extcmd, fget, fillp, flip, flr, folder,
foreach, fset, getmetatable, help, holdframe, import, inext, info,
install_demos, install_games, ipairs, keyconfig, line, load, login, logout, ls,
lshr, map, mapdraw, max, memcpy, memset, menuitem, mget, mid, min, mkdir, mset,
music, next, ord, oval, ovalfill, pack, pairs, pal, palt, peek, peek2, peek4,
pget, poke, poke2, poke4, print, printh, pset, radio, rawequal, rawget, rawlen,
rawset, reboot, rect, rectfill, reload, reset, rnd, rotl, rotr, run, save,
scoresub, select, serial, set_draw_slice, setmetatable, sfx, sget, sgn, shl,
shr, shutdown, sin, split, splore, spr, sqrt, srand, sset, sspr, stat, stop,
sub, t, time, tline, tonum, tostr, tostring, trace, type, unpack, yield
Numbers:
█: 0.5
▒: 23130.5
🐱: 20767.5
⬇️: 3
░: 32125.5
✽: -18402.5
●: -1632.5
♥: 20927.5
☉: -19008.5
웃: -26208.5
⌂: -20192.5
⬅️: 0
😐: -24351.5
♪: -25792.5
🅾️: 4
◆: -20032.5
…: -2560.5
➡️: 1
★: -20128.5
⧗: 6943.5
⬆️: 2
ˇ: -2624.5
∧: 31455.5
❎: 5
▤: 3855.5
▥: 21845.5
Tables:
_pausemenu: {}
Others:
None
]]

#include ../lib/utils.lua

-- TODO: Assert all known builtins are not nil

local functionKeys = {}
local numberKeys = {}
local tableKeys = {}
local otherKeys = {}

for k, v in pairs(_ENV) do
  if type(v) == "function" then
    add(functionKeys, k)
  elseif type(v) == "number" then
    add(numberKeys, k)
  elseif type(v) == "table" then
    add(tableKeys, k)
  else
    add(otherKeys, k)
  end
end

printh("Functions:")
printh(join(sortedArray(functionKeys), ", "))

printh("Numbers:")
for k in all(sortedArray(numberKeys)) do
  printh(k .. ": " .. tostr(_ENV[k]))
end

printh("Tables:")
for k in all(sortedArray(tableKeys)) do
  printh(k .. ": " .. objectToString(_ENV[k]))
end

printh("Others:")
if (#otherKeys == 0) then
  printh("None")
else
  for k in all(sortedArray(otherKeys)) do
    printh(k .. ": " .. type(_ENV[k]))
  end
end

printh("Questionable Pico-ls builtins:")
local questionablePicolsBuiltins = { "rawequals", "self", "coyield", "?" }
for k in all(questionablePicolsBuiltins) do
  printh(k .. ": " .. type(_ENV[k]))
end

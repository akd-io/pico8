-- rnd32() returns a random number between 0x0000.0000 and 0xffff.fffe,
-- inclusive.
-- It does this by calling rnd(~0), as ~0 = bnot(0x0000.0000) = 0xffff.ffff
-- 0xffff.fffe is the highest the rnd() function will go, as it's max argument
-- is exclusive.
-- Some use rnd(-1), but rnd(~0) is superior as -1 is only 0xffff.0000.
-- Devs should use rnd(~0) directly to save a function call, but rnd32() is
-- here for documentation purposes.
function rnd32()
  return rnd(~0)
end
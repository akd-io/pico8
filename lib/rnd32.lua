-- rnd32() returns a random number between 0x0000.0000 and 0xffff.fffe, inclusive, by calling rnd(~0), equivalent to rnd(0xffff.ffff).
-- The specific value 0xffff.ffff is excluded because the rnd() function's limit argument is exclusive.
-- Many developers use rnd(-1) but this translates to rnd(0xffff) and excludes 0x0000ffff possibilities instead of just 0x00000001.
-- An alternate version that supports 0xffff.ffff can be implented with two rnd()-calls, but is slower and not used here.
-- Devs should use rnd(~0) directly to save a function call, but it's here for documentation.
function rnd32()
  return rnd(~0)
end
-- withTempSeed() takes a seed and a callback function and calls the callback
-- function with the seed set to the given value. Before and after the callback
-- function is called, the current PRNG state is saved and restored, so the
-- program can continue non-deterministically. Read about the PRNG state in
-- memory here: https://pico-8.fandom.com/wiki/Memory#Hardware_state
function withTempSeed(seed, callback)
  -- Save PRNG state, the 8 bytes starting at 0x5f44.
  local state1, state2 = $0x5f44, $0x5f48
  -- Set new seed
  srand(seed)
  -- Call callback function
  local retval = callback()
  -- Restore PRNG state
  poke4(0x5f44, state1, state2)
  -- Return value from callback function
  return retval
end
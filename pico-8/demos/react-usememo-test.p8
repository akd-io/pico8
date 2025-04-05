pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- React useMemo Test
-- by akd
--[[
  Prints:
    useMemo: Calculated doubleFlooredCount: 0
    App: Count: 0.3 FlooredCount: 0 DoubleFlooredCount: 0
    App: Count: 0.6 FlooredCount: 0 DoubleFlooredCount: 0
    App: Count: 0.9 FlooredCount: 0 DoubleFlooredCount: 0
    useMemo: Calculated doubleFlooredCount: 2
    App: Count: 1.2 FlooredCount: 1 DoubleFlooredCount: 2
    App: Count: 1.4999 FlooredCount: 1 DoubleFlooredCount: 2
    App: Count: 1.7999 FlooredCount: 1 DoubleFlooredCount: 2
    useMemo: Calculated doubleFlooredCount: 4
    App: Count: 2.0999 FlooredCount: 2 DoubleFlooredCount: 4
    App: Count: 2.3999 FlooredCount: 2 DoubleFlooredCount: 4
    App: Count: 2.6999 FlooredCount: 2 DoubleFlooredCount: 4
    App: Count: 2.9999 FlooredCount: 2 DoubleFlooredCount: 4
]]
#include ../lib/react.lua

local function App()
  local state = useState({
    count = 0
  })
  state.count += 0.3
  local flooredCount = flr(state.count)

  local doubleFlooredCount = useMemo(
    function()
      local doubleFlooredCount = flooredCount * 2
      printh("useMemo: Calculated doubleFlooredCount: " .. doubleFlooredCount)
      return doubleFlooredCount
    end,
    { flooredCount }
  )

  printh("App: Count: " .. state.count .. " FlooredCount: " .. flooredCount .. " DoubleFlooredCount: " .. doubleFlooredCount)
end

for i = 1, 10 do
  renderRoot(App)
end

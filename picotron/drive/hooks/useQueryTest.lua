include("/lib/react.lua")
renderRoot, useState, createContext, useContext, useMemo = __initReact()
include("/hooks/useQuery.lua")

window({
  width = 120,
  height = 50,
})

local f = 0
function App()
  local query = useQuery("http://localhost:3000/hello-world")
  f += 1

  cls()
  print("frame: " .. f)
  print("result: " .. tostr(query.result))
  print("error: " .. tostr(query.error))
  print("loading: " .. tostr(query.loading))
end

function _draw()
  renderRoot(App)
end

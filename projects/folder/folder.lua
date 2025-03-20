local lsContext = createContext(ls())

function MyComp()
  local context = useContext(lsContext)

  printh(arrayToString(context))

  rectfill(20, 20, 30, 30, 5)
end

function App()
  cls()
  rectfill(0, 0, 10, 10, 5)

  return {
    { MyComp }
  }
end

function _update60() end
function _draw()
  renderRoot(App)
end
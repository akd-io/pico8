function useQuery(url)
  local state = useState({
    result = nil,
    error = nil,
    loading = true,
  })

  local a, b, c = useMemo(function()
    local _a, _b, _c = fetch(url)
    state.loading = false
    return _a, _b, _c
  end, { url })
  printh("a: " .. tostr(a))
  printh("b: " .. tostr(b))
  printh("c: " .. tostr(c))

  return state
end

include("/lib/describe.lua")

function useLs(url)
  local privateState = useState({
    workerID = nil
  })
  local state = useState({})

  useMemo(function()
    on_event(
      "ls_result",
      function(msg)
        printh(describe(msg))
        local packedLsResult = msg.packedLsResult
        printh(describe(packedLsResult))
        local a, b, c = unpack(packedLsResult, 1, 3)
        printh("a: " .. tostr(a))
        printh("b: " .. tostr(b))
        printh("c: " .. tostr(c))
        state.result = a
        state.meta = b
        state.error = c
        state.loading = false
      end
    )
  end, {})

  useMemo(function()
    state.result = nil
    state.meta = nil
    state.error = nil
    state.loading = true

    if (privateState.workerID != nil) then
      -- Kill worker
      printh("Killing worker")
      send_message(2, { event = "kill_process", proc_id = privateState.workerID })
    end
    privateState.workerID = create_process("useLsWorker.lua", { argv = { url } })
    printh("workerID: " .. tostr(privateState.workerID))
  end, { url })

  return state
end

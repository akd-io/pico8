include("/lib/describe.lua")

function useDirs(paths)
  --- Path to PID map
  ---@type { [string]: number? }
  local workerIDs = useState({})

  --- Path to {result, loading} map
  ---@type { [string]: { result?: table, loading: boolean } }
  local states = useState({})

  useMemo(function()
    on_event(
      "dir_result",
      function(msg)
        printh(describe(msg))
        local path = msg.path
        local packedLsResult = msg.packedLsResult
        printh(describe(packedLsResult))
        local a, b, c = unpack(packedLsResult, 1, packedLsResult.n)
        printh("a: " .. tostr(a))
        printh("b: " .. tostr(b))
        printh("c: " .. tostr(c))
        states[path].result = a
        states[path].loading = false
        workerIDs[path] = nil
      end
    )
  end, {})

  useMemo(function()
    -- TODO: Traverse workerIDs instead of paths to kill workers that are no longer needed
    for path in all(paths) do
      if (states[path] == nil) then
        states[path] = {
          result = nil,
        }
      end
      states[path].loading = true

      if (workerIDs[path] != nil) then
        -- Kill worker
        printh("Killing worker for path " .. path)
        send_message(2, { event = "kill_process", proc_id = workerIDs[path] })
      end
      workerIDs[path] = create_process("useDirWorker.lua", { argv = { path } })
      printh("workerID: " .. tostr(workerIDs[path]))
    end
  end, { paths })

  return states
end

function useDir(path)
  local stabilePaths = useMemo(function()
    return { path }
  end, { path })

  return useDirs(stabilePaths)[path]
end

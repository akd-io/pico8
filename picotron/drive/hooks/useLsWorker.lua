local e = env()
local path = e.argv[1]
send_message(e.parent_pid, {
  event = "ls_result",
  packedLsResult = pack(ls(path))
})

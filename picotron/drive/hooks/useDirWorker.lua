local e = env()
local path = e.argv[1]
send_message(e.parent_pid, {
  event = "dir_result",
  path = path,
  packedLsResult = pack(ls(path))
})

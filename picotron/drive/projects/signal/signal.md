# `_signal()` Documentation

When patching `/system/wm.lua`, it is possible to call `_signal()` which is otherwise inaccessible to user scripts.

TODO: Test if it's accessible in `pm.lua` too.

For example, adding a `_signal(33)` call to the start of `/system/wm.lua`, and restarting `wm.lua` with `send_message(2, { event = "restart_process", proc_id = 3 })` will shutdown Picotron.

This document will try to document every `_signal()` code.

## Code search

TODO

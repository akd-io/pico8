# `_signal()` Documentation

When patching `/system/wm.lua`, it is possible to call `_signal()` which is otherwise inaccessible to user scripts.

TODO: Test if it's accessible in `pm.lua` too.

For example, adding a `_signal(33)` call to the start of `/system/wm.lua`, and restarting `wm.lua` with `send_message(2, { event = "restart_process", proc_id = 3 })` will shutdown Picotron.

This document will try to document every `_signal()` code.

## Results

List of all `_signal()` calls found in the source code.

- `_signal(16)`
  - Labeled `placeholder mechanism` in comment in relation to audio capture.
- `_signal(18)`
  - Starts video capture.
- `_signal(19)`
  - Ends video capture.
- `_signal(21)`
  - Capture screenshot.
- `_signal(22)`
  - Functionality unknown.
  - The `_signal(22)` call in `wm.lua` is commented "stay awake", in relation to battery saver.
- `_signal(23)`
  - Block buttons until released.
- `_signal(33)`
  - Shuts down Picotron.
- `_signal(34)`
  - Reboots Picotron.
- `_signal(35)`
  - Relates to booting to a minimal terminal setup.
  - The minimal terminal setup acts as a safe boot mode, and is used to recover from a borked `/appdata/system/startup.lua`.
  - `_signal(35)` seems to signal to the C code that `startup.lua` is booting to secure mode.
  - It is unknown though, what exact side-effect this has. That is, when the presumed flag set by `_signal(35)` is checked.
    - Calling `_signal(35)` from un-jettisoned userland code does not reboot the system for example.
  - It is used in `startup.lua` to secure boot when both control keys are held down.
  - Found with the help of `@kutuptilkisi` on Discord.
- `_signal(36)`
  - Functionality unknown.
  - Described to "finish loading core processes" in `wm.lua`.
- `_signal(37)`
  - Functionality unknown.
  - Dubbed "presentable signal" in `wm.lua`.
- `_signal(38)`
  - Used in `head.lua` to
    > start of userland code (for memory accounting)
- `_signal(39)`
  - Disable mounting.
- `_signal(40)`
  - Lock flushing.
- `_signal(41)`
  - Unlock flushing.
  - Lock and unlock is done before and after Picotron file system operations in
    `fs.lua`. I assume Picotron holds its file system in memory, and "flushing"
    means writing it to disk. Flushing is locked during file system operations
    to prevent corruption.
- `_signal(42)`
  - Export cartridge.
  - No guardrails. Consider using the `export` command instead.
- `_signal(65)`
  - Mounts host desktop.

## Code search

Search term: `_signal(`

Files to include: `picotron/drive/`

Context lines: `0`

```
105 results - 17 files

picotron/drive/dumps/ram/mount/gfrbswob/system/startup.lua:
  107: 	if (stat(988) > 0) bypass = true _signal(35)
  201: 		_signal(39)

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/app_menu.lua:
  88: 			_signal(23) -- block all buttons until released

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/events.lua:
  304: 			-- _signal(23)
  381: 		_signal(23)
  461: 			_signal(23) -- also: block buttons. Don't want the "v" press to pass through as a button press

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/fs.lua:
   877: 			_signal(40)
   879: 			_signal(41)
  1020: 		_signal(40)
  1022: 		_signal(41)
  1129: 		_signal(40) -- 0.1.1e compound op lock (prevent flushing cart halfway through moving)
  1131: 		_signal(41)
  1135: 		_signal(40)
  1137: 		_signal(41)
  1149: 		_signal(40) -- 0.1.1e: lock flushing for compound operation; don't want to e.g. store a cart on host that is halfway through being copied
  1151: 		_signal(41) -- unlock

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/head.lua:
  454: 		_signal(38) -- start of userland code (for memory accounting)

picotron/drive/dumps/ram/mount/gfrbswob/system/pm/pm.lua:
   18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
   22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  113: 		_signal(33)
  119: 		_signal(34)
  125: 		_signal(65)
  159: 		_signal(42)

picotron/drive/dumps/ram/mount/gfrbswob/system/wm/wm.lua:
   636: 	--_signal(36) -- finished loading core processes  (deleteme -- shouldn't need)
   849: 	_signal(23) -- block buttons
  2234: 					_signal(37)
  2243: 				_signal(37)
  2250: 			_signal(37)
  2552: 		if (sdat.fastquit) _signal(33)
  2557: 		_signal(33)
  2719: 			_signal(19)
  2725: 		if (not fstat("/desktop/host")) _signal(65)
  2726: 		_signal(16) -- placeholder mechanism
  3033: 			_signal(22) -- stay awake
  3608: 	if (not fstat("/desktop/host")) _signal(65)
  3627: 	_signal(18)
  3634: 	if (not fstat("/desktop/host")) _signal(65)
  3652: 	_signal(21)
  3920: 		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})
  3957: 	--	add(item, {"\^:00387f7f7f7f7f00 Host Desktop", function() _signal(65) end})

picotron/drive/dumps/system/startup.lua:
  107: 	if (stat(988) > 0) bypass = true _signal(35)
  201: 		_signal(39)

picotron/drive/dumps/system/lib/app_menu.lua:
  88: 			_signal(23) -- block all buttons until released

picotron/drive/dumps/system/lib/events.lua:
  304: 			-- _signal(23)
  381: 		_signal(23)
  461: 			_signal(23) -- also: block buttons. Don't want the "v" press to pass through as a button press

picotron/drive/dumps/system/lib/fs.lua:
   877: 			_signal(40)
   879: 			_signal(41)
  1020: 		_signal(40)
  1022: 		_signal(41)
  1129: 		_signal(40) -- 0.1.1e compound op lock (prevent flushing cart halfway through moving)
  1131: 		_signal(41)
  1135: 		_signal(40)
  1137: 		_signal(41)
  1149: 		_signal(40) -- 0.1.1e: lock flushing for compound operation; don't want to e.g. store a cart on host that is halfway through being copied
  1151: 		_signal(41) -- unlock

picotron/drive/dumps/system/lib/head.lua:
  454: 		_signal(38) -- start of userland code (for memory accounting)

picotron/drive/dumps/system/pm/pm.lua:
   18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
   22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  113: 		_signal(33)
  119: 		_signal(34)
  125: 		_signal(65)
  159: 		_signal(42)

picotron/drive/dumps/system/wm/wm.lua:
   636: 	--_signal(36) -- finished loading core processes  (deleteme -- shouldn't need)
   849: 	_signal(23) -- block buttons
  2234: 					_signal(37)
  2243: 				_signal(37)
  2250: 			_signal(37)
  2552: 		if (sdat.fastquit) _signal(33)
  2557: 		_signal(33)
  2719: 			_signal(19)
  2725: 		if (not fstat("/desktop/host")) _signal(65)
  2726: 		_signal(16) -- placeholder mechanism
  3033: 			_signal(22) -- stay awake
  3608: 	if (not fstat("/desktop/host")) _signal(65)
  3627: 	_signal(18)
  3634: 	if (not fstat("/desktop/host")) _signal(65)
  3652: 	_signal(21)
  3920: 		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})
  3957: 	--	add(item, {"\^:00387f7f7f7f7f00 Host Desktop", function() _signal(65) end})

picotron/drive/projects/signal/signal.md:
   1: # `_signal()` Documentation
   3: When patching `/system/wm.lua`, it is possible to call `_signal()` which is otherwise inaccessible to user scripts.
   7: For example, adding a `_signal(33)` call to the start of `/system/wm.lua`, and restarting `wm.lua` with `send_message(2, { event = "restart_process", proc_id = 3 })` will shutdown Picotron.
   9: This document will try to document every `_signal()` code.
  13: - `_signal(33)` shutdown?

picotron/drive/projects/stat/search.txt:
   50:   107: 	if (stat(988) > 0) bypass = true _signal(35)
  216:   18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
  220:   22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  296:   2719  			_signal(19)
  300:   3920  		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})
  607:   107: 	if (stat(988) > 0) bypass = true _signal(35)
  868:   18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
  872:   22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  982:   2719  			_signal(19)
  986:   3920  		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})

picotron/drive/projects/stat/stats.md:
  462:   18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
  482:   18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
  572:   22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  653:   22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  770:   3920  		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})
  783:   3920  		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})
  812:   2719  			_signal(19)
  829:   2719  			_signal(19)
  889:   107: 	if (stat(988) > 0) bypass = true _signal(35)
  894:   107: 	if (stat(988) > 0) bypass = true _signal(35)
```

After regex101 cleanup + unique + sort:

```
_signal()
_signal(16)
_signal(18)
_signal(19)
_signal(21)
_signal(22)
_signal(23)
_signal(33)
_signal(34)
_signal(35)
_signal(36)
_signal(37)
_signal(38)
_signal(39)
_signal(40)
_signal(41)
_signal(42)
_signal(65)
```

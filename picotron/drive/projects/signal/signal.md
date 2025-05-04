# `_signal()` Documentation

The `_signal()` function is accessible by un-jettisoned scripts. It is similar to `stat()` but is used to send signals back to the picotron app instead of reading values from it.

This document will try to document every `_signal()` code.

## Results

- `_signal(16)`
  - Starts and stops audio capture.
  - Found with the help of `@_maxine_` on Discord [here](https://discord.com/channels/1068899948592107540/1358151110917099785/1366298848590434376).
  - See also `stat(322)` in the [`stat()` Documentation](../stat/stats.md#results)
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

Files to include: `picotron/drive/dumps/0.2.0d/system`

Context lines: `1`

```
40 results - 7 files

picotron/drive/dumps/0.2.0d/system/startup.lua:
  106  	flip()
  107: 	if (stat(988) > 0) bypass = true _signal(35)
  108  end

  200  		-- printh("** sending signal 39: disabling mounting **")
  201: 		_signal(39)
  202  	end

picotron/drive/dumps/0.2.0d/system/lib/app_menu.lua:
  87  			--send_message(_pid(), {event = "unpause"})
  88: 			_signal(23) -- block all buttons until released
  89  			send_message(3, {event = "close_pause_menu"}) -- only applies to fullscreen apps

picotron/drive/dumps/0.2.0d/system/lib/events.lua:
  303  			-- update: nah -- too much magic and not that useful. better to do explicitly in _update() (e.g. ignore button presses while ctrl held)
  304: 			-- _signal(23)
  305

  380  		-- block buttons
  381: 		_signal(23)
  382

  460  			sandbox_clipboard_text = _get_userland_clipboard_text() -- ctrl-v taken as permission to transfer from userland clipboard to sandbox
  461: 			_signal(23) -- also: block buttons. Don't want the "v" press to pass through as a button press
  462  		end

picotron/drive/dumps/0.2.0d/system/lib/fs.lua:
   876  		if (type(obj) == "string" and ext and ext:is_cart()) then
   877: 			_signal(40)
   878  				_rm(location:path()) -- unmount existing cartridge // to do: be more efficient
   879: 			_signal(41)
   880  			return _store_local(location, obj)

  1019  		if (f1:prot()) return -- rm not supported by protocols yet
  1020: 		_signal(40)
  1021  			local ret = _rm(f1, 0, 0) -- atomic operation
  1022: 		_signal(41)
  1023  		return ret

  1128
  1129: 		_signal(40) -- 0.1.1e compound op lock (prevent flushing cart halfway through moving)
  1130  			local res = _cp(src, dest, true, nil, bbs_id) -- atomic operation
  1131: 		_signal(41)
  1132  		if (res) return res -- copy failed

  1134  		-- copy completed -- safe to delete src
  1135: 		_signal(40)
  1136  			_rm(src)
  1137: 		_signal(41)
  1138  	end

  1148
  1149: 		_signal(40) -- 0.1.1e: lock flushing for compound operation; don't want to e.g. store a cart on host that is halfway through being copied
  1150  			local ret0, ret1 = _cp(src, dest, nil, nil, bbs_id) -- atomic operation
  1151: 		_signal(41) -- unlock
  1152  		return ret0, ret1

picotron/drive/dumps/0.2.0d/system/lib/head.lua:
  456
  457: 		_signal(38) -- start of userland code (for memory accounting)
  458

picotron/drive/dumps/0.2.0d/system/pm/pm.lua:
   17  	-- headless script: shutdown when no userland processes remaining
   18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
   19

   21  	-- to do: this test no longer works
   22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
   23

  112  	function()
  113: 		_signal(33)
  114  	end

  118  	function()
  119: 		_signal(34)
  120  	end

  124  	function()
  125: 		_signal(65)
  126  	end

  158
  159: 		_signal(42)
  160

picotron/drive/dumps/0.2.0d/system/wm/wm.lua:
   635
   636: 	--_signal(36) -- finished loading core processes  (deleteme -- shouldn't need)
   637  	--flip()

   848
   849: 	_signal(23) -- block buttons
   850

  2233  					if (last_fullscreen_workspace) set_workspace(last_fullscreen_workspace)
  2234: 					_signal(37)
  2235  					sent_presentable_signal = true

  2242  				if (last_desktop_workspace) set_workspace(last_desktop_workspace)
  2243: 				_signal(37)
  2244  				sent_presentable_signal = true

  2249  		if (t() > 7.0) then
  2250: 			_signal(37)
  2251  			sent_presentable_signal = true

  2551  	if (key("ctrl") and dkeyp("q")) then
  2552: 		if (sdat.fastquit) _signal(33)
  2553  	end

  2556  	if (key("alt") and dkeyp("f4")) then
  2557: 		_signal(33)
  2558  	end

  2718  		if (key("ctrl") and dkeyp("9") or stat(321) >= max_gif_frames()) then
  2719: 			_signal(19)
  2720  		end

  2724  	if (key("ctrl") and dkeyp("0")) then
  2725: 		if (not fstat("/desktop/host")) _signal(65)
  2726: 		_signal(16) -- placeholder mechanism
  2727  	end

  3032  		if (not screensaver_proc_id) then
  3033: 			_signal(22) -- stay awake
  3034  		end

  3607
  3608: 	if (not fstat("/desktop/host")) _signal(65)
  3609

  3626
  3627: 	_signal(18)
  3628  end

  3633
  3634: 	if (not fstat("/desktop/host")) _signal(65)
  3635

  3651
  3652: 	_signal(21)
  3653  end

  3924  	if (stat(320) > 0) then
  3925: 		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})
  3926  	else

  3961  	add(item, {"\^:7f7d7b7d7f083e00 Terminal", function() create_process("/system/apps/terminal.lua") end})
  3962: 	--	add(item, {"\^:00387f7f7f7f7f00 Host Desktop", function() _signal(65) end})
  3963
```

After these operations:

1. regex101 search `/_signal\(.*\)/gmU`
2. regex101 plain text export
3. uniqueness filter (VSCode `> Delete Duplicate Lines`)
4. sort (VSCode `> Sort lines (natural)`)

The result is:

```
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

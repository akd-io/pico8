# `stat()` Documentation

This file attempts to document all `stat()` codes, enriching the official documentation with its hidden features.

## TODO

- Try logging stats above 0..1000.
- Try logging state below 0.
- Try logging several return values from stat(), as some stats are known to return multiple values.
  - Try logging `#pack(stat(i))`, to get number of returned values.

## Table of Contents

- [Results](#results)
- [Official `stat()` documentation](#official-stat-documentation)
  - [`stat()` section](#stat-section)
  - [HTML Export Size Limit section](#html-export-size-limit-section)
  - [Mixer state section](#mixer-state-section)
- [Undocumented stats gathered from `stat.lua` script](#undocumented-stats-gathered-from-statlua-script)
- [Source search](#source-search)
  - [All unique `stat()` calls](#all-unique-stat-calls)
  - [Undocumented unique `stat()` calls](#undocumented-unique-stat-calls)
  - [Code searches](#code-searches)
    - [301 Search](#301-search)
    - [302 Search](#302-search)
    - [307 Search](#307-search)
    - [315 Search](#315-search)
    - [316 Search](#316-search)
    - [317 Search](#317-search)
    - [318 Search](#318-search)
    - [320 Search](#320-search)
    - [321 Search](#321-search)
    - [330 Search](#330-search)
    - [987 Search](#987-search)
    - [988 Search](#988-search)

## Results

- `stat(0)` memory usage (triggers a garbage collection)
- `stat(1)` cpu usage (try to stay under ~0.9 to maintain 60fps)
- `stat(2)` reserved
- `stat(3)` raw mememory usage (no GC, so value jumps around)
- `stat(5)` runtime, system version
- `stat(7)` operating fps (60,30,20,15)
- `stat(86)` epoch time
- `stat(87)` timezone delta in seconds
- `stat(101)` web: player cart id (when playing a bbs cart; nil otherwise)
- `stat(150)` web: window.location.href
- `stat(151)` web: stat(150) up to the end of the window.location.pathname
- `stat(152)` web: window.location.host
- `stat(153)` web: window.location.hash
- `stat(301)` (undocumented)
  - See [code references](#301-search)
- `stat(302, i)` (undocumented)
  - See [code references](#302-search)
- `stat(307)` (undocumented)
  - `stat(307) & 0x1` seems to indicate `307` is a bitfield and
    - `0b1` is code for "trusted system apps"
  - See [code references](#307-search)
- `stat(308)` (undocumented)
  - Found to have value `1973.0` in `stat.lua` output.
  - No code references.
- `stat(309)` (undocumented)
  - Found to have value `60531740.0` in `stat.lua` output.
  - No code references.
- `stat(310)` (undocumented)
  - Found to have value `551.0` in `stat.lua` output.
  - No code references.
- `stat(311)` (undocumented)
  - Found to have value `15833.0` in `stat.lua` output.
  - No code references.
- `stat(312)` (undocumented)
  - Found to have value `4096.0` in `stat.lua` output.
  - No code references.
- `stat(313)` (undocumented)
  - Found to have value `626688.0` in `stat.lua` output.
  - No code references.
- `stat(314)` (undocumented)
  - Returns the value of pi, the mathematical constant.
  - Found to have value `3.1415926535898` in `stat.lua` output.
  - No code references.
- `stat(315)` (undocumented)
  - Presence of the `-x` CLI argument when running headless using `picotron -x <path/to/my/script.lua>`.
  - Found with the help of `@_maxine_` on discord
  - See [code references](#315-search)
- `stat(316)` (undocumented)
  - The path specified when running headless using `picotron -x <path/to/my/script.lua>`.
  - Found with the help of `@_maxine_` on discord
  - See [code references](#316-search)
- `stat(317)` (undocumented)
  - See [code references](#317-search)
- `stat(318)` (undocumented)
  - See [code references](#318-search)
- `stat(320)` (undocumented)
  - See [code references](#320-search)
- `stat(321)` (undocumented)
  - See [code references](#321-search)
- `stat(330)` (undocumented)
  - See [code references](#330-search)
- `stat(400 + c, 0)` note is held (0 false 1 true)
- `stat(400 + c, 1)` channel instrument
- `stat(400 + c, 2)` channel vol
- `stat(400 + c, 3)` channel pan
- `stat(400 + c, 4)` channel pitch
- `stat(400 + c, 5)` channel bend
- `stat(400 + c, 6)` channel effect
- `stat(400 + c, 7)` channel effect_p
- `stat(400 + c, 8)` channel tick len
- `stat(400 + c, 9)` channel row
- `stat(400 + c, 10)` channel row tick
- `stat(400 + c, 11)` channel sfx tick
- `stat(400 + c, 12)` channel sfx index (-1 if none finished)
- `stat(400 + c, 13)` channel last played sfx index
- `stat(400 + c, 19, addr)` fetch stereo output buffer (returns number of samples)
- `stat(400 + c, 20 + n, addr)` fetch mono output buffer for a node n (0..7)
- `stat(464)` bitfield indicating which channels are playing a track (sfx)
- `stat(465, addr)` copy last mixer stereo output buffer output is written as int16's to addr. returns number of samples written.
- `stat(466)` which pattern is playing (-1 for no music)
- `stat(467)` return the index of the left-most non-looping music channel
- `stat(985)` (undocumented)
  - Found to have value `1.0` in `stat.lua` output.
  - No code references.
- `stat(987)` (undocumented)
  - Found to have value `201225.0` in `stat.lua` output.
  - See [code references](#987-search)
- `stat(988)` (undocumented)
  - See [code references](#988-search)

## Official `stat()` documentation

### `stat()` section

From https://www.lexaloffle.com/dl/docs/picotron_manual.html#stat

> Get system status where x is:
>
> ```
>   0  memory usage        // triggers a garbage collection
>   1  cpu usage           // try to stay under ~0.9 to maintain 60fps)
>   2  reserved
>   3  raw mememory usage  // no GC, so value jumps around)
>   5  runtime, system version
>   7  operating fps (60,30,20,15)
>  86  epoch time
>  87  timezone delta in seconds
> 101  web: player cart id (when playing a bbs cart; nil otherwise)
> 150  web: window.location.href
> 151  web: stat(150) up to the end of the window.location.pathname
> 152  web: window.location.host
> 153  web: window.location.hash
> ```

### HTML Export Size Limit section

The HTML Export Size Limit section of the docs mention `stat(151)`, but its purpose it already documented in the `Stat()` section.

Included here for completeness.

From https://www.lexaloffle.com/dl/docs/picotron_manual.html#HTML_Export_Size_Limit

> The html exporter can handle carts that are up to 8MB in .p64.rom format (use "info" command to check). Beyond that size, fetch() can be used to download more data as needed using stat(151) to prepend the host and path the page is being served from: fetch(stat(151).."level2.pod").

### Mixer state section

From https://www.lexaloffle.com/dl/docs/picotron_manual.html#Querying_Mixer_State

> Global mixer state:
>
> ```
> stat(464)         -- bitfield indicating which channels are playing a track (sfx)
> stat(465, addr)   -- copy last mixer stereo output buffer output is written as
>                   -- int16's to addr. returns number of samples written.
> stat(466)         -- which pattern is playing (-1 for no music)
> stat(467)         -- return the index of the left-most non-looping music channel
> ```
>
> Per channel (c) state:
>
> ```
> stat(400 + c,  0) -- note is held (0 false 1 true)
> stat(400 + c,  1) -- channel instrument
> stat(400 + c,  2) -- channel vol
> stat(400 + c,  3) -- channel pan
> stat(400 + c,  4) -- channel pitch
> stat(400 + c,  5) -- channel bend
> stat(400 + c,  6) -- channel effect
> stat(400 + c,  7) -- channel effect_p
> stat(400 + c,  8) -- channel tick len
> stat(400 + c,  9) -- channel row
> stat(400 + c, 10) -- channel row tick
> stat(400 + c, 11) -- channel sfx tick
> stat(400 + c, 12) -- channel sfx index (-1 if none finished)
> stat(400 + c, 13) -- channel last played sfx index
> stat(400 + c, 19,     addr) -- fetch stereo output buffer (returns number of samples)
> stat(400 + c, 20 + n, addr) -- fetch mono output buffer for a node n (0..7)
> ```

## Undocumented stats gathered from `stat.lua` script

The following list contains stats gathered from [stat.lua](stat.lua), with documented stats removed.

```
308 = 1973.0,
309 = 60531740.0,
310 = 551.0,
311 = 15833.0,
312 = 4096.0,
313 = 626688.0,
314 = 3.1415926535898,
985 = 1.0,
987 = 201225.0,
```

`stat.txt` also has 400..415 set to -1.0. It's an expected range to get -1.0 per the [Mixer State](#mixer-state) section above.

But it seems there are 16 instead of the expected 8. Might just be because of stereo.

## Source search

A search through a dump of `/ram` and `/system` using a VSCode Search Editor with the below settings yielded the results found in [search.txt](search.txt).

Search regex: `[^f]stat\(`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

### All unique `stat()` calls

Pasting [search.txt](search.txt) into [regex101](https://regex101.com/), using regex `/stat\(.*?\)/gm`, can exporting the matches as plain text, [all-stat-calls.txt](all-stat-calls.txt) was generated.

Running VSCode's `> Delete Duplicate Lines` and `> Sort lines (natural)` on [all-stat-calls.txt](all-stat-calls.txt), gave the following list of all unique `stat()` calls:

```
stat()
stat(0)
stat(1)
stat(5)
stat(7)
stat(87)
stat(101)
stat(152)
stat(301)
stat(302, i)
stat(307)
stat(315)
stat(316)
stat(317)
stat(318)
stat(320)
stat(321)
stat(330)
stat(400 + ci_channel, 8)
stat(400 + ci_channel, 20 + node_index, tick_addr)
stat(400 + i, 9)
stat(400 + i, 12)
stat(400 + stat(467)
stat(400+i,1 )
stat(400+i,1)
stat(400+i,9 )
stat(400+i,12)
stat(400+i,19,0x90000)
stat(464)
stat(465,0,0xe0000)
stat(466)
stat(987)
stat(988)
stat(wallpaper)
```

Note:

- `stat()` was from a comment, and irrelevant.
- `stat(400 + stat(467)` was cut short. Full call from source is `stat(400 + stat(467), 9)`
- `stat(wallpaper)`'s full source is `fstat(wallpaper)`, and irrelevant.

### Undocumented unique `stat()` calls

This list takes the previous list, and removed officially documented ones.

```
stat(301)
stat(302, i)
stat(307)
stat(315)
stat(316)
stat(317)
stat(318)
stat(320)
stat(321)
stat(330)
stat(987)
stat(988)
```

### Code searches

#### 301 Search

Search regex: `[^f]stat\(301`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
12 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/boot.lua:
   90  	local keep_going = true
   91: 	local remaining = allotment - stat(301)
   92  	local slices = 0

  199
  200: 	local userland_cpu = 0.98 - wm_cpu_max - stat(301)
  201: 	local cpu0 = stat(301)
  202

  204
  205: 	local cpu1 = stat(301)
  206

  239
  240: 	local cpu2 = stat(301)
  241

  253
  254: 	flip() -- reset cpu_cycles for next frame? doesn't matter now that using stat(301) though.
  255

picotron/drive/dumps/system/boot.lua:
   90  	local keep_going = true
   91: 	local remaining = allotment - stat(301)
   92  	local slices = 0

  199
  200: 	local userland_cpu = 0.98 - wm_cpu_max - stat(301)
  201: 	local cpu0 = stat(301)
  202

  204
  205: 	local cpu1 = stat(301)
  206

  239
  240: 	local cpu2 = stat(301)
  241

  253
  254: 	flip() -- reset cpu_cycles for next frame? doesn't matter now that using stat(301) though.
  255
```

#### 302 Search

Search regex: `[^f]stat\(302`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
2 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/events.lua:
  151  	for i=1,255 do
  152: 		local mapped_name = stat(302, i)
  153  		if (mapped_name and mapped_name ~= "") then

picotron/drive/dumps/system/lib/events.lua:
  151  	for i=1,255 do
  152: 		local mapped_name = stat(302, i)
  153  		if (mapped_name and mapped_name ~= "") then
```

#### 307 Search

Search regex: `[^f]stat\(307`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
14 results - 6 files

picotron/drive/dumps/ram/mount/gfrbswob/system/apps/filenav.p64:
  3029
  3030: 				-- printh("clicked on file; {intention, open_with, fullpath(filename), stat(307)}"..pod{intention, env().open_with, fullpath(filename), stat(307)})
  3031

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/head.lua:
   203  	-- sandboxed programs can not create processes
   204: 	if _env().sandbox and ((stat(307) & 0x1) == 0) then -- sandboxed program that is not a trusted system app
   205

   363  	-- only "trusted system apps" (currently /system/*) can pass in a custom fileview
   364: 	if (stat(307) & 0x1) == 0 then
   365  		new_env.fileview = {}

  1064  		proc_id == _pid() or                          -- can always send message to self
  1065: 		(stat(307) & 0x1) == 1 or                     -- can always send message if is bundled /system app (filenav)
  1066  		proc_id == 3 or                               -- can always send message to wm

picotron/drive/dumps/ram/mount/lnqujccm/open.lua:
  64
  65: 				-- printh("clicked on file; {intention, open_with, fullpath(filename), stat(307)}"..pod{intention, env().open_with, fullpath(filename), stat(307)})
  66

picotron/drive/dumps/ram/mount/mxhduaku/open.lua:
  64
  65: 				-- printh("clicked on file; {intention, open_with, fullpath(filename), stat(307)}"..pod{intention, env().open_with, fullpath(filename), stat(307)})
  66

picotron/drive/dumps/system/apps/filenav.p64:
  3029
  3030: 				-- printh("clicked on file; {intention, open_with, fullpath(filename), stat(307)}"..pod{intention, env().open_with, fullpath(filename), stat(307)})
  3031

picotron/drive/dumps/system/lib/head.lua:
   203  	-- sandboxed programs can not create processes
   204: 	if _env().sandbox and ((stat(307) & 0x1) == 0) then -- sandboxed program that is not a trusted system app
   205

   363  	-- only "trusted system apps" (currently /system/*) can pass in a custom fileview
   364: 	if (stat(307) & 0x1) == 0 then
   365  		new_env.fileview = {}

  1064  		proc_id == _pid() or                          -- can always send message to self
  1065: 		(stat(307) & 0x1) == 1 or                     -- can always send message if is bundled /system app (filenav)
  1066  		proc_id == 3 or                               -- can always send message to wm
```

#### 315 Search

Search regex: `[^f]stat\(315`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
8 results - 8 files

picotron/drive/dumps/ram/mount/gfrbswob/system/boot.lua:
  170  	-- to do: use time() for better sync
  171: 	if not played_boot_sound and stat(987) >= sfx_delay and stat(315) == 0 then
  172  		played_boot_sound = true

picotron/drive/dumps/ram/mount/gfrbswob/system/startup.lua:
  59
  60: if (stat(315) > 0) then
  61  	-- headless script

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/head.lua:
  778
  779: 		if (stat(315) > 0) then
  780  			_printh(_tostring(str))

picotron/drive/dumps/ram/mount/gfrbswob/system/pm/pm.lua:
  17  	-- headless script: shutdown when no userland processes remaining
  18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
  19

picotron/drive/dumps/system/boot.lua:
  170  	-- to do: use time() for better sync
  171: 	if not played_boot_sound and stat(987) >= sfx_delay and stat(315) == 0 then
  172  		played_boot_sound = true

picotron/drive/dumps/system/startup.lua:
  59
  60: if (stat(315) > 0) then
  61  	-- headless script

picotron/drive/dumps/system/lib/head.lua:
  778
  779: 		if (stat(315) > 0) then
  780  			_printh(_tostring(str))

picotron/drive/dumps/system/pm/pm.lua:
  17  	-- headless script: shutdown when no userland processes remaining
  18: 	if (stat(315) > 0 and #_get_process_list() <= 3) _signal(33)
  19
```

#### 316 Search

Search regex: `[^f]stat\(316`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
2 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/startup.lua:
  61  	-- headless script
  62: 	create_process(stat(316))
  63  	return

picotron/drive/dumps/system/startup.lua:
  61  	-- headless script
  62: 	create_process(stat(316))
  63  	return
```

#### 317 Search

Search regex: `[^f]stat\(317`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
40 results - 8 files

picotron/drive/dumps/ram/mount/gfrbswob/system/startup.lua:
    8  	sdat = fetch"/system/misc/default_settings.pod"
    9: 	if (stat(317) > 0) then
   10  		sdat.wallpaper = "/system/wallpapers/pattern.p64"

   30  local ff = ls("/desktop")
   31: if (not ff or #ff == 0 or stat(317) > 0) then
   32  	mkdir ("/desktop") -- just in case
   33  	cp("/system/misc/drive.loc", "/desktop/drive.loc")
   34: 	if ((stat(317) & 0x2) == 0) cp("/system/misc/readme.txt", "/desktop/readme.txt") -- no readme for exports
   35  end

   72
   73: if (stat(317) & 0x2) > 0 then
   74  	-- export

  141
  142: if stat(317) == 0 then -- no tool workspaces for exports / bbs player
  143  	create_process("/system/apps/code.p64", {argv={"/ram/cart/main.lua"}})

  152  local wallpaper = (sdat and sdat.wallpaper) or "/system/wallpapers/pattern.p64"
  153: if ((stat(317) & 0x1) ~= 0) wallpaper = nil -- placeholder: exports do not observe wallpaper to avoid exported runtime/cart mismatch in exp/shared
  154  if (not fstat(wallpaper)) wallpaper = "/system/wallpapers/pattern.p64"

  160
  161: if stat(317) == 0 then -- no fullscreen terminal for exports / bbs player
  162  	create_process("/system/apps/terminal.lua",

  180
  181: if stat(317) > 0 then
  182  	-- player startup

  198
  199: 	if ((stat(317) & 0x3) == 0x3) then -- player that has embedded rom
  200  		-- printh("** sending signal 39: disabling mounting **")

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/fs.lua:
   92  		-- bbs web player
   93: 		if ((stat(317) & 0x3) == 0x1) then
   94  			if (stat(152) == "localhost") return "http://localhost" -- dev

   98  		-- any other exports: bbs:// is not supported (to do: explicit error codepath -- just disable bbs:// ? )
   99: 		if ((stat(317) & 0x1) > 0) return ""
  100

  106  		-- bbs web player: just use get_cart for now -- later: use cdn
  107: 		if ((stat(317) & 0x3) == 0x1) return get_bbs_host().."/bbs/get_cart.php?cat=8&lid="..bbs_id
  108  		-- exports: bbs:// otherwise not supported
  109: 		if (stat(317) > 0) return ""
  110  		-- binaries: use cdn

picotron/drive/dumps/ram/mount/gfrbswob/system/pm/pm.lua:
  21  	-- to do: this test no longer works
  22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  23

picotron/drive/dumps/ram/mount/gfrbswob/system/wm/wm.lua:
   836  	if (not win) return false
   837: 	return win.fullscreen and win.player_cart and (stat(317)&0x3) == 0x3 and not win.can_escape_fullscreen
   838  end

  2221  	if (not sent_presentable_signal) then
  2222: 		if (stat(317) > 0) then
  2223  			-- exported cartridge / bbs player: show when a window is open, active (0x1) and not holding frame (0x2)

  2407  	-- deleteme -- happens when window manager sends signal(37) (wm_is_presentable)
  2408: 	-- if (time() == 1.5 and stat(317) == 0) set_workspace(5)
  2409

  2455  		-- 3 minutes; to do: store in settings.pod
  2456: 		if (stat(317) & 0x1) == 0 then -- placeholder: no screensaver for exports / bbs player (older exported runtimes can end up running newer screensavers)
  2457  			if ((time() > last_input_activity_t + 180 or test_screensaver_t0) and not screensaver_proc_id)

  2567
  2568: 		if stat(317) > 0 then
  2569  			-- exported player or bbs player: reset cart if it is active

  3939  	-- bbs:// not available for exports (and hide for bbs player)
  3940: 	if (stat(317) == 0) then
  3941  		-- to do: cartridges should launch splore (doubles as Favourites). Naming matches "Files" -- the objects you want to look through

picotron/drive/dumps/system/startup.lua:
    8  	sdat = fetch"/system/misc/default_settings.pod"
    9: 	if (stat(317) > 0) then
   10  		sdat.wallpaper = "/system/wallpapers/pattern.p64"

   30  local ff = ls("/desktop")
   31: if (not ff or #ff == 0 or stat(317) > 0) then
   32  	mkdir ("/desktop") -- just in case
   33  	cp("/system/misc/drive.loc", "/desktop/drive.loc")
   34: 	if ((stat(317) & 0x2) == 0) cp("/system/misc/readme.txt", "/desktop/readme.txt") -- no readme for exports
   35  end

   72
   73: if (stat(317) & 0x2) > 0 then
   74  	-- export

  141
  142: if stat(317) == 0 then -- no tool workspaces for exports / bbs player
  143  	create_process("/system/apps/code.p64", {argv={"/ram/cart/main.lua"}})

  152  local wallpaper = (sdat and sdat.wallpaper) or "/system/wallpapers/pattern.p64"
  153: if ((stat(317) & 0x1) ~= 0) wallpaper = nil -- placeholder: exports do not observe wallpaper to avoid exported runtime/cart mismatch in exp/shared
  154  if (not fstat(wallpaper)) wallpaper = "/system/wallpapers/pattern.p64"

  160
  161: if stat(317) == 0 then -- no fullscreen terminal for exports / bbs player
  162  	create_process("/system/apps/terminal.lua",

  180
  181: if stat(317) > 0 then
  182  	-- player startup

  198
  199: 	if ((stat(317) & 0x3) == 0x3) then -- player that has embedded rom
  200  		-- printh("** sending signal 39: disabling mounting **")

picotron/drive/dumps/system/lib/fs.lua:
   92  		-- bbs web player
   93: 		if ((stat(317) & 0x3) == 0x1) then
   94  			if (stat(152) == "localhost") return "http://localhost" -- dev

   98  		-- any other exports: bbs:// is not supported (to do: explicit error codepath -- just disable bbs:// ? )
   99: 		if ((stat(317) & 0x1) > 0) return ""
  100

  106  		-- bbs web player: just use get_cart for now -- later: use cdn
  107: 		if ((stat(317) & 0x3) == 0x1) return get_bbs_host().."/bbs/get_cart.php?cat=8&lid="..bbs_id
  108  		-- exports: bbs:// otherwise not supported
  109: 		if (stat(317) > 0) return ""
  110  		-- binaries: use cdn

picotron/drive/dumps/system/pm/pm.lua:
  21  	-- to do: this test no longer works
  22: 	if (stat(317) > 0 and #_get_process_list() <= 3) _signal(33)
  23

picotron/drive/dumps/system/wm/wm.lua:
   836  	if (not win) return false
   837: 	return win.fullscreen and win.player_cart and (stat(317)&0x3) == 0x3 and not win.can_escape_fullscreen
   838  end

  2221  	if (not sent_presentable_signal) then
  2222: 		if (stat(317) > 0) then
  2223  			-- exported cartridge / bbs player: show when a window is open, active (0x1) and not holding frame (0x2)

  2407  	-- deleteme -- happens when window manager sends signal(37) (wm_is_presentable)
  2408: 	-- if (time() == 1.5 and stat(317) == 0) set_workspace(5)
  2409

  2455  		-- 3 minutes; to do: store in settings.pod
  2456: 		if (stat(317) & 0x1) == 0 then -- placeholder: no screensaver for exports / bbs player (older exported runtimes can end up running newer screensavers)
  2457  			if ((time() > last_input_activity_t + 180 or test_screensaver_t0) and not screensaver_proc_id)

  2567
  2568: 		if stat(317) > 0 then
  2569  			-- exported player or bbs player: reset cart if it is active

  3939  	-- bbs:// not available for exports (and hide for bbs player)
  3940: 	if (stat(317) == 0) then
  3941  		-- to do: cartridges should launch splore (doubles as Favourites). Naming matches "Files" -- the objects you want to look through
```

#### 318 Search

Search regex: `[^f]stat\(318`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
12 results - 6 files

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/events.lua:
  448
  449: 		elseif stat(318) == 1 then
  450  			-- web: when ctrl-v, pretend the v didn't happen.

picotron/drive/dumps/ram/mount/gfrbswob/system/lib/head.lua:
  1046  	-- web debug
  1047: 	if (stat(318)==1) printh("@notify: "..msg_str.."\n")
  1048  end

picotron/drive/dumps/ram/mount/gfrbswob/system/wm/wm.lua:
   957  	if (haltable_proc_id == win.proc_id) has_exit = false    -- running /ram/cart via ctrl+r; just press escape instead
   958: 	if (win.player_cart and stat(318) == 1) has_exit = false -- running entry point cart / bbs cart under web (nothing to exit to)
   959

   961  		add(win.pmenu, {label = "Exit Cartridge", action = function()
   962: 			if is_fullscreen_export(win) and stat(318) == 0 then
   963  				-- 0.2.0b playing the entry point cart in a binary export -> quit to host OS

  2251  			sent_presentable_signal = true
  2252: 			-- if (stat(318) > 0) printh("@@ forced signal 37")
  2253  		end

  3978  	-- no need to shutdown on web
  3979: 	if (stat(318) == 0) add(item, {"\^:082a494141221c00 Shutdown", function() send_message(2, {event="shutdown"}) end})
  3980

picotron/drive/dumps/system/lib/events.lua:
  448
  449: 		elseif stat(318) == 1 then
  450  			-- web: when ctrl-v, pretend the v didn't happen.

picotron/drive/dumps/system/lib/head.lua:
  1046  	-- web debug
  1047: 	if (stat(318)==1) printh("@notify: "..msg_str.."\n")
  1048  end

picotron/drive/dumps/system/wm/wm.lua:
   957  	if (haltable_proc_id == win.proc_id) has_exit = false    -- running /ram/cart via ctrl+r; just press escape instead
   958: 	if (win.player_cart and stat(318) == 1) has_exit = false -- running entry point cart / bbs cart under web (nothing to exit to)
   959

   961  		add(win.pmenu, {label = "Exit Cartridge", action = function()
   962: 			if is_fullscreen_export(win) and stat(318) == 0 then
   963  				-- 0.2.0b playing the entry point cart in a binary export -> quit to host OS

  2251  			sent_presentable_signal = true
  2252: 			-- if (stat(318) > 0) printh("@@ forced signal 37")
  2253  		end

  3978  	-- no need to shutdown on web
  3979: 	if (stat(318) == 0) add(item, {"\^:082a494141221c00 Shutdown", function() send_message(2, {event="shutdown"}) end})
  3980
```

#### 320 Search

Search regex: `[^f]stat\(320`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
6 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/wm/wm.lua:
  2257  	-- show gif capture (don't draw inside captured area!)
  2258: 	if (stat(320) > 0) then
  2259  		local x,y,width,height,scale = peek2(0x40,5)

  2716  	-- finish capturing gif
  2717: 	if (stat(320) > 0) then
  2718  		if (key("ctrl") and dkeyp("9") or stat(321) >= max_gif_frames()) then

  3918
  3919: 	if (stat(320) > 0) then
  3920  		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})

picotron/drive/dumps/system/wm/wm.lua:
  2257  	-- show gif capture (don't draw inside captured area!)
  2258: 	if (stat(320) > 0) then
  2259  		local x,y,width,height,scale = peek2(0x40,5)

  2716  	-- finish capturing gif
  2717: 	if (stat(320) > 0) then
  2718  		if (key("ctrl") and dkeyp("9") or stat(321) >= max_gif_frames()) then

  3918
  3919: 	if (stat(320) > 0) then
  3920  		add(item, {"\^:06ff81b5b181ff00 End Recording", function() _signal(19) end})
```

#### 321 Search

Search regex: `[^f]stat\(321`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
8 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/wm/wm.lua:
  2261
  2262: 		polaroid(x,y,x+width-1,y+height-1, stat(321), max_gif_frames())
  2263  --[[

  2270  		local maxf = max_gif_frames()
  2271: 		local q = stat(321) * 32 / maxf
  2272  		local x0 = x + width - 40

  2275  		if (width > 100) then
  2276: 			print("\014frame "..flr(stat(321)).." / "..maxf, x+4,y+height+3, 7)
  2277  		else

  2717  	if (stat(320) > 0) then
  2718: 		if (key("ctrl") and dkeyp("9") or stat(321) >= max_gif_frames()) then
  2719  			_signal(19)

picotron/drive/dumps/system/wm/wm.lua:
  2261
  2262: 		polaroid(x,y,x+width-1,y+height-1, stat(321), max_gif_frames())
  2263  --[[

  2270  		local maxf = max_gif_frames()
  2271: 		local q = stat(321) * 32 / maxf
  2272  		local x0 = x + width - 40

  2275  		if (width > 100) then
  2276: 			print("\014frame "..flr(stat(321)).." / "..maxf, x+4,y+height+3, 7)
  2277  		else

  2717  	if (stat(320) > 0) then
  2718: 		if (key("ctrl") and dkeyp("9") or stat(321) >= max_gif_frames()) then
  2719  			_signal(19)
```

#### 330 Search

Search regex: `[^f]stat\(330`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
2 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/wm/wm.lua:
  2288  	-- debug: show when battery saver is being applied
  2289: 	-- if (stat(330) > 0) circfill(20,20,10,8) circfill(20,20,5,1)
  2290

picotron/drive/dumps/system/wm/wm.lua:
  2288  	-- debug: show when battery saver is being applied
  2289: 	-- if (stat(330) > 0) circfill(20,20,10,8) circfill(20,20,5,1)
  2290
```

#### 987 Search

Search regex: `[^f]stat\(987`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
2 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/boot.lua:
  170  	-- to do: use time() for better sync
  171: 	if not played_boot_sound and stat(987) >= sfx_delay and stat(315) == 0 then
  172  		played_boot_sound = true

picotron/drive/dumps/system/boot.lua:
  170  	-- to do: use time() for better sync
  171: 	if not played_boot_sound and stat(987) >= sfx_delay and stat(315) == 0 then
  172  		played_boot_sound = true
```

#### 988 Search

Search regex: `[^f]stat\(988`

Files to include: `picotron/drive/dumps/`

Context lines: `1`

```
2 results - 2 files

picotron/drive/dumps/ram/mount/gfrbswob/system/startup.lua:
  106  	flip()
  107: 	if (stat(988) > 0) bypass = true _signal(35)
  108  end

picotron/drive/dumps/system/startup.lua:
  106  	flip()
  107: 	if (stat(988) > 0) bypass = true _signal(35)
  108  end
```

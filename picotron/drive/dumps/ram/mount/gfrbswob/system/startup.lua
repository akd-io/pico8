--[[pod_format="raw",created="2024-03-14 04:10:03",modified="2024-03-14 04:20:48",revision=8]]

-- load settings
local sdat = fetch"/appdata/system/settings.pod"
if not sdat then
	-- install defaults
	sdat = fetch"/system/misc/default_settings.pod"
	store("/appdata/system/settings.pod", sdat)
end

-- install default desktop items
local ff = ls("/desktop")
if (not ff or #ff == 0) then
	mkdir ("/desktop") -- just in case
	store("/desktop/drive.loc", fetch("/system/misc/drive.loc"))
	store("/desktop/readme.txt", fetch("/system/misc/readme.txt"))
end

-- present working cartridge (dummy -- to do: remove)
store("/ram/system/pwc.pod", "/untitled.p64")

-- custom startup could opt to run different window / program manager
create_process("/system/pm/pm.lua")
create_process("/system/wm/wm.lua")


------------------------------------------------------------------------------------------------
--   hold down lctrl + rctrl on boot to start with a minimal terminal setup
--   useful for recovering from borked /appdata/system/startup.lua
------------------------------------------------------------------------------------------------

-- give a guaranteed short window to skip

for i=1,20 do
	flip()
	if (stat(988) > 0) bypass = true _signal(35) 
end


if (bypass) then
	create_process("/system/apps/terminal.lua", 
		{
			window_attribs = {fullscreen = true, pwc_output = true, immortal = true},
			immortal   = true -- exit() is a NOP; separate from window attribute :/
		}
	)
	return
end
------------------------------------------------------------------------------------------------
local runtime_version, system_version = stat(5)
local system_meta = _fetch_metadata_from_file("/system/.info.pod") or {}
if (system_meta.version ~= system_version) then
	printh("** version mismatch // /system: "..system_meta.version.." expects binaries: "..system_version)
	send_message(3, {event="report_error", content = "** system version mismatch **"})
	send_message(3, {event="report_error", content = "/system version is: "..system_meta.version})
	send_message(3, {event="report_error", content = "this build expects: "..system_version})
end
------------------------------------------------------------------------------------------------



if (fstat("/cart/main.lua")) then
	-- embedded cartridge (web or binary)
	-- not sandboxed
	create_process("/cart/main.lua")

elseif (fstat("/ram/bbs_cart.p64")) then
	-- bbs web player
	create_process("/ram/bbs_cart.p64", {
		sandboxed = true,
		cart_id = stat(101),
	})
else
	-- no cart found
	create_process("/system/misc/nocart.p64")
end



--[[pod_format="raw",created="2023-10-20 06:24:13",modified="2024-10-15 00:19:32",revision=3683,stored="2023-21-29 09:21:19"]]
--[[
	fi: shuffleable stacks dev
]]
include "icon.lua"
include "list.lua"
include "grid.lua"
include "desktop.lua"
include "open.lua"
include "interf.lua"
include "tabcomp.lua"
include "finfo.lua"
include "drop.lua"
include "intention.lua"
-----------------------

function _init()

	
	config = fetch"/appdata/system/filenav.pod" or {}
	on_event("modified:/appdata/system/filenav.pod", function()	
		config = fetch"/appdata/system/filenav.pod" or {}
	end)

--	printh("@@ filenav _init cd env().path: "..tostr(env().path))
	cd(env().path)
	--cd("/desktop") -- dev
	
	push_intention(env().intention or intention, env().intention and env().parent_pid)
	
	poke(0x4000,get(fetch"/system/fonts/lil.font"))
	poke(0x5600,get(fetch"/system/fonts/p8.font"))
	
	window{
		width = 272, height = 160,
		title = intention_window_title or intention_title,
		has_context_menu = true -- mb2 to open app menu // to do: indicate which items are for context menu
	}

	-- mode: list, grid, desktop
	mode = "grid"
	--mode = "desktop"
	
	
	desktop_path = "/desktop"
	if (env().argv and env().argv[1] == "-desktop") then
		mode = "desktop"
		--if (env().desktop_path) desktop_path = env().desktop_path	
		if (env().argv[2]) desktop_path = env().argv[2]
		cd(desktop_path) -- path never changes after this in desktop mode
	end
	
	if (env().argv and env().argv[1]) then
		local ff=env().argv[1]
		if (fstat(ff) == "folder") cd(ff)
	end
	

--[[
	menuitem{
		id = "new_file",
		
		label = "\^:0f19392121213f00 New File",
		
		action = function()
			push_intention("new_file")
		end
	}
	
	menuitem{
		id = "new_folder",
		label = "\^:00387f7f7f7f7f00 New Folder",

		action = function()
			push_intention("new_folder")
		end
	}

	-- Rename File, File Info: added by update_context_menu()
]]	
	
	--printh("===== filenav: "..pwd().." =====")
	
	generate_interface()
end

local back_page = nil
local last_state_str = nil
local last_state_mb

function _draw()

	local t0=stat(1)

	gui:draw_all() 
	

	clip()
	camera()

--[[ to do: preview drop position (need to take drag offset into account, and maybe show group
	if (dragging_files and config.snap_to_grid) then
		local mx,my = mouse()
		mx = 45+((-45 + mx + 33) \ 66) * 66
		my = 16+((-16 + my + 25) \ 50) * 50
		mx = mid(-21,mx,375)
		my = mid(16,my,216)
		circ(mx,my+10,20,10)
	end
]]

	-- fps
	if (false) then
		rectfill(get_display():width()-32,0,10000,12,1)
		print((stat(1)-t0)\0.01,get_display():width()-30,12,8)
	end

--	print(dragging_files ~= nil and "dragging" or "---",2,20,7)

end

local last_poll_t = 0
function _update()

--[[ don't need -- is invoked by app menu shortcut
	if (key"ctrl") then
		if (keyp"i") open_selected_file_info()
	end
--]]

	-- to do: app menu shortcuts?
	if (key"ctrl" and keyp"x") then
		copy_selected_files("cut")
	end
	if (key"ctrl" and keyp"c") then
		copy_selected_files("copy")
	end
	
	if refresh_gui then
		--if (mode != "desktop") -- 0.1.0c: commented ~ generate interface even on desktop (allow file ops)
		generate_interface()
		refresh_gui = false
	end
	
	-- to do: could be every 4 seconds
	-- + update immediately when gaining focus or some file activity detected 
	-- (global timestamp of last change in /ram/system? "modifed:.." event applied to folders?)

	if (time() > last_poll_t + 1.0) then
		update_file_info()
		last_poll_t = time()
	end
	
	--if (not key"shift") 
	gui:update_all()

end

on_event("gained_visibility", function()
	if (mode == "desktop") fetch_desktop_items()
end)
--[[
-- nope ~ too slow
on_event("lost_visibility", function()
	if (mode == "desktop") store_desktop_items()
end)
]]

on_event("filenav_refresh", function()
	-- printh("@@ refreshing filenav **")
	update_file_info(true) -- invalidate cache
	--refresh_gui = true
end)



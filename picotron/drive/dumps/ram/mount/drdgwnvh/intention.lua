--[[pod_format="raw",created="2023-10-05 21:49:51",modified="2024-10-15 00:19:32",revision=1458]]
--[[

	intention.lua
	
	open filenav with intention to perform some operation
	-> changes semantics of double click, and adds intention panel at bottom
		e.g.: Save As ..   [Save]
	
	update: reuse for tasks that never leave filenav (new folder)
]]

--intention = "open" -- debugging

local intention_stack = {}

function push_intention(p0,p1)
	--printh("pushing intention:"..pod{p0,p1})
	add(intention_stack,
		{
			intention,
			intention_requester_proc_id
		}
	)
	init_intention(p0, p1)
	refresh_gui = true
end

function pop_intention()
	local item=deli(intention_stack) or {}
	init_intention(item[1], item[2])
	refresh_gui = true
	
	return item -- never used
end


function init_intention(p0, p1)

	-- can be nill (e.g. pop last intention off stack to remove intention panel)
	intention = p0
	intention_requester_proc_id = p1
	
	intention_dat = {
		save_file_as  = {"Save As", "Save"}, -- "Save File As" doesn't fit
		select_file   = {"Select File", "Select"}, -- similar to save_file_as but general purpose name (up to requester what to do with selected file)
		open_file     = {"Open File", "Open"},
		new_file      = {"New File", "Create"},
		new_folder    = {"New Folder", "mkdir"},
		new_cartridge = {"New Cart", "Create"},
		new_tab       = {"New File", "Create", "New Tab"}, -- can either open a file, or create a file  -->  window title is "New Tab"
		rename        = {"Rename", "Rename"} -- could be file or folder
	}

	if intention and intention_dat[intention] then
		intention_title  = intention_dat[intention][1] -- window title
		intention_action = intention_dat[intention][2] -- button on right
		intention_window_title = intention_dat[intention][3] or intention_title
	end
end

function generate_intention_panel()

	local panel = gui:attach{
		x = 0, y = 0, vjustify = "bottom",
		width_rel = 1.0,
		height = 19,
	}

	function panel:draw()
		rectfill(0,0,self.width-1,self.height-1,6)
		print(intention_title..":",6,6,13)
	end
	
	local wwa = 80
	local xx = -6
	
	if (#intention_stack > 1) then
 		local el = panel:attach_button{
			x = xx, justify = "right", y = 3,
			label = "Cancel",
			bgcol = 0x0707,
			fgcol = 0x0e01,
			tap = function()
				pop_intention()
			end
		}
		xx -= el.width
		xx -= 4
		wwa += el.width+4
	end
	
	local btn1 = panel:attach_button{
		x = xx, justify = "right", y = 3,
		label = intention_action,
		bgcol = 0x0707,
		fgcol = 0x0e01,
		tap = process_intention
	}
	
	wwa += btn1.width
	
	intention_text = panel:attach_text_editor{
		x=64,y=4,
		width=100,
		width_rel = 1.0,
		width_add = - wwa,
		height=12,
		max_lines = 1,	
		key_callback = { 
			enter = process_intention -- same as clicking on the button next to it
		}
	}
	
	intention_text:set_keyboard_focus(true)

	--intention_text:set_text{path}
	--intention_text:click({mx=1000,my=2})
	
end


function process_intention()

	if (not intention_text) return

	local filename = fullpath(intention_text:get_text()[1])

	if (not filename) then
		notify("could not resolve; filenames must contain only a..z,0..9,_-.")
		return
	end
	
	-- printh("process intention: "..pod{intention,filename})
	
	-- safety: can't operate on a folder
	--[[
	if (fstat(filename) == "folder") then
		notify("could not process: "..intention)
		return
	end
	]]
	
	-- new_file is processed by open.lua
	-- ** never processed by requester **
	if (intention == "new_file" or intention == "new_tab") then
		if (not filename:ext() and env().use_ext) filename..="."..env().use_ext
		create_process(env().open_with and env().open_with or "/system/util/open.lua",
			{ argv = {filename} })
		pop_intention()
		return
	end
	
	-- new_folder always internal
	if (intention == "new_folder") then
		mkdir(filename)
		pop_intention()
		return
	end

	if (intention == "new_cartridge") then
		if (not filename:ext()) filename..=".p64"
		mkdir(filename)
		pop_intention()
		return
	end

	if (intention == "rename") then
		-- printh("rename: "..intention_filename.." to: "..filename)
		if (fstat(filename)) then
			notify("can not rename to an existing file")
		else
			if (not filename:ext() and intention_filename:ext()) then
				filename..="."..intention_filename:ext()
			end
			local res = mv(intention_filename, filename)
			if (res) then
				notify("error: "..res)
			elseif (mode == "desktop") then
				copy_desktop_item_attributes(intention_filename:basename(), filename:basename())
			end
		end

		pop_intention()
		return
	end
	
	-- intention came from external requester
	-- e.g. save, save as
	if (intention_requester_proc_id) then
		-- printh("sending intention to: "..intention_requester_proc_id)
		send_message(intention_requester_proc_id, -- env().parent_pid, 
			{event=intention, filename=filename})
		exit()
		return
	end	

end





















































































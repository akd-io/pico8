--[[pod_format="raw",created="2023-10-08 09:24:50",modified="2024-10-16 00:57:09",revision=2981,stored="2023-21-29 09:21:19"]]
--[[
	finfo.lua
	
	collection of file info tables, independent of gui
	indexed by filename; fel (file gui elements) can point at this
]]
-- global
finfo = {}
finfo_version = 0 -- bump each time it changes

function deselect_all()
	for k,v in pairs(finfo) do
		v.selected = false
	end
	update_context_menu()
	finfo_version += 1 -- refresh
end

--[[
	fileview_state
	returns a string encoding the state that drawing the main file view depends on
	when the state doesn't change, the file view (grid / desktop) does not need to be redrawn
	(experimental for 0.1.1c -- saves ~30% cpu when many filenav windows open)
]]
function fileview_state(self)

	local mx,my,mb = mouse()
	if (mb == 0) mx,my = 0,0 -- can ignore mosue position when not pressing
	local ret = {
		--rnd(), -- debug: force refresh
		mode, 
		finfo_version, -- not finfo itself! too expensive
		mx, my, mb, self.last_state_mb,
		theme"icon0",theme"icon1",theme"icon2",theme"icon3",
		self.child[1] and self.child[1].sy or self.sy,
		self.child[1] and self.child[1].sx or self.sx,
		self.width, self.height -- perhaps should be standard, handled in gui.lua (along with scrolling)
	}
	self.last_state_mb = mb

	return pod(ret)
end


-- really means: copy list of file references to clipboard
function copy_selected_files(op)
	local items = {}
	for k,v in pairs(finfo) do
		if (v.selected) then
			v.fullpath = fullpath(v.filename)
			v.op = op
			add(items, v)
		end
	end
	set_clipboard(pod(items,0x7,{pod_type="file_references"}))
	if op == "copy" then
		notify("copied "..#items.." items to clipboard")
	else
		notify("marked "..#items.." items for move")
	end
end


function delete_selected_files()

	mkdir("/ram/compost")
	
	local num = 0
	local err
	for k,v in pairs(finfo) do
		if (v.selected) then
			local fullpath = fullpath(v.filename)
			local res = mv(fullpath, "/ram/compost/"..fullpath:basename())
			if (res) err = res
			num += 1
		end
	end
	if (err) then
		notify("moved "..num.." items to /ram/compost // ** error ** "..err)
	else
		notify("moved "..num.." items to /ram/compost")
	end

	update_file_info(true)

end


-- means "start dragging"
function drag_selected_files(msg)
	
	
	-- skip if already dragging files or haven't moved far enough from initial point
	if (dragging_files) return

	-- 0.1.1d: changed to < 2 from < 3
	if (abs(msg.mx - msg.mx0) < 2 and abs(msg.my - msg.my0) < 3) return


	-- list: relative item positions not set yet. calculate here
	if mode == "list" then
		local mx,my=mouse()
		local num = 0
		for i=1,#fi do
			if (fi[i].finfo.selected) num += 1
		end
		local idx = 0
		for i=1,#fi do
			if (fi[i].finfo.selected) then
				fi[i].finfo.x = mx - 8
				fi[i].finfo.y = my - num*2-2+idx*2 - 4
				idx += 1	
			end
		end
	end


	
	update_context_menu()
	
	dragging_files = {}

	local idx=0

	for k,v in pairs(finfo) do
		if (v.selected) then
			v.fullpath = fullpath(v.filename)
			local mx, my = mouse()
			-- 0.1.0c: set offsets here (wm handles this, but mouse moved by the time message arrives)
			v.xo = v.x and (v.x - mx) or 0
			v.yo = v.y and (v.y - my) or 0
			add(dragging_files, v)
			--printh("added "..v.fullpath..string.format(" %d %d",v.x,v.y))
		end
	end
	
	-------  sort by distance to mouse cursor (grid, desktop)
	local mx, my = mouse()

	for i=1,#dragging_files do
		local v = dragging_files[i]
		v.dist = (v.x - mx)^2 + (v.y - my)^2
		--v.dist = v.xo^2 + v.yo^2
	end

	local tbl = dragging_files
	for pass=1,#tbl do
		for i=1,#tbl-1 do
			if (tbl[i].dist == tbl[i+1].dist and tbl[i].filename > tbl[i+1].filename) or
				tbl[i].dist > tbl[i+1].dist
			then
				tbl[i],tbl[i+1] = tbl[i+1],tbl[i]
			end
		end
	end

		
	if (#dragging_files > 0) then
		-- send a message to window manager
		send_message(3,{
			event = "drag_items",
			items	 = dragging_files
		})
	else
		dragging_files = nil -- cancel; nothing to drag
	end
		
end



function update_file_info(clear)

--	printh("update_file_info..")
	finfo_version += 1

	-- for debugging; clear when interface is regenerated
	-- update: used to update icons via filenav_refresh broadcasted message
	if (clear) then
		finfo = {}
		last_files_pod = nil
		last_index = nil
	end
	
	update_context_menu()
	
	-- fetch current list
	local files = ls(pwd())
	
	-- no change; no need to update
	local files_pod = pod{mode,pwd(),files}
	if (files_pod == last_files_pod) then
		return
	end
	
	last_files_pod = files_pod
	
	filenames = {}

	-- search for added /changed files
	local found = {}
	for i=1,#files do
	
		local filename = files[i]
		found[filename] = true
		if (not finfo[filename]) finfo[filename] = {}
		local f = finfo[filename]
		
		--local attrib, size, mount_desc = "file", 0, nil --fstat(filename)
		local attrib, size, mount_desc = fstat(filename)
		

		-- update / create info
		f.pod_type = "file_reference" -- used by dragging_items
		f.filename = filename
		f.fullpath = fullpath(filename)
		f.selected = f.selected or false
		f.attrib   = f.attrib or attrib
		f.size     = f.size or size
		f.meta     = fetch_metadata(filename) or {}
		f.icon     = get_file_icon(filename, f.meta)
		f.index    = i
		f.is_non_cart_folder = false
	
		-- derive printable filename (has folder icon infront for folders that aren't carts0
		f.filename_printable = f.filename
		
		if (f.attrib == "folder") then
			local ext = f.filename:ext()
			if (ext == "p64" or ext == "p64.png" or ext == "p64.rom") then
				-- cart icon?	
				-- f.filename_printable = "\^:00ff8181ffc17f00 "..f.filename_printable
			else
				f.is_non_cart_folder = true
				f.filename_printable = "\^:00387f7f7f7f7f00 "..f.filename_printable
			end
		end

		add(filenames, f.filename)
	end
	
	
--[[
	-- clear out missing items
	for k,v in pairs(finfo) do
		if (not found[k]) finfo[k] = nil
	end
]]


	-- update gui elements
	if (mode == "grid") generate_fels_grid()
	if (mode == "list") generate_fels_list()
	if (mode == "desktop") generate_fels_desktop()
	
	--printh("========= updated_file_info =========")
	--printh(pod(finfo))

end

function open_selected_file_info()
	for k,v in pairs(finfo) do
		if (v.selected) then
			create_process("/system/apps/about.p64", 
			{
				argv={v.fullpath},
				window_attribs = {workspace = "current", autoclose=true}
			})
		end
	end
end

function update_context_menu()

	local which = nil
	local num_selected = 0
	for k,v in pairs(finfo) do
		if (v.selected) which = v.fullpath  num_selected += 1
	end

	-- clear; need for dynamic menus where it is easier to rebuild from scratch
	menuitem()



	-- special case: unmount host desktop 
	if (num_selected == 1 and which == "/desktop/host") then
		-- to do: handle unmounting in a more general way (when there are more things to mount)
		menuitem{
			id="unmount_host_desktop",	
			label = "Unmount",
			action = function() rm"/desktop/host" end
		}
		return
	end



	-- 0. header // shows main context (what is selected)

	if (num_selected == 0) then
		--[[
		menuitem{
			id="file_info",
			label="Desktop"
		}
		]]
	elseif (num_selected == 1) then
		menuitem{
			id="file_info",	
			label = "About "..which:basename(),
			--label = "\^:1c367f7777361c00 About "..which:basename(),
			--label = "\^:1c367f7777361c00 "..which:basename(),
			shortcut = "Ctrl-I",
			action = function()
				create_process("/system/apps/about.p64", 
					{argv={which}, window_attribs={workspace = "current", autoclose=true}})				
			end
		}
	else
		menuitem{
			id="files_info",
--			label=num_selected.." Items         \f6\^iDeselect",
--			action = function() deselect_all()  sel = nil end
			label=num_selected.." Items",
		}
	end

	-- 1b: view contents of cartridge

	if (num_selected == 1) then
		
		local ext = which:ext()
		if ext == "p64" or ext == "p64.rom" or ext == "p64.png" then -- to do: better way to test for cart; do this a lot

			menuitem{divider=true}

			menuitem{
				id="show_cart_contents",	
				label = "\^:007f41417f613f00 Show Cart Contents",
				action = function()
					create_process("/system/apps/filenav.p64",
					{ 
						argv = {
							fullpath(which), 
							fullpath(which)
						}
					})
				end
			}
			menuitem{
				id="load_cart",	
				label = "\^:007f41417f613f00 Load Cartridge",
				action = function()
					create_process("/system/util/load.lua", { argv = {fullpath(which)} })
				end
			}
		end
	end


	if (num_selected > 0) menuitem{divider=true}

	



	-- 1a. operations on selected files

	if (num_selected > 0) then

		menuitem{
			id="cut_files",	
			label = "\^:0015200120012a00 Cut",
			action = cut_selected_files
		}
		menuitem{
			id="copy_files",	
			label = "\^:0f013d2525243c00 Copy",
			action = copy_selected_files
		}
		menuitem{
			id="delete_file",	
			label = "\^:3e7f5d5d773e2a00 Delete",
			-- label = "\^:3e7f5d5d773e2a00 Move to Compost", -- to do: need icon + compost widget 
			action = delete_selected_files
		}
		
		if num_selected == 1 then
			menuitem{
				id="rename",
				label = "\^:0f193921213f0015 Rename",
				action = function()
					intention_filename = which -- the filename that caused menu item to be added
					push_intention("rename")
				end
			}
		end

		menuitem{divider=true}
	end

	-- 1b. nothing selected -> create new items / paste

	if (num_selected == 0) then

		-- check clipboard

		local p, m = unpod(get_clipboard())	
		if m and m.pod_type == "file_references" and type(p) == "table" then	
			menuitem{
				id = "paste_files",
				label = "\^:1e2d212121213f00 Paste "..#p.." Item"..(#p == 1 and "" or "s"),

				action = function() 
					local mx,my,mb = mouse()
					send_message(pid(), {event="drop_items", 
						items = p,
						dx = 0, dy = 0,
						mx = mx, my = my, -- (drop where the context menu item is!)
						-- hold ctrl / shift to modify drop action (e.g. in filenav means force overwrite)
						-- can use from context menu!
						ctrl = key"ctrl", shift = key"shift", 
					})
				end
			}
			menuitem{divider=true}
		end

		menuitem{
			id = "new_file",
			label = "\^:0f19392121213f00 New File",
			action = function() push_intention("new_file") end
		}
		
		menuitem{
			id = "new_folder",
			label = "\^:00387f7f7f7f7f00 New Folder",
			action = function() push_intention("new_folder") end
		}

		menuitem{
			id = "new_cart",
			label = "\^:007f41417f613f00 New Cartridge",
			action = function() push_intention("new_cartridge") end
		}

		menuitem{divider=true}

	end

	-- 2a: open (same as double-clicking; should be possible to use Picotron without ever double-clicking?)

	--[[
		menuitem{
			id="open_item",	
			label = "\^:00304f4141417f00 Open",
			action = function()
				-- same as clicking
			end
		}
	]]

	

	-- 2c: open host folder (to do: could always add and check origin when opening)

	local kind, size, origin = fstat(pwd())

	if (not origin and kind == "folder") then
		menuitem{
			id="open_host_path",	
			label = "\^:00304f4141417f00 Open Host OS Folder",
			action = function()
				send_message(2, {event="open_host_path", path = pwd(), _delay = 0.25})
			end
		}
	end

	-- 2d. open item in host (how to label this?)

	if (num_selected == 1) then
		kind, size, origin = fstat(which)
		if (kind == "file") then
			menuitem{
				id="open_host_path",	
				label = "\^:0b1b3b033f3f3f00 View in Host OS",

				action = function()
					send_message(2, {event="open_host_path", path = which, _delay = 0.25}) -- delay so that mouse isn't held while new window is opening ._.
				end
			}
		end
	end

	
	-- 2e. mount host desktop
	
	if (num_selected == 0 and not fstat("/desktop/host")) then
		menuitem{
			id="mount_host_desktop",	
			label = "\^:00304f4141417f00 Mount Host Desktop",
			action = function()
				send_message(2, {event="mount_host_desktop"})
			end
		}
	end
	


end


-- this model too complex -- better to take the performance hit and regenerate from scratch each time
function update_context_menu_old()
	
	local which = nil
	local num_selected = 0
	for k,v in pairs(finfo) do
		if (v.selected) which = v.fullpath  num_selected += 1
	end

	if (which) then

		-- printh("update_context_menu: "..which)

		if (num_selected == 1) then
			menuitem{
				id="file_info",	
				label = "\^:1c367f7777361c00 File Info",
				shortcut = "Ctrl-I",
				action = function()
					create_process("/system/apps/about.p64", 
						{argv={which}, window_attribs={workspace = "current", autoclose=true}})				
				end
			}
		end

		menuitem{
			id="delete_file",	
			label = "\^:3e7f5d5d773e2a00 Delete "..num_selected.." File"..(num_selected == 1 and "" or "s"),
			action = delete_selected_files
		}
		
		-- rename 
		if (mode ~= "desktop" and num_selected == 1) then
			menuitem{
				id="rename",
				label = "\^:0f193921213f0015 Rename "..(fstat(which) == "folder" and "Folder" or "File"),
				action = function()
					intention_filename = which -- the filename that caused menu item to be added
					push_intention("rename")
				end
			}
		end

		-- open in host
			
		local kind, size, origin = fstat(which)

		if ((not origin or origin:sub(1,5) == "host:") and num_selected == 1) then
			menuitem{
				id="open_host_path",	
				label = "\^:0b1b3b033f3f3f00 View in Host OS",

				action = function()
					send_message(2, {event="open_host_path", path = which, _delay = 0.25}) -- delay so that mouse isn't held while new window is opening
				end
			}
		else
			-- remove
			menuitem{id="open_host_path"}
		end

	else
		-- no item selected

		-- clear entries
		menuitem{id="file_info"}
		menuitem{id="delete_file"}
		menuitem{id="rename"}

		-- open host folder

		local kind, size, origin = fstat(pwd())

		-- if ((not origin or origin:sub(1,5) ~= "/ram/")) -- testing -- deleteme
		if (not origin) then
			menuitem{
				id="open_host_path",	
				label = "\^:00304f4141417f00 Open Host OS Folder",
				action = function()
					send_message(2, {event="open_host_path", path = pwd(), _delay = 0.25})
				end
			}
		else
			-- remove
			menuitem{id="open_host_path"}
		end

	end
	
end






--[[pod_format="raw",created="2023-10-04 15:13:41",modified="2024-10-15 00:19:32",revision=3163,stored="2023-21-29 09:21:19"]]
-- mode: desktop
local desktop_items = nil
local desktop_content = nil
local sel

-- used when renaming a file
function copy_desktop_item_attributes(src, dest)
	if (not desktop_items[src]) return
	desktop_items[dest] = desktop_items[dest] or {}
	for k,v in pairs(desktop_items[src]) do
		desktop_items[dest][k] = v
	end
	store_desktop_items()
end

function set_desktop_item_position(filename, x, y)
	if (not desktop_items[filename]) desktop_items[filename] = {}

	if (not x or not y) then

		-- find an unused spot

		local used = userdata("u8",48+8,27+8)
		
		for k,item in pairs(desktop_items) do
			if (item.x and item.y) then
				local xx = item.x \ 10
				local yy = item.y \ 10
				used:set(4+xx,4+yy,1)
			end
		end
		
		local inc_x,inc_y = 10, 10

		if (config.snap_to_grid) then
			inc_x = 66
			inc_y = 50
		end

		for xx = -21, 400, inc_x do
				for yy = 16, 230, inc_y do 			
				if used:get(4+xx\10,4+yy\10) == 0 then

					local empty = true
					for dx=-2,2 do
						for dy=-3,2 do
							if (used:get(4+xx\10+dx,4+yy\10+dy) > 0) empty = false
						end
					end

					if empty then
						x = xx y = yy
						goto found_slot
					end
				end
			end
		end

		-- can't find; create a jumbled mess on the left hand side
		x = 40 + rnd(200)
		if (not y) y = 40 + rnd(200)

	end

	::found_slot::

	desktop_items[filename].x = x
	desktop_items[filename].y = y
end
function fetch_desktop_items()
	local meta = fetch_metadata(desktop_path)
	desktop_items = meta and meta.file_item or {}
	--printh("fetched desktop items: "..pod(desktop_items))
end
function store_desktop_items()
	--printh("@@ store_desktop_items: "..pwd())
	
	-- security: only store items that have a matching file.
	-- (when delete a file, don't expect the filename to be kicking around here)
	for k,v in pairs(desktop_items) do
		if (not fstat(k)) desktop_items[k] = nil
		
		-- also: store as ints
		v.x \= 1  v.y \= 1
		
	end
	
	store_metadata(desktop_path, {file_item = desktop_items})
	
end
function shift_selected_desktop_items(dx, dy)

	for i=1,#fi do
		local el2 = fi[i]
		if (el2.finfo.selected) then
			local w2 = el2.width/2
			local h2 = el2.height/2
			
			-- clamp
			
			el2.x = mid(-w2, el2.x + dx, w2 + 480 - el2.width)
			el2.y = mid(-h2, el2.y + dy, h2 + 270 - el2.height)
			
			-- snap to grid
			if (config.snap_to_grid) then
				el2.x = 45+((-45 + el2.x + 33) \ 66) * 66
				el2.y = 20+((-20 + el2.y + 25) \ 50) * 50 -- was 16+,-16 in 0.1.1c
				
				-- add stack group pos to position to preserve stack order
				if (el2.group_pos) then
					el2.x -= el2.group_pos
					el2.y -= el2.group_pos
				end
				
				--printh("dropped at "..el2.x.." "..el2.y)
				el2.x = mid(-21,el2.x,375)
				el2.y = mid(16,el2.y,216)
				
				
				-- when part of a group, offset x,y to preserve stack order
				if (el2.group_id) then
					local g = group[el2.group_id]
					if (#g > 1) then
						
					end
				end
			end

			-- create / update desktop item too

			desktop_items[el2.filename] = desktop_items[el2.filename] or {} -- create new
			local di = desktop_items[el2.filename]	
			di.x = el2.x
			di.y = el2.y
			
		end
	end
	
	store_desktop_items()
	update_desktop_groups()
end

local function create_file_item(parent, ff, x, y)
	if (not ff or not ff.filename) return
	local filename = ff.filename
	
	desktop_items[filename] = desktop_items[filename] or {}
	
	local el = {
		x=x,y=y,
		width=128, height=42, -- desktop items can be quite wide
		finfo    = ff,
		filename = ff.filename,
		-- cursor = 5 -- needs to be consistent with grid view
	}
	
	function el:update(msg)
		
		local mx,my = mouse()
		
		local dx,dy = mx - (self.sx+self.width/2), my - (self.sy+self.height/2)

		-- reset auto-open mechanism
		if (not dragging_files) then
			self.opened_while_dragging_files = false
			self.hover_counter = 0
			return
		end
		
		-- auto-open when not selected and dragging files overhead
		if not self.finfo.selected and 
			dx*dx+dy*dy<256 and 
			not self.opened_while_dragging_files
		then
			self.hover_counter = self.hover_counter or 0
			self.hover_counter += 1
			if (msg.dx ~= 0 or msg.dy ~= 0) self.hover_counter \= 2 -- hold without moving but can recover 
			if self.finfo.attrib == "folder" and self.hover_counter > 60 then -- hold for a second. accidental opens are annoying
				local ext = self.finfo.filename:ext()
				if ext ~= "p64.png" and ext ~= "p64" and ext ~= "p64.rom" then -- don't auto-open cart files
					self.opened_while_dragging_files = true
					create_process("/system/apps/filenav.p64",
					{
						argv = {el.finfo.fullpath}, 
						window_attribs={
							give_focus = true,
							x = max(-2, mx - 80), -- position window under cursor
							y = max(-2, my - 40)  -- ready to catch file
						}
					})
				end
			end
		else
			self.hover_counter = 0
		end
	end
	
	function el:drag(msg)
		drag_selected_files(msg)
	end
	
	function el:release(msg)
		dragging_files = nil
	end

	function el:hover(msg)
		-- keep drawing while over an item
		if (msg.dx~=0 or msg.dy~=0) finfo_version += 1
	end

	
	function el:test_point(x, y)
		
		local ll = el.last_label_area
		if (not ll) return true
		
		-- sprite pixel is set, or inside filename label
		return get(self.finfo.icon, x - ll[5], y - ll[6]) > 0
			or (x >= ll[1] and y >= ll[2] and x <= ll[3] and y <= ll[4])
	end
	
	
	function el:draw(msg)
		clip() -- allow desktop items to be drawn any size (e.g. super long filenames)

		--rect(0,0,self.width-1,self.height-1,2) -- debug: show width
		pal()
		local sprx, spry = self.width/2 - 8, 6
		local sprx0, spry0 = sprx, spry
		
		--local dx,dy = msg.mx - (self.sx+self.width/2), msg.my - (self.sy+self.height/2)
		--if (dx*dx+dy*dy<256) circfill(self.width/2,self.height/2,16,13)
	
		-- determine if under a pile of items
		local g=group[self.group_id]
		local buried = self.finfo.filename ~= g[#g].filename
		
		if (self.finfo.selected)  then
		
			-- shadow colour
			local shadow_col = theme"desktop_shadow"
			pal(7,shadow_col) pal(6,shadow_col) pal(13,shadow_col) pal(1,shadow_col) 
			--fillp(0xf0f0)
			if (#g==1) spr(self.finfo.icon,sprx,spry)
			pal()fillp()
			sprx += 1
			spry -= 1
			
			-- invert
			-- pal(7,1) pal(1,7)
			--rectfill(0,0,self.width-1,self.height-1,10)
		end
		
		-- pop up 1px on hover (but not for label hover)
		-- bump finfo_version to redraw
		if (msg.has_pointer and msg.my < 24) spry -= 1 finfo_version += 1
		
		-- apply shuffle_t -- bump finfo_version so that it keeps animating
		sprx += self.shuffle_t * self.shuffle_spacing
		spry += self.shuffle_t * self.shuffle_spacing
		if (self.shuffle_t < 0) self.shuffle_t = min(0, self.shuffle_t+0.1) finfo_version += 1
		if (self.shuffle_t > 0) self.shuffle_t = max(0, self.shuffle_t-0.1) finfo_version += 1
		
	
		
		if (not dragging_files or not self.finfo.selected) then
			
			if (buried) then
				pal(7, theme"icon1")
				pal(6,theme"icon2")
				pal(13, theme"icon3")
				pal(1, theme"icon3")
			else
				pal(7, theme"icon0")
				pal(6,theme"icon1")
				pal(13, theme"icon2")
				pal(1, theme"icon3")
			end
			
			
			spr(self.finfo.icon,sprx,spry)
		end
		
		pal()
		
		--local str = "\014"..self.filename
		poke(0x5f36, 0x80) -- turn on wrap to clip_right
		
		local str = self.filename
		
		local ww,hh = print(str, 0, -1000000)
		hh += 1000000

--		ww = min(ww, self.width-8) -- don't clip left text, only right
		
		local w2 = self.width / 2
		local yy = 30
		
		if (not buried) then
			color(self.finfo.selected and 1 or 7)
			
			rectfill(w2-ww/2-5,yy-4,w2+ww/2+3,yy+hh-1) 
			rectfill(w2-ww/2-6,yy-3,w2+ww/2+4,yy+hh-2)
			
			print(str, w2 - ww / 2, yy, self.finfo.selected and 7 or 13)
		end
		
		-- for test_point
		if (buried) then
			-- test only icon, not label
			el.last_label_area = {1000,0,1000,0,sprx0,spry0}
		else
			el.last_label_area = {w2-ww/2-5,yy-4,w2+ww/2+3,yy+hh-1,sprx0,spry0}
		end
		
		-- for dragging file icons
		self.finfo.x = sprx + self.sx
		self.finfo.y = spry + self.sy 

		-- pset(sprx, spry, rnd(32)) -- debug: show when redraw is happening
		
	end
	
	function el:click()
		
		-- adjust z for all items in group, and bring all to front
		if self.group_id then
			local g=group[self.group_id]
			for i=1,#g do
				g[i].z = top_z
				g[i]:bring_to_front()
			end
			top_z += 1
		else
			-- doesn't happen; always group of 1
			self:bring_to_front()
		end
		
		if (key("ctrl")) then
			self.finfo.selected = not self.finfo.selected
		else
			-- if wasn't already selected, deselect everything else
			if (not self.finfo.selected) deselect_all()  sel = nil
			-- .. but either way, this one is going to be selected
			self.finfo.selected = true
		end

		update_context_menu()

		return true
	end

	function el:tap(msg)
		-- unselect all but current item (need to preserve selection on click for dragging / context menu)
		if not key"ctrl" and not key"shift" and msg.last_mb == 1 then
			deselect_all()
			self.finfo.selected = true
		end
	end
	
	-- shuffle pile
	function el:mousewheel(msg)

		if (not self.group_id) return
		local g = group[self.group_id]
		if (#g < 2) return
		if (msg.wheel_y < 0) then
			local x0, y0 = desktop_items[g[1].filename].x,desktop_items[g[1].filename].y
			for i=1,#g-1 do
				desktop_items[g[i].filename].x,desktop_items[g[i].filename].y =
					desktop_items[g[i+1].filename].x,desktop_items[g[i+1].filename].y
			end
			desktop_items[g[#g].filename].x = x0
			desktop_items[g[#g].filename].y = y0
		end
		if (msg.wheel_y > 0) then
			local x0, y0 = desktop_items[g[#g].filename].x,desktop_items[g[#g].filename].y
			for i=#g-1,1,-1 do
				desktop_items[g[i+1].filename].x,desktop_items[g[i+1].filename].y =
					desktop_items[g[i].filename].x,desktop_items[g[i].filename].y
			end
			desktop_items[g[1].filename].x = x0
			desktop_items[g[1].filename].y = y0
		end
		
		-- sync gui element positions and set transition animation
		for i=1,#fi do
			fi[i].x = desktop_items[fi[i].filename].x
			fi[i].y = desktop_items[fi[i].filename].y
			if(fi[i].group_id == self.group_id) then
				fi[i].shuffle_t = sgn(msg.wheel_y)
				fi[i].shuffle_spacing = mid(1, 20\#group[self.group_id], 3)
			end
		end
		-- rebuild groups from desktop items
		store_desktop_items()
		update_desktop_groups()
	end
	
	
	function el:doubleclick()
		click_on_file(self.filename)
	end
	
	return el
end

function sort_file_items_by_y()

	for pass=1,#fi do
		for i=2,#fi do
			local fn0=fi[i].filename
			local fn1=fi[i-1].filename
			
			if(desktop_items[fn0].y < desktop_items[fn1].y) then
				fi[i],fi[i-1]=fi[i-1],fi[i]
			end
		end
	end
	
end

function update_desktop_groups()
	
	sort_file_items_by_y()
	
	--desktop_content.child = {}
	

	group={}
	-- clear
	for i=1,#fi do
		fi[i].group_id = nil
	end

	local group_id = 1

	for i=1,#fi do
		local list = fi -- to do: occupancy grid
		local found_group_id = nil
		for j=1,#list do
			if list[j]~=fi[i] and list[j].group_id then
				local dx = list[j].x - fi[i].x
				local dy = list[j].y - fi[i].y
				if (dx*dx+dy*dy<12*12) then
					found_group_id = list[j].group_id
					--printh("found group_id: "..found_group_id)
				end
			end
		end
		if (found_group_id) then
			fi[i].z = #group[found_group_id]
			add(group[found_group_id], fi[i])
			fi[i].group_id = found_group_id
		else
			-- start new group
			group[group_id] = {fi[i]}
			fi[i].group_id  = group_id
			group_id+=1
		end
	end
	
	-- organise buried item positions: 3px apart
	for i=1,#group do
		local g=group[i]
		-- use second to last (2nd from top) so that stack doesn't just around
		-- adding a new item on front (common)
		local anchor = mid(1,#g-1,#g) -- was #g\2
		local spacing = mid(1, 20\#g, 3)
		local x = g[anchor].x
		local y = g[anchor].y
		
		for j=1,#g do
			g[j].x = x - (anchor-j)*spacing
			g[j].y = y - (anchor-j)*spacing
			-- gather actual items to same point
			-- means stack won't get broken when removing middle item
			-- and creates more consistent collision with pile (e.g. when inserting)
			desktop_items[g[j].filename].x = g[j].x
			desktop_items[g[j].filename].y = g[j].y
			
			-- used for preserving order when snapping to grid
			g[j].group_pos = (anchor-j)*spacing
			 -- snap to grid: make sure goes on top
			if (config.snap_to_grid and #g == 0) g[j].group_pos = -3
			
		end
	end

	finfo_version += 1 -- redraw
end

function generate_fels_desktop()
	fi = {}
	
	-- load item info on first generate
	if (not desktop_items) then
		fetch_desktop_items()
	end
	-- attach to content incase want to have scrollable desktop files later (?)
	-- start at 12 to make space for titlebar

	local put_x = -21
	local put_y = 16
	
	for i=1,#filenames do
	
		-- start at random position
		if (desktop_items[filenames[i]] == nil) then

			set_desktop_item_position(filenames[i], nil, nil)
			
			-- temporary hack for default desktop items
			local fn = filenames[i]
			if (fn:basename() == "drive.loc" or fn:basename() == "readme.txt") 
			then
				desktop_items[filenames[i]].x = put_x
				desktop_items[filenames[i]].y = put_y		
				put_y += 50
				if (put_y > 230) put_y = 16 put_x += 66
			end
		end
		
		local desktop_item = desktop_items[filenames[i]]
		fi[i] = create_file_item(gui, finfo[filenames[i]], 
			desktop_item.x,
			desktop_item.y)
	end
	
	sort_file_items_by_y()

	-- attach everything
	desktop_content.child = {}
	for i=1,#fi do
		fi[i].cursor = "pointer"
		fi[i].shuffle_t = 0
		fi[i].shuffle_spacing = 0
		desktop_content:attach(fi[i])
	end
	-- fi should be the same list (is sorted by y by update_desktop_groups)
	-- (now with drecorations added by :attach)
	fi = desktop_content.child
	
	update_desktop_groups()
	
end
-- only called once on startup -- don't need to be adaptive
function generate_interface_desktop(y0, add_height)
	
	local item_w = 68
	local item_h = 42
	local items_x = get_display():width() \ item_w
		
	local container = gui:attach{
		x=0, y=y0,
		width_rel  = 1.0,
		height_rel = 1.0,
		height_add = -y0 + add_height,
		draw_dependency = fileview_state 
	}
	-- add to gui; use regular unoptimised gui scheme
	-- (could add buckets later or backpage caching, but probably unnecessary)
	content = container:attach{
		x=0,y=0,width_rel=1.0,height_rel=1.0,
		clip_to_parent = true,
		draw_dependency = fileview_state -- why doesn't this work in the container like grid / list modes?
	}
	
	desktop_content = content
	
	local function fi_for_xy(x, y)
		-- early reject by reading drawn state
		if (pget(x,y) == 0) return
		local el = gui:el_at_xy(x,y)
		if (el and el.test_point) return el -- .test_point means is a file el
	end
	
	function content:click(msg)
		if (not key"ctrl") deselect_all()
		sel = {msg.mx, msg.my}
	end
	
	-- copy pasted from grid.lua
	-- fudged step size because test_point is slow (via gui:el_at_xy)
	-- to do: more sensible collision calculation
	function content:drag(msg)
		if (sel) then
			if (abs(msg.mx-sel[1]) > 4 or abs(msg.my-sel[2]) > 4) then
				sel[3],sel[4] = msg.mx, msg.my -- relative to gui element
				-- update selection
				if (not key"ctrl") deselect_all()
				local xx0 = min(sel[1],sel[3])
				local xx1 = max(sel[1],sel[3])
				local yy0 = min(sel[2],sel[4])
				local yy1 = max(sel[2],sel[4])

				for i=1, #fi do
					local item = fi[i]

					local uu0 = mid(xx0, item.x, xx1)
					local vv0 = mid(yy0, item.y, yy1)
					local uu1 = mid(xx0, uu0 + item.width, xx1)
					local vv1 = mid(yy0, vv0 + item.height, yy1)
					
					for y = vv0, vv1, 4 do
						for x = uu0, uu1, 4 do
							if (item:test_point(x - item.x, y - item.y)) item.finfo.selected = true
						end
					end

				end

			else
				sel[3],sel[4] = nil,nil
			end
			
		end
	end
	
	function content:release()
		sel = nil
	end
	
	-- drawn first -- maybe need separate layer in container
	-- to draw selection
	
	function content:draw()
		cls()
		poke(0x547d,0xff) -- wm draw mask; interact mask is still 0
	end
	
--[[
	function content:draw2()
		if (sel and #sel == 4) then
				rect(sel[1],sel[2],sel[3],sel[4], 7)
				rect(sel[1]+1,sel[2]+1,sel[3]-1,sel[4]-1, 1)
			end
	end
]]
	-- draw selection on top
	container:attach{
		x=0,y=0,width_rel=1.0,height_rel=1.0,
		ghost = true,
		draw = function()
			--clip()
			if (sel and #sel == 4) then
				rect(sel[1],sel[2],sel[3],sel[4], 7)
				rect(sel[1]+1,sel[2]+1,sel[3]-1,sel[4]-1, 1)
			end
		end
	}
	update_file_info(true)
end


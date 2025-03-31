--[[pod_format="raw",created="2023-10-20 06:27:59",modified="2024-10-15 00:19:32",revision=3081,stored="2023-21-29 09:21:19"]]
-- mode: icons on a grid (default folder view; is cutest for < ~100 files)
local sel = nil
local function create_file_item(parent, ff, x, y)
	if (not ff or not ff.filename) return
	local el = {
		x = x, y = y,
		width=64, height=46,
		finfo    =  ff,
		filename = ff.filename,
		parent = parent,
	}
	function el:drag(msg)
		drag_selected_files(msg)
	end
	function el:release(msg)
		dragging_files = nil
	end
	
	
	-- need to test in custom click event below
	function el:test_point(x, y)
		
		local ll = el.last_label_area
		if (not ll) return true
		
		-- sprite pixel is set, or inside filename label
		return get(self.finfo.icon, x - ll[5], y - ll[6]) > 0
			or ll and x >= ll[1] and y >= ll[2] and x <= ll[3] and y <= ll[4]	
	end
	
	-- draw icon on grid
	function el:draw()

		clip()
		
		local sprx, spry = self.width/2 - 8, 6
		local sprx0, spry0 = sprx, spry
		
		-- shadow; helps with white outline on white (when inverted)
		pal(1,6) pal(13,6) pal(7,6)
		if (self.finfo.selected) then
			 -- pop up and show shadow. that works!
			 spr(self.finfo.icon,sprx,spry)
			 sprx += 2
			 spry -= 1
		end
		pal()
		
		-- none of these solve the white-on-white problem well;
		-- use pop-up for now. kinda cute and suggests mobility
		--[[
		if (self.finfo.selected) then
			-- invert only col0, col2. needs shadows when on white (folder)
			--pal(7,1) pal(1,7)
			
			-- rotate? nah
			--pal(1,13) pal(13,7) pal(7,1)
			
			-- rectangle: too much, but kinda interesting
			--rectfill(0,2,self.width-1,self.height-3,6)
		end
		]]
		
		if (not dragging_files or not self.finfo.selected) then
			pal(7, theme"icon0")
			pal(6,theme"icon1")
			pal(13, theme"icon2")
			pal(1, theme"icon3")
			
			spr(self.finfo.icon,sprx,spry)
		end
		
		pal()
		
		--local str = "\014"..self.filename
		poke(0x5f36, 0x80) -- turn on wrap to clip_right
		
		local str = self.filename
		
		local ww,hh = print(str, 0, -1000000)
		hh += 1000000
		
		--ww = min(ww, self.width) -- don't clip left text, only right

		local dx = min(ww, self.width) / 2


		local w2 = self.width/2
		local yy = 28
		
		color(self.finfo.selected and 1 or 7)
		rectfill(w2-dx-5,yy-4,w2-dx+ww+3,yy+hh-1) 
		rectfill(w2-dx-6,yy-3,w2-dx+ww+4,yy+hh-2)
		
		print(str, w2 - dx, yy, self.finfo.selected and 7 or 13)
		
		-- for test_point
		self.last_label_area = {w2-dx-5,yy-4,w2-dx+ww+3,yy+hh-1,sprx0,spry0}
		
		-- for dragging file icons; self.sx,sy isn't set
		self.finfo.x = sprx + self.x + self.parent.sx
		self.finfo.y = spry + self.y + self.parent.sy
			
		
	end
	
	function el:click()
		if (key("ctrl")) then
			self.finfo.selected = not self.finfo.selected
		elseif key"shift" and last_index then
			-- select range
			local i0,i1 = last_index, self.finfo.index
			if (i0 > i1) i0,i1=i1,i0
			for i=i0,i1 do
				finfo[filenames[i]].selected = true
			end
		else
			-- if wasn't already selected, deselect everything else
			if (not self.finfo.selected) then 
				deselect_all()  sel = nil
				-- set file navigator text
				navtext:set_text{fullpath(el.filename)}
			end
			-- .. but either way, this one is going to be selected
			self.finfo.selected = true
			last_index = self.finfo.index
		end	

		update_context_menu()

		if intention == "save_file_as" or intention == "select_file" then
			-- set text
			intention_text:set_text({el.filename})
			navtext:set_text{""}
		end
	end

	function el:tap(msg)
		-- unselect all but current item (need to preserve selection on click for dragging / context menu)
		if not key"ctrl" and not key"shift" and msg.last_mb == 1 then
			deselect_all()
			self.finfo.selected = true
		end
		update_context_menu() -- need to again for app menu
	end

	function el:doubleclick()
		click_on_file(self.filename)
	end
	
	return el
end
function generate_fels_grid()
	-- handle file items layer of gui manually so can optimise
	-- (e.g. only draw / update visible items)
		
	local xx,yy = 0,0
	local item_w = 68
	local item_h = 46
	-- to do: should be parent
	local items_x = get_display():width() \ item_w
	
	fi = {}
	
	for i=1,#filenames do
		-- to do: auto-stagger for long file names? + (xx&1)*16
		--add(fi, create_file_item(content, finfo[filenames[i]], 2 + xx*item_w, 2 + yy*item_h + (xx&1)*16))
		add(fi, create_file_item(content, finfo[filenames[i]], 2 + xx*item_w, 2 + yy*item_h))
		xx+=1
		if (xx >= items_x) xx=0 yy+=1
	end
end


function generate_interface_grid(y0, add_height)
	update_file_info()
--	printh("@@ generating grid interface")
	local pointer_el = nil
	local item_w = 68
	local item_h = 46
	local items_x = 3
	local last_items_x
	
	-- attribute headers
	-- click for sorting by that attribute
	
	-- location is in window title!
	local container = gui:attach{
		x=0,y=y0,
		width_rel = 1.0,
		height_rel = 1.0,
		height_add = -y0 + add_height,
		
		update = function(self)
			--  re-calculate item positions on change
			items_x = self.width \ item_w
			if (items_x ~= last_items_x) then
				generate_fels_grid(finfo)
				last_items_x = items_x
			end
		end,
		
		-- needs to exist for clipping ._.
		draw = function(self)
		end,

		draw_dependency = fileview_state
	}
	content = container:attach{
		x=0,y=0,
		width_rel=1.0,
		height=((#filenames + items_x - 1) \ items_x) * item_h,
		clip_to_parent = true
	}
	
	function content:clamp_scrolling()
		local max_y = max(0, content.height - container.height)
		content.y = mid(0, content.y, -max_y)
		content.x = min(0, content.x)
	end
	
	local function fi_for_xy(x, y)
		local item_x = x \ item_w
		local item_y = y \ item_h
		local index = 1 + item_x + item_y * items_x
		return fi[flr(index)]
	end
	function content:update()
		content:clamp_scrolling()
		
		-- update pointer element
		local mx,my,mb = mouse()
		
		if (self.sx) pointer_el = fi_for_xy(mx - self.sx, my - self.sy)
		
		-- test point
		if (pointer_el and pointer_el.parent) then
		
			pointer_el.sx = pointer_el.x + pointer_el.parent.sx
			pointer_el.sy = pointer_el.y + pointer_el.parent.sy
			
			
			pointer_el = pointer_el:test_point(mx - pointer_el.sx, my - pointer_el.sy)
				and pointer_el or nil
		end

		-- to do: better way to handle this?
		if (pointer_el) then
			window{cursor = "pointer"}
		else
			window{cursor = 1}
		end
		
		self.height=((#filenames + items_x - 1) \ items_x) * item_h
		self.height=max(self.height, self.parent.height) -- allow select from dead space
	end
	-- 
		
	-- draw grid view
	function content:draw()
		rectfill(0,0,1000,self.height,7)

		if (#fi == 0) return
	
		--local mini = mid(1, (-content.y                   ) \ item_h + 1, #fi)
		--local maxi = mid(1, (-content.y + container.height) \ item_h + 1, #fi)
		
		-- to do: calculate
		local mini = 1
		local maxi = #fi
		
		for i=mini,maxi do
			
			local ff = fi[i]
			local sx = ff.x + content.x \ 1 + container.x 
			local sy = ff.y + content.y \ 1 + container.y 
		
			camera(-sx, -sy)
			
			-- clipping hack: don't draw over toolbar at top
			--clip(sx, max(sy, container.y), ff.width, ff.height)
			ff:draw()
		end
		
		--clip()
		
		-- draw selection
		camera(-self.sx, -self.sy)
		
		if (sel and #sel == 4) then
			rect(sel[1],sel[2],sel[3],sel[4], 7)
			rect(sel[1]+1,sel[2]+1,sel[3]-1,sel[4]-1, 1)
		end
		
	end
	
	-- forward messages
	-- to do: allow subscribe_to_events at gui element level?
	
	function content:click(msg)
		if (pointer_el) then
			pointer_el:click(msg)
		else
			if (not key"ctrl") deselect_all()
			sel = {msg.mx, msg.my} -- relative to gui element
		end
	end

	function content:tap(msg)
		if (pointer_el and pointer_el.tap) pointer_el:tap(msg)
	end

	function content:drag(msg)
	
		-- dragging a file
		if (pointer_el and pointer_el.finfo and pointer_el.drag and
			not sel) then
			pointer_el:drag(msg)
		end
		
		if (sel) then
			if (abs(msg.mx-sel[1]) > 2 or abs(msg.my-sel[2]) > 2) then
				sel[3],sel[4] = msg.mx, msg.my -- relative to gui element
				-- update selection
				if (not key"ctrl") deselect_all()
				local xx0 = min(sel[1],sel[3])
				local xx1 = max(sel[1],sel[3])
				local yy0 = min(sel[2],sel[4])
				local yy1 = max(sel[2],sel[4])

				-- to do: only need to test the visible ones
				for i=1, #fi do
					local item = fi[i]

					local uu0 = mid(xx0, item.x, xx1)
					local vv0 = mid(yy0, item.y, yy1)
					local uu1 = mid(xx0, uu0 + item.width, xx1)
					local vv1 = mid(yy0, vv0 + item.height, yy1)
					
					for y = vv0, vv1-1, 4 do
						for x = uu0, uu1-1, 4 do
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
		dragging_files = nil -- to do: drop
	end
	
	
	function content:doubleclick(...)
		if (pointer_el) pointer_el:doubleclick(...)
	end

	
	
	
	update_file_info(true)
	container:attach_scrollbars{autohide=true}
	
end



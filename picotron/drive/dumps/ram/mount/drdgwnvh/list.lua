--[[pod_format="raw",created="2023-10-20 06:27:42",modified="2024-10-15 00:19:32",revision=3432,stored="2023-21-29 09:21:19"]]
-- mode: list
local item_h = 12
local function create_file_item(parent, ff, x, y)
	if (not ff or not ff.filename) return
	local el = {
		x = x, y = y, width=480,
		width_rel = 1.0, height=12,
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

	-- from grid version
	function el:update(msg)
		-- reset auto-open mechanism
		if (not dragging_files) then
			self.opened_while_dragging_files = false
			self.hover_counter = 0
			return
		end
		-- to do: hover logic
	end

	
	function el:draw()
		if (self.finfo.selected) then
			rectfill(0,0,self.width-1,self.height-1,10)
		end
		
		line(0,self.height-1,self.width-1,self.height-1,6)

		print(self.finfo.filename_printable,4,2,1)
		
		if (not self.finfo.is_non_cart_folder) print(string.format("%6d",self.finfo.size),140,2,1)
		
		if (self.finfo.meta.modified) print(self.finfo.meta.modified:sub(1,10), 200, 2,1)
	
		-- for dragging file icons
		--[[
			self.finfo.x = self.x + self.parent.sx
			self.finfo.y = self.y + self.parent.sy
			local mx,my = mouse()
			self.finfo.y = my + (self.finfo.y - my) / 4 -- scrunch up
		]]
	end
	
	function el:click()
		if (key("ctrl")) then
			self.finfo.selected = not self.finfo.selected
		elseif key"shift" and last_index then
			-- select range
			local i0,i1 = last_index, self.finfo.index
			--printh("selecting range "..pod{i0,i1})
			if (i0 > i1) i0,i1=i1,i0
			for i=i0,i1 do
				finfo[filenames[i]].selected = true
			end
		else
			if (not self.finfo.selected) then
				deselect_all()
			end
			self.finfo.selected = true
			last_index = self.finfo.index
			-- set
			navtext:set_text{fullpath(el.filename)}
		end	

		update_context_menu()

		if intention == "save_file_as" then
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
	end

	function el:doubleclick()
		click_on_file(self.filename)
	end
	
	return el
end
function generate_fels_list()
	-- handle file items layer of gui manually so can optimise
	-- (e.g. only draw / update visible items)
		
	local xx,yy = 0,0
	local item_w = 68
	-- to do: should be parent
	local items_x = get_display():width() \ item_w
	
	fi = {}
	
	for i=1,#filenames do
		add(fi, create_file_item(content, finfo[filenames[i]], 0, (i-1)*item_h))
	end
end
function generate_interface_list(y0, add_height)
	update_file_info()
	
	local pointer_el = nil
	
	
	-- location is in window title!
	local container = gui:attach{
		x=0,y=y0+12,
		width_rel = 1.0,
		height_rel = 1.0,
		height_add = -(y0+12) + add_height,
		draw_dependency = fileview_state
	}

	function container:draw()
		rectfill(0,0,1000,self.height,7)
	end

	content = container:attach{
		x=0,y=0,
		width_rel=1.0,
		height=#filenames * item_h,
		clip_to_parent = true
	}

	-- attribute headers
	-- to do: click for sorting by that attribute
	
	gui:attach{
		x=0,y=y0,width_rel=1.0,height=12,
		width = 100,
		draw=function(self)
			rectfill(0,0,self.width-1,self.height-1, 6)
			print("filename", 4, 2, 13)
			print("size", 151,2,13) -- right-justified becaues values are right-justified
			print("modified",211,2,13) -- right-justified to match size; values are always same width so free to choose justification
		end
	}
	
	--------
	
	function content:clamp_scrolling()
		local max_y = max(0, content.height - container.height)
		content.y = mid(0, content.y, -max_y)
		content.x = min(0, content.x)
	end
	function content:update()

		-- +20 so that there is blank space at the bottom; shows end of list and can click to deselect after selecting all
		self.height = max(self.parent.height, #filenames * item_h + 20) 
		
		content:clamp_scrolling()
		
		-- update pointer element
		local mx,my,mb = mouse()
		local index = 1 + (my - self.sy) \ item_h
		pointer_el = fi[flr(index)]
		
		-- set cursor
		window{cursor = pointer_el and "pointer" or 1}
		
	end
	-- 
			
	function content:draw()
		
		if (#fi == 0) return
	
		local mini = mid(1, (-content.y                   ) \ item_h + 1, #fi)
		local maxi = mid(1, (-content.y + container.height) \ item_h + 1, #fi)
		for i=mini,maxi do
			
			local ff = fi[i]
			local sx = ff.x + content.x \ 1 + container.x 
			local sy = ff.y + content.y \ 1 + container.y 
		
			camera(-sx, -sy)
			
			-- clipping hack: don't draw over toolbar or column headers at top
			clip(sx, max(sy, container.y), ff.width, ff.height)
			ff:draw()
		end
		
		clip()
	end
	
	-- forward messages (list view)
	-- to do: allow subscribe_to_events at gui element level?
	
--[[
	function content:click(...)
		pointer_el:click(...)
	end
]]

	function content:tap(msg)
		if (pointer_el and pointer_el.tap) pointer_el:tap(msg)
	end

	function content:click(msg)
		if (pointer_el) then
			pointer_el:click(msg)
		else
			if (not key"ctrl") deselect_all()
			sel = {msg.mx, msg.my} -- relative to gui element
		end
	end

	function content:release()
		sel = nil
		dragging_files = nil
	end

	function content:doubleclick(...)
		pointer_el:doubleclick(...)
	end

	function content:drag(msg)
	
		-- dragging a file
		if (pointer_el and pointer_el.finfo and pointer_el.drag and
			not sel) then
			pointer_el:drag(msg)
		end

		-- (no drag to select in list view)
	end
	
	update_file_info(true)
	container:attach_scrollbars{autohide=true}
	
end




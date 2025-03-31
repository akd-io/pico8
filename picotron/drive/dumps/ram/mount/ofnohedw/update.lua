--[[pod_format="raw",created="2023-10-10 07:45:26",modified="2024-08-18 16:06:41",revision=3663,stored="2023-24-28 00:24:00"]]
	
	function get_selected_rect()
		local x0,y0 = 10000, 10000
		local x1,y1 = 0,0
		for y = 0, cbmp_height-1 do
			for x = 0, cbmp_width-1 do
				if (get(csel, x, y) > 0) then
					x0 = min(x0, x) y0 = min(y0, y)
					x1 = max(x1, x) y1 = max(y1, y)
				end 
			end
		end
		if (x0 == 10000) x0,y0,x1,y1 = 0, 0, cbmp_width-1, cbmp_height-1
		
		return x0, y0, x1-x0+1, y1-y0+1
	end
	
	
	function copy_selected_rect()
		local x0, y0, ww, hh = get_selected_rect()
		local out = userdata("u8", ww, hh)
		--printh(pod{x0,y0, ww,hh})
		blit(cbmp, out, x0, y0, 0, 0)
		return out
	end
	
	
	function rotate_selection(dx, dy)
		local x,y = 0, 0
		local bmp2 = cbmp:copy()
		local w,h = bmp2:attribs()
		set_draw_target(cbmp)
		
		clip(x,y,w,h)
		rectfill(x,y,x+w-1,y+h-1,0)
		for yy=-1,1 do
			for xx=-1,1 do
				spr(bmp2,dx+x+xx*w,dy+y+yy*h)
			end
		end
				
		clip()
		set_draw_target()
	end
	
	function move_selection(dx, dy)
		
		backup_state()
		
		if (not ci.layer) return rotate_selection(dx, dy)
		
		blit(ci.layer0, cbmp)
		ci.layer_x += dx
		ci.layer_y += dy
		blit(ci.layer, cbmp, 0, 0, ci.layer_x, ci.layer_y)
		
		-- new selection
		csel:clear()
		local ww, hh = ci.layer:attribs()
		set_draw_target(csel)
		rectfill(ci.layer_x, ci.layer_y, ci.layer_x + ww-1, ci.layer_y + hh-1, 1)
		csel_outline = nil -- regenerate
		set_draw_target()
	end
	
	 
	function clear_selection()
		if (csel) csel:clear()
		csel_outline = nil -- refresh
		ci.layer, ci.back = nil, nil -- what is ci.back? to do: delete if not used
	end
	
	function select_all()
		backup_state()
		csel:copy(1,true)
		csel_outline = nil -- regenerate	
		local ww,hh = cbmp_width,cbmp_height
		ci.layer = userdata("u8",ww,hh)
		ci.layer_x = 0
		ci.layer_y = 0
		ci.layer0 = cbmp:copy()
		blit(cbmp,ci.layer)
	end
	
	
	function modify_selection(op)
		backup_state()
		
		local tbmp = ci.layer or cbmp
		local orig = tbmp:copy()
		
		if (op == "flip_x") then
			for x=0, tbmp:width()-1 do
				blit(orig,tbmp,x,0,tbmp:width()-1-x,0,1,tbmp:height())
			end
			
		end
		
		if (op == "flip_y") then
			for y=0, tbmp:height()-1 do
				blit(orig,tbmp,0,y,0,tbmp:height()-1-y,tbmp:width(),1)
			end
		end
		
		-- layer only -- don't clear whole map with del
		if (ci.layer and op == "clear") then
			ci.layer:clear()
		end
		
		-- update changes
		if (ci.layer) blit(ci.layer, cbmp, 0, 0, ci.layer_x, ci.layer_y)
	end
	
	function get_region_indexes(r)
		local out={}
		for y = r.y,r.y+r.h-1 do
			for x = r.x,r.x+r.w-1 do
				if (x>=0 and x<8 and y>=0 and y<32) then
					add(out, x+y*8)
				end
			end
		end
		return out
	end

	function gather_sprites(r)
		local out={}
		
		for index in all(get_region_indexes(r)) do
			local ii = item[index]
			add(out, {
				bmp = ii.bmp,
				flags = ii.flags,
				pan_x = ii.pan_x,
				pan_y = ii.pan_y,
				zoom = ii.zoom
			})
		end
		
		return out
	end
	
	-- return
	function paste_sprite_collection(dat, region_w, do_big)
		local xx=0
		local yy=0
		local out = {}
		for i=1,#dat do
			-- target
			local tx=region.x + xx
			local ty=region.y + yy
			
			if (tx>=0 and tx<8 and ty>=0 and ty<32) then
				local index=tx+ty*8
				local src=dat[i] 
				item[index].undo_stack:checkpoint()
				
				item[index].bmp = src.bmp or userdata("u8",16,16)
				item[index].flags = src.flags or 0
				item[index].pan_x = src.pan_x or 0
				item[index].pan_y = src.pan_y or 0
				item[index].zoom  = src.zoom or 8
				item[index].extra = src.extra
				
				if do_big then
					local bmp1 = item[index].bmp
					local w,h = bmp1:attribs()
					local bmp2 = userdata("u8",w*2,h*2)
					for y=0,h*2-1 do
						for x=0,w*2-1 do
							bmp2:set(x,y,get(bmp1,x/2,y/2))
						end
					end
					item[index].bmp = bmp2
				end
				
				add(out,index)
			end
	
			-- advance relative position
			xx+=1
			if (xx >= region_w) then
				xx=0 yy+=1
			end
		end
		return out
	end
	
	
function _update()
	 
	--[[
		-- use update_gui_layout instead
		if (get_display():height() != last_display_height) refresh_gui = true
		last_display_height = get_display():height()
	]]	
	
	if (refresh_gui) then
		generate_gui()
		refresh_gui = false
	end
	
 	gui:update_all()
 	update_gui_layout()
 	set_draw_target()
 	
 	------------------------------------------
 	if (gui:get_keyboard_focus_element()) return
 	------------------------------------------
 	
 	if keyp("tab") then
		show_pane = not show_pane
	elseif keyp("enter") then
		clear_selection()
	end
	
	local mag = key("ctrl") and 8 or 1
	if (keyp("left"))  move_selection(-mag, 0)
	if (keyp("right")) move_selection( mag, 0)
	if (keyp("up"))    move_selection( 0,-mag)
	if (keyp("down"))  move_selection( 0, mag)
	
	if (not key"ctrl") then
	
	if (keyp("f")) modify_selection("flip_x")
		if (keyp("v")) modify_selection("flip_y")
		if (keyp("del") or keyp("backspace")) modify_selection("clear")
		
		-- navigate
		-- to do: region moves with these keys?
		local mag = key("shift") and 8 or 1
		if (keyp("-")) region.w,region.h=1,1 set_current_item(current_item - mag, true) 
		if (keyp("+")) region.w,region.h=1,1 set_current_item(current_item + mag, true)
		
		-- switch colour
		if (keyp("1")) switch_col(-1)
		if (keyp("2")) switch_col( 1)
		
	end -- no ctrl
	
 	-- ctrl --
 	
 	if (key("ctrl")) then
	 
	 	if keyp("c") or keyp("x") then
	 		local flags = item[current_item].flags
	 		if (flags == 0) flags = nil -- don't need to store anywhere
	 		
	 		if region.w == 1 and region.h == 1 then
		 		set_clipboard(
		 			pod(copy_selected_rect(),
		 				7, {pod_type="gfx",flags=flags}
		 		))
		 		local _,_,ww,hh = get_selected_rect()
		 		if (ww == cbmp_width and hh == cbmp_height) then
		 			notify("copied sprite")
		 		else
		 			notify("copied "..ww.." x "..hh.." pixels")
		 		end
		 		
	 		else
	 			-- multi-copy
	 			set_clipboard(
	 				pod(gather_sprites(region),
	 					7, {pod_type="gfx",region_w=region.w}
	 			))	
	 			notify("copied "..(region.w*region.h).." sprites")
	 		end
	 		
			if keyp("x") then
				backup_state()
				set_draw_target(cbmp)
				local x,y,w,h = get_selected_rect()
				rectfill(x,y,x+w-1,y+h-1,0)
				set_draw_target()
			end
		end
		
		if keyp("v") or keyp("b") then
			local ct = get_clipboard()
			local bmp1 = nil
			local meta = nil
			if (sub(ct,1,5) == "[gfx]") then
				bmp1 = userdata(ct)
			else
				bmp1, meta = unpod(ct)
			end
			if (type(bmp1) == "userdata") then
			
				-- paste big
				if (keyp"b") then
					local w,h = bmp1:attribs()
					local bmp2 = userdata("u8",w*2,h*2)
					for y=0,h*2-1 do
						for x=0,w*2-1 do
							bmp2:set(x,y,get(bmp1,x/2,y/2))
						end
					end
					bmp1 = bmp2
				end
				
				backup_state()
				item[current_item].bmp = bmp1
				item[current_item].flags = meta and meta.flags or 0
				set_current_item(current_item, true)
			elseif (type(bmp1) == "table" and meta and meta.region_w) then
				-- multipaste
				multi_op(
					paste_sprite_collection(bmp1, meta.region_w, keyp"b")
				)
				set_current_item(current_item, true)
				notify("pasted "..#bmp1.." sprites")
			else
				notify("could not find gfx to paste")
			end
		end
		
		if keyp("z") then
			undo()
			set_current_item(current_item)
			refresh_gui = true
		end
		
		if keyp("y") then
			redo()
			set_current_item(current_item)
			refresh_gui = true
		end
		
		if keyp("a") then
			select_all()
		end
		
	
	end -- ctrl
	
	
 end

--[[pod_format="raw",created="2023-10-10 07:45:26",modified="2024-07-18 22:58:53",revision=2796]]

-- update layout without needing to regenerate gui
 -- to do: could also use this for handling changes in display size
 function update_gui_layout()
 	if (not sidebar or not canvas_el) return
 	
 	xt = show_pane and 336 or 480
 	sidebar_x = sidebar_x or sidebar.x
 	sidebar_x = (sidebar_x * 3 + xt) / 4
 	
	if (sidebar_x > xt) then
		sidebar_x = max(xt, sidebar_x - 8)
	else
		sidebar_x = min(xt, sidebar_x + 8)
	end
	
	-- !! instant change -- maybe better (still get toolbar transition!)
	sidebar_x = xt

 	sidebar.x = sidebar_x \ 1
 	sidebar.height = get_display():height()
 
	canvas_el.width = sidebar_x \ 1
	canvas_el.height = get_display():height()
 
	-- send a message to wm asking to undock / dock toolbar
	if show_pane ~= last_show_pane then	
		--send_message(3, {event="dock_toolbar", state = show_pane})
	end
	last_show_pane = show_pane
 end


function get_selected_region()
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


function copy_selected_region()
	local x0, y0, ww, hh = get_selected_region()
	local out = userdata("i16", ww, hh)
	--printh(pod{x0,y0, ww,hh})
	blit(cbmp, out, x0, y0, 0, 0)
	return out
end


function move_selection(dx, dy)
	backup_state()
	
	if (not ci.layer) then
		-- just pan (louis instinctively tried this)
		item[1].pan_x += dx * item[1].zoom * 4
		item[1].pan_y += dy * item[1].zoom * 4
		return
	end
	
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
	backup_state()
	if (csel) csel:clear()
	csel_outline = nil -- refresh
	ci.layer, ci.back = nil, nil
end

function select_all()
	backup_state()
	csel:copy(1,true)
	csel_outline = nil -- regenerate	
	local ww,hh = cbmp_width,cbmp_height
	ci.layer = userdata("i16",ww,hh)
	ci.layer_x = 0
	ci.layer_y = 0
	ci.layer0 = cbmp:copy()

	-- same as select tool -- cut out area that will move (all of it)
	ci.layer0:clear() 
	

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
		tbmp:bxor(0x4000, true)
	end
	
	if (op == "flip_y") then
		for y=0, tbmp:height()-1 do
			blit(orig,tbmp,0,y,0,tbmp:height()-1-y,tbmp:width(),1)
		end
		tbmp:bxor(0x8000, true)
	end
	
	-- layer only -- don't clear whole map with del
	if (ci.layer and op == "clear") then
		ci.layer:clear()
	end
	
	-- update changes
	if (ci.layer) blit(ci.layer, cbmp, 0, 0, ci.layer_x, ci.layer_y)
end



 
 function _update()
 
	-- want to know if editing text at start of frame, so
	-- that can ignore enter keypress (erf) -- messed up checkpointing
	local kfce0 = gui:get_keyboard_focus_element()
 
 	gui:update_all()
	update_gui_layout()
 	set_draw_target()
 	
 	-------------------------------------------------------------
 
 	if (keyp("escape")) then
 		-- get rid of attach-on-demand elements
		refresh_gui = true
		window{capture_escapes = false}	
 	end
 	
  	-- layer name editor (or something else) has/had kbd focus -> ignore other input
 	if (gui:get_keyboard_focus_element() or kfce0) return
	-------------------------------------------------------------
 	
	if keyp("tab") then
		show_pane = not show_pane
		refresh_gui=true
	elseif keyp("enter") then
		clear_selection()
	end
	
	local mag = key("ctrl") and 8 or 1
	if (keyp("left"))  move_selection(-mag, 0)
	if (keyp("right")) move_selection( mag, 0)
	if (keyp("up"))    move_selection( 0,-mag)
	if (keyp("down"))  move_selection( 0, mag)
	
	if (keyp("f")) modify_selection("flip_x")
	if (keyp("v")) modify_selection("flip_y")
	if (keyp("del") or keyp("backspace")) modify_selection("clear")

	
 	-- 
 	if (key("ctrl")) then
 
 	if keyp("c") or keyp("x") then
 		local tbmp = ci.layer or cbmp
 		set_clipboard(pod(tbmp,7,{pod_type="map"}))
 		if keyp("x") then
			backup_state()
			tbmp:clear()
			if (ci.layer) blit(ci.layer, cbmp, 0, 0, ci.layer_x, ci.layer_y)
			notify(string.format("cut %d x %d tiles",tbmp:width(),tbmp:height()))
 		else
			notify(string.format("copied %d x %d tiles",tbmp:width(),tbmp:height()))
		end
	end
	
	if keyp("v") then
		local ct = get_clipboard()
		local bmp1 = nil
		if (sub(ct,1,5) == "[gfx]") then
			bmp1 = userdata(ct)
		else
			bmp1 = unpod(ct)
		end
		if (type(bmp1) == "userdata") then
			backup_state()
			item[current_item].bmp = bmp1
			set_current_item(current_item)
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
 





































--[[pod_format="raw",created="2023-05-11 02:05:16",modified="2024-07-18 22:58:53",revision=3088]]

show_pane = true



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
 

function generate_gui()
	
	gui = create_gui()
	
	-- remove temporary items attached on demand
	layer_name_editor = nil
	field_editor = nil
	
	if (not show_pane) then
		gui:attach(create_canvas{x=0,y=0,width=480,height=get_display():height()})
		return
	end
	
	canvas_el = gui:attach(create_canvas{x=0,y=0,width=336,height=261})
	
	sidebar = gui:attach{x=480-144,y=0,width=150,height=250}
	
	sidebar:attach(create_layer_info{x=8,y=5,width=128,height=24})
	sidebar:attach(create_layer_nav{x=8,y=16,width=128,height=55})
	
	-- a little space above palette for tabs (operation)
	--local pal_el = sidebar:attach(create_palette{x=8,y=14,width=128,height=32})
		
	--sidebar:attach(create_item_info{x=8,y=64,width=128,height=20})
	sidebar:attach(create_item_info{x=8,y=96,width=128,height=24})
	sidebar:attach(create_bank_tabs{x=8+128-48+1,y=116-9,width=48,height=9})
	sidebar:attach(create_nav{x=8,y=116,width=128,height=128})
	sidebar:attach(create_ram_widget{x=88,y=250,width=60,height=10})

	
	---- tools ----
	
	-- ** to do: tool should depend on layer type.
	-- ** e.g. entity picker when layer is entities mode
	
	local tools = {
		"pencil", "rect","fill","stamp","select","pick","pan"
	}
	
	local ww=12
	local yy=75 -- gfx is 50
	for i=0,#tools-1 do
	sidebar:attach(create_tool_button(tools[i+1], 
		10+(i%ww)*14, yy+(i\ww)*14))
	end
	
	
	
	update_gui_layout()


end
local tool_gfx={
pencil="[gfx]08080000700000077700007777700777770070777000700700007770000000000000[/gfx]",
brush="[gfx]08080000077000007700000770000007000007700000077000007700000000000000[/gfx]",
line="[gfx]08080000007000000700000070000007000000700000070000007000000000000000[/gfx]",
--rect="[gfx]08087777777070000070700000707000007070000070700000707777777000000000[/gfx]",
rect= -- alway filled in map editor
--[[pod,pod_type="image"]]unpod("b64:bHo0ABQAAAAXAAAAs3B4dQBDIAgIBGcAAgBQAGcAZ4A="),
pick=
--[[pod,pod_type="image"]]unpod("b64:bHo0ABgAAAAWAAAA8AdweHUAQyAICAQgB2AHsBcgF7AHYAew"),
select="[gfx]08087707077070000070000000007000007000000000700000707707077000000000[/gfx]",
shape="[gfx]08087777777070000070700000707000007070000070700000707777777000000000[/gfx]",
pan="[gfx]08080070700000707070007070700077777070777770077777700077770000000000[/gfx]",
fill="[gfx]08080000700000000700000000700777777770777770700777007000700000000000[/gfx]",
stamp="[gfx]08080077700000777000007770000077700077777770700000707777777000000000[/gfx]",
smudge="[gfx]08080070000000700000007070700077777070777770077777700077770000000000[/gfx]",
sweep="[gfx]08080000700000007000000070000007000000070000777777707070707000000000[/gfx]",
text="[gfx]08087777777077007770777707707700077070770770770070707777777000000000[/gfx]",
scramble="[gfx]08080700070007000700777777707077707077777770070007007700077000000000[/gfx]",
eraser="[gfx]08080007700000777700077777707077777070077700070070000077000000000000[/gfx]",
}
local brush_gfx={
"[gfx]08080000000000000000000000000007000000000000000000000000000000000000[/gfx]",
"[gfx]08080000000000000000000000000007700000077000000000000000000000000000[/gfx]",
"[gfx]08080000000000000000000700000077700000070000000000000000000000000000[/gfx]",
"[gfx]08080000000000000000000770000077770000777700000770000000000000000000[/gfx]",
"[gfx]08080000000000077000007777000777777007777770007777000007700000000000[/gfx]",
"[gfx]08080077770007777770777777777777777777777777777777770777777000777700[/gfx]",
"[gfx]08080000000000000000000000000000000000777700000000000000000000000000[/gfx]",
"[gfx]08080000000000000000000007000000700000070000007000000700000000000000[/gfx]"
}
function create_brush_button(which, x, y)
	local el= {which = which, x = x, y = y, width=12, height = 12}
	
	el.gfx = userdata(brush_gfx[which])
	
	function el:draw()
		rectfill(0,1,self.width-2,self.height-2,0)
		pal(7, self.which == brush.which and 7 or 13)
		spr(self.gfx,2,2)
		pal(7,7)
	end
	
	function el:tap()
		brush.which = self.which
		brush.thickness = self.which-1
	end
	
	return el
end
function create_tool_button(which, x, y)
	local el= {which = which, x = x, y = y, width=12, height = 12}
	
	el.gfx = tool_gfx[which]
	if (type(el.gfx)=="string") el.gfx = userdata(tool_gfx[which])
	
	function el:draw()
	--[[
		line(1,0,9,0,13)
		rectfill(0,1,10,9,13)
		line(1,10,9,10,13)
	]]
		pal(7, which == ctool and 7 or 13)
		spr(self.gfx,2,2)
		pal(7,7)
	end
	
	function el:tap()
		ctool = self.which
		refresh_gui = true
	end
	
	return el
end

-- from gfx.p64
function create_ram_widget(el)
	function el:draw()
		print(string.format("%2.2fmb (%02d%%)",stat(0)/0x100000,stat(0)\167772),0,0,
			stat(0) > 0xe00000 and 14 or 21) -- warn when more than 7/8ths of capacity
	end
	return el
end

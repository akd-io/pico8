--[[pod_format="raw",created="2023-05-11 02:05:16",modified="2024-08-18 16:06:41",revision=3778,stored="2023-24-28 00:24:00"]]
--[[

	should only need:
	palette  --  with tab to show operations (or other palette styles)
	tools
	tool attributes // brush size, fill pattern
	navigator

	the palette and navigator can /frame/ the tools + attributes	

]]

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
	
	canvas_el = gui:attach(create_canvas{x=0,y=0,
	width=336,height=get_display():height()})

	sidebar = gui:attach{x=480-144,y=0,width=150,height=250}
	
	-- a little space above palette for tabs (operation)
	local pal_el = sidebar:attach(create_palette{x=8,y=16,width=128,height=32})

	sidebar:attach(create_pal_tabs{x=112,y=6,width=48,height=9})
	sidebar:attach(create_pal_preview{x=7,y=4,width=30,height=9})
--[[
	sidebar:attach{
		x=128,y=8,width=8,height=6,
		draw=function() 
			--for y=0,3 do for x=0,7 do
			--	pset(x,y,x+y*8) end end
			rectfill(0,0,7,3,6) 
		end,
		click=function() pal_swatch ^^= 1 refresh_gui=1 end
	}
]]	
		
	--sidebar:attach(create_item_info{x=8,y=64,width=128,height=20})

	sidebar:attach(create_item_info{x=8,y=96,width=128,height=24})
	sidebar:attach(create_bank_tabs{x=8+128-48+1,y=116-9,width=48,height=9})
	sidebar:attach(create_nav{x=8,y=116,width=128,height=128})
	sidebar:attach(create_ram_widget{x=88,y=250,width=60,height=10})

	---- tools ----
	
	local tools = {
		"pencil","brush","line","rect", "circ",
		"fill", "stamp", "select", "pan"
		--"eraser",
		--"smudge",
		--"sweep","text","scramble"
	}
	
	local ww=12
	local yy=pal_el.y + pal_el.height + 4
	for i=0,#tools-1 do
	sidebar:attach(create_tool_button(tools[i+1], 
		10+(i%ww)*14, yy+(i\ww)*14))
	end
	
	---- colour / fill pattern preview -----

-- only show when tools that use fill pattern is selected
-- (line and shape disabled for now)
if (({brush=1,xline=1,xshape=1})[ctool]) then 

	yy+=16
	sidebar:attach({x=8,y=yy,width=24,height=24,
		draw=function(self)
			clip()
			rectfill(-1,-1,self.width,self.height,0)
			fillp(brush.pat)
			rectfill(0,0,self.width-1,self.height-1,col)
			fillp()
		end
	})
	
	-- brushes
	
	local xx = 36
	
	
	for i=0,7 do
		sidebar:attach(create_brush_button(i+1, xx +(i%ww)*12, yy))
	end
	
	-- 0x8085
	-- fill patterns
	
	local pat = {[0]=
		0x0000,0x50a0,0x5a5a,0x50a0~0xffff,	
		0x36c9,0x9c63,0x1248~0xffff,0x8421~0xffff,

		0x0000, 0x80b9, 0x813d,
		0x7e99, 0x81db, 0x7d7d,
		0x8272, 0x834f
	}
	yy += 14
	for i=0,7 do
			sidebar:attach({x = xx + i*12, y = yy, width=11,height=10,
				pat = pat[i],
				draw=function(self)
					clip()
					--poke(0x550b,0xff)
					rectfill(-1,-1,self.width,self.height,0)
			
					fillp(self.pat)
					rectfill(0,0,self.width-1,self.height-1,
						self.pat==brush.pat and 7 or 5)
					fillp()
				end,
				click = function(self)
					brush.pat = self.pat
				end
			})
	end
end -- brush elements

	update_gui_layout()

end

local tool_gfx={
pencil="[gfx]08080000700000077700007777700777770070777000700700007770000000000000[/gfx]",
brush="[gfx]08080000077000007700000770000007000007700000077000007700000000000000[/gfx]",
line="[gfx]08080000007000000700000070000007000000700000070000007000000000000000[/gfx]",
select="[gfx]08087707077070000070000000007000007000000000700000707707077000000000[/gfx]",
rect="[gfx]08087777777070000070700000707000007070000070700000707777777000000000[/gfx]",
circ=unpod("b64:bHo0ACAAAAAiAAAA8wVweHUAQyAICAQQJzAHIAcQB0AHAAQAcBAHIAcwJ6A="),
pan="[gfx]08080070700000707070007070700077777070777770077777700077770000000000[/gfx]",
fill="[gfx]08080000700000000700000000700777777770777770700777007000700000000000[/gfx]",
stamp="[gfx]08080077700000777000007770000077700077777770700000707777777000000000[/gfx]",
smudge="[gfx]08080070000000700000007070700077777070777770077777700077770000000000[/gfx]",
sweep="[gfx]08080000700000007000000070000007000000070000777777707070707000000000[/gfx]",
text="[gfx]08087777777077007770777707707700077070770770770070707777777000000000[/gfx]",
scramble="[gfx]08080700070007000700777777707077707077777770070007007700077000000000[/gfx]",
eraser="[gfx]08080007700000777700077777707077777070077700070070000077000000000000[/gfx]",
}

brush_gfx={
userdata"[gfx]08080000000000000000000000000007000000000000000000000000000000000000[/gfx]",
userdata"[gfx]08080000000000000000000000000007700000077000000000000000000000000000[/gfx]",
userdata"[gfx]08080000000000000000000700000077700000070000000000000000000000000000[/gfx]",
userdata"[gfx]08080000000000000000000770000077770000777700000770000000000000000000[/gfx]",
userdata"[gfx]08080000000000077000007777000777777007777770007777000007700000000000[/gfx]",
userdata"[gfx]08080077770007777770777777777777777777777777777777770777777000777700[/gfx]",
--[[pod,pod_type="image"]]unpod("b64:bHo0AA8AAAAOAAAA4HB4dQBDIAgIBPAJR-AS"),
--[[pod,pod_type="image"]]unpod("b64:bHo0ABoAAAAYAAAA8AlweHUAQyAICARQB1AXQBdAF0AXQBdAF9A="),
userdata"[gfx]08080000000000000000000000000000000000777700000000000000000000000000[/gfx]",
userdata"[gfx]08080000000000000000000007000000700000070000007000000700000000000000[/gfx]"
}


function create_brush_button(which, x, y)
	local el= {
		which = which, x = x, y = y, width=12, height = 12,
		cursor="pointer"	
	}
	
	el.gfx = brush_gfx[which]
	
	function el:draw()
		rectfill(0,1,self.width-2,self.height-2,0)
		pal(7, self.which == brush.which and 7 or 13)
		spr(self.gfx,2,2)
		pal(7,7)
	end
	
	function el:tap()
		brush.which = self.which
		brush.thickness = self.which-1
		brush.sprite = el.gfx
	end
	
	return el
end


function create_tool_button(which, x, y)
	local el= {which = which, x = x, y = y, width=12, height = 12,cursor="pointer"}
	
	if type(tool_gfx[which]) == "userdata" then
		el.gfx = tool_gfx[which]
	else
		el.gfx = userdata(tool_gfx[which])
	end
	
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


function create_ram_widget(el)
	function el:draw()
		print(string.format("%2.2fmb (%02d%%)",stat(0)/0x100000,stat(0)\167772),0,0,
			stat(0) > 0xe00000 and 14 or 21) -- warn when more than 7/8ths of capacity
	end
	return el
end


--[[pod_format="raw",created="2023-11-20 08:11:39",modified="2024-10-15 00:19:32",revision=3761,stored="2023-21-29 09:21:19"]]
-- interface


top_z = 1

-- shortcut
-- don't need desktop (just use desktop!) or favourites (too many concepts)
shortcuts =
{
	-- "favs" to avoid deciding which spelling to use
	{"/ram/cart",userdata"[gfx]08087777777770000007700000077000000777777777700000777777777000000000[/gfx]"},
	--{"/desktop", userdata"[gfx]08087777777700000000777777777077777777777777707777777777777700000000[/gfx]"},
	--{"/appdata/filenav/favs",userdata"[gfx]08080000000007707700777777707777777007777700007770000007000000000000[/gfx]"},
	{"/",userdata"[gfx]08080000000000000770000077000007700000770000077000007700000000000000[/gfx]"},
}
button_gfx =
{
	updir = userdata"[gfx]08080000000000770000077770007777770000770000007700000077770000000000[/gfx]",
	--list  = userdata"[gfx]08087777077000000000777707700000000077770770000000007777077000000000[/gfx]",
	list  = userdata"[gfx]08087770707000000000777070700000000077707070000000007770707000000000[/gfx]", -- to do: still too similar to app menu 
	grid  = userdata"[gfx]08087770777077707770777077700000000077707770777077707770777000000000[/gfx]",
}
function generate_toolbar()
	local shortcut_w = 16
	local shortcuts_w = shortcut_w * #shortcuts + 8
	
	toolbar = gui:attach{
		x = 0, y = 0,
		width_rel = 1.0,
		height = 16
	}
	
	function toolbar:draw()
		rectfill(0,0,1000,self.height,6)
	end
	
	-- navbar
	-- to do: put up_folder button on left? maybe not!
	navtext = toolbar:attach_text_editor{
		x=34,y=2,
		width=100,
		width_rel = 1.0,
		width_add = -shortcuts_w - 34,
		height=12,
		max_lines = 1,	
		key_callback = { 
		
			enter = function () 
				
				local path = navtext:get_text()[1]
				local attribs = fstat(path)

				-- printh("pressed enter "..pod{navtext:get_text()[1], path, attribs})
				
				if attribs == "folder" then
					cd(path)
				elseif intention then
					process_intention()
				elseif (attribs == "file") then
					-- open it; same as double clicking on it
					click_on_file(path)
				else
					-- create file?
					--> to do: switch to New File intention
						-- (used can cancel if it was a typo)
				end
					
				refresh_gui = true
				
			end,
			
			tab = function ()
				local path = navtext:get_text()[1]
				path = tab_complete_filename(path)
				
				navtext:set_text{path}
				-- hacky way to put the mouse cursor at the end
				navtext:click({mx=1000,my=2})
				
			end
		
		}
	}
	
	
	local path = pwd()
	if (string.sub(path,-1) != "/") path = path.."/"
	navtext:set_text{path}
	navtext:set_keyboard_focus(true)
	-- hacky way to put the mouse cursor at the end
	navtext:click({mx=1000,my=2})
	
	-- shortcut buttons
	
	for i=1,#shortcuts do
		toolbar:attach{
			cursor = "pointer",
			--x = get_display():width()-shortcuts_w + 5 + (i-1) * shortcut_w,
			x = -shortcuts_w + 5 + i * shortcut_w,
			justify = "right",
			y = 3,
			width=shortcut_w,
			height=10,
			location=shortcuts[i][1],
			icon=shortcuts[i][2],
			draw = function(self)
				--rectfill(0,0,self.width-1,self.height-1,7)
				pal(7,self.location==pwd() and 7 or 13)
				spr(self.icon,self.width/2-self.icon:width()/2,1)
				pal(7,7)
			end,
			tap = function(self)
				cd(self.location)
				refresh_gui = true
			end
		}
	end
	
	-- updir button
	
	toolbar:attach{
			cursor = "pointer",
			x = 16,y = 3,width=shortcut_w,height=10,
			icon=button_gfx.updir,
			draw = function(self)
				pal(7,13) --pwd() == "/" and 6 or 13)
				spr(self.icon,self.width/2-self.icon:width()/2,1)
				pal(7,7)
			end,
			tap = function(self)
				cd("..")
				refresh_gui = true
			end
		}
		
	-- toggle view mode
	
	toolbar:attach{
			cursor = "pointer",
			x = 2,y = 3,width=shortcut_w,height=10,
			draw = function(self)
				local icon = mode == "list" and button_gfx.list or button_gfx.grid
				pal(7,13)
				spr(icon,self.width/2-icon:width()/2,1)
				pal(7,7)
			end,
			tap = function(self)
				mode = (mode == "grid") and "list" or "grid"
				refresh_gui = true
			end
		}
	
	
end


function generate_interface()

	local scroll_y = content and content.y
	local text0 = navtext and navtext:get_text()
	
	gui_w, gui_h = get_display():width(), get_display():height()
	
	-- show path when not in intention mode
	if (not intention) then
		window{title = pwd()}
	end
	
	gui = create_gui()
	
	local files = ls(pwd())
	
	-- printh("generate_interface()")
	
	local add_height = intention and -19 or 0

	-- to do: generate interface based on mode
	if (mode == "list")    generate_interface_list(16, add_height)
	if (mode == "grid")    generate_interface_grid(16, add_height)
	if (mode == "desktop") generate_interface_desktop(0, add_height)
	
	if (mode != "desktop") then
		generate_toolbar()
	end
	
	if (intention) generate_intention_panel()
	
	-- restore some state
	if (content and scroll_y) content.y = scroll_y
	if (content and text)     navtext:set_text(text0)
	
	
end





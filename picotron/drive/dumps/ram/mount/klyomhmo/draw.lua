--[[pod_format="raw",created="2023-10-12 03:26:20",modified="2024-07-18 22:58:53",revision=2264]]
function _draw()
	cls(5)
	-- operations during _update can request a
	-- gui update before it is next draw (avoid flicker)
	if (refresh_gui) then
		generate_gui()
		-- gui:draw_all() expects :update_all() called first on current state of gui
		gui:update_all()
		refresh_gui = false
	end
		
	fillp() pal()
	gui:draw_all()
	
	-- dark gray
	poke4(0x5000+32*4, 0x20202020)
	
	if (custom_palette) then
		poke4(0x5000, get(custom_palette))
	end
	
end


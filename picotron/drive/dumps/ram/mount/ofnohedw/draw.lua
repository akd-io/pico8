--[[pod_format="raw",created="2023-10-12 03:26:20",modified="2024-08-18 16:06:41",revision=2907,stored="2023-24-28 00:24:00"]]
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
		
	gui:draw_all()
	
	-- custom display palette
	-- at end.. something in :draw_all() probably calls pal()
	poke4(0x5000+32*4, 0x20202020)
	
	if (custom_palette) then
		poke4(0x5000, get(custom_palette))
	end
	
end


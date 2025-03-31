--[[pod_format="raw",created="2023-10-22 07:32:11",modified="2024-09-12 16:58:56",revision=14024,stored="2023-36-29 04:36:40"]]
global_t = 0

-- map keyboard letters to pitches

key_pitch="zsxdcvgbhnjmq2w3er5t6y7ui9o0p"

something_is_playing = false

function follow_playback(playing_pattern)

	-- click anywhere (e.g. scrollbar) -> turn off following
	local mx,my,mb = mouse()
	if (mb > 0 and last_mb ~= 0) following_playback = false
	if key"left" or key"right" or key"up" or key"down" or
		key"pageup" or key"pagedown"
	then
		following_playback = false
	end
	

	if (not playing_pattern or playing_pattern < 0) following_playback = false
	if (mode ~= "pattern") following_playback = false
	if (not following_playback) return --false
	
	if (cp ~= playing_pattern) then
		cp = playing_pattern
		refresh_gui = true
	else
		-- follow cursor row of leftmost non-looping channel
		
		local row = stat(400 + stat(467), 9)
		pattern_contents.y = mid(0, 64 - row * 8, 
			 pattern_contents.parent.height - pattern_contents.height)
	end
	
end


function _update()


	local playing_pattern = stat(466)

	follow_playback(playing_pattern)
	
	-- find out which channel current instrument is being played on
	ci_channel = -1
	for i=0,15 do
		if (ci_channel == -1 and stat(400+i,1) == ci) then
			ci_channel = i
		end
	end
	
	-- update: something_is_playing
	something_is_playing = false
	for i=0,15 do
		if (stat(400+i,12) != -1) something_is_playing = true -- sfx
		--if (stat(400+i,1 ) != -1) something_is_playing = true -- inst
	end
	
	-- or if there is [recently] some global output (e.g. echo or rogue node)
	len = stat(465,0,0xe0000)
	local found_signal
	for i=0,len-7,8 do
		if (peek8(0xe0000+i) != 0) found_signal = true
	end
	if (found_signal) last_found_signal_t = t()
	if (last_found_signal_t and last_found_signal_t > t()-0.1) then
		something_is_playing = true
	end
	

	if (gui) gui:update_all()
	
	--------------------------------------------
	if (gui and gui:get_keyboard_focus_element()) return
	--------------------------------------------
	
	if (key"ctrl") then
		-- can't play note when holding control
		
		if (keyp"z") undo()
		if (keyp"y") redo()
	
	elseif (keyp"space") then
		-- inst mode only -- track / pat has own handling
		if mode == "instrument" then
			if (something_is_playing) then
				note() -- kill all channels
			else
				-- play current sfx / track
				if (last_mode == "track") sfx(ct)
				if (last_mode == "pattern") music(cp)
			end
		end
	elseif mode == "instrument" then	
		
		local pitch = -1
		--if (keyp("space")) pitch = 48 -- middle c
		if (keyp(",")) pitch = 60 -- to do
		
		for i=1,#key_pitch do
			if key(sub(key_pitch,i,i)) then
				pitch = 35 + i + (coct*12-48)
			end
		end
		
		if (pitch >= 0) then
			note(
				pitch, -- pitch
				pitch ~= last_pitch and ci or 255, -- works with inst retrig flag set
				cvol,    -- volume
				0,0,   -- effect, effect_p
				8,     -- channel index -- 8 so that can play with music
				false  -- don't force retrigger (retrigger when pitch/inst changes)		
				)
		else
			-- release
			local mx,my,mb = mouse()
			if (mb == 0 or mx > 80) -- not holding play button w/ mouse
			then
				note(0xff, 0xff, 0xff, 0xff, 0xff, 8)
			end
		end
		
		last_pitch = pitch
		
	end
	

	if (mode == "track" or (mode == "pattern" and focus == "track")) then
		update_track_editor()
	elseif mode == "pattern" then
		update_pattern_editor()
	elseif mode == "instrument" then
		update_instrument_editor()
	end
	
	-- applies even when focus is on track
	if (mode == "pattern") update_pattern_editor_playback()

	
	-- switch modes
	if (keyp"tab") then
		if (mode == "instrument") then mode = "track"
		elseif (mode == "track") then mode = "pattern"
		else mode = "instrument" end
		set_mode(mode)
	end
	
	-- navigate items
	
	if (cur_x == 6 and (mode == "track" or mode == "pattern")) then
		-- can't navigate when in fx channel!
		-- -,+ mean slide
	elseif (keyp("-") or keyp("+")) then

		local dd = keyp("-") and -1 or 1
		if (mode == "instrument") ci += dd if (key"shift") then extend_instrument_selection() else ci0,ci1,ci2=ci,ci,ci end
		if (mode == "track")      ct += dd if (key"shift") then extend_track_selection()      else ct0,ct1,ct2=ct,ct,ct end
		if (mode == "pattern")    cp += dd if (key"shift") then extend_pattern_selection()    else cp0,cp1,cp2=cp,cp,cp end

		

		refresh_gui = true
	end
	
	
	
	
	global_t += 1
	
	-- consume any leftover text input
	readtext(true)
	
	
end



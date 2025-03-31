--[[pod_format="raw",created="2023-10-22 07:32:11",modified="2024-09-12 16:58:56",revision=15444,stored="2023-36-29 04:36:40"]]

function create_pane(title, x, y, w, h, col, ontap)

	if (not col) col = 0x0705 -- default back
	
	local el={
		title=title,
		x=x,y=y,width=w,height=h,
		col=col
	}
	
	if (ontap) el.cursor = "pointer"
	
	function el:draw()
	
		local col = (self.col >> 0) & 0xff
		local hcol = (self.col >> 8) & 0xff
		
		rectfill(1,0,self.width-2,0,hcol)
		rectfill(0,1,self.width,8,hcol)
		rectfill(0,9,self.width-1,self.height-2,col)
		rectfill(1,self.height-1,self.width-2,self.height-1,col)
		
		--print(title,14,2,1) -- assume some kind of icon to the left
		local str = title
--		if (str == "instruments") str = string.format("inst %02x \f6(%d)", ci,ci)
		if (str == "sfx") str = "sfx "..flr(ct)
		print(str,6,2,1) -- assume some kind of icon to the left
		
	end
	
	-- on tap header
	function el:tap(msg)
		if (ontap and msg.my <= 9) ontap(self,msg)
	end
	
	return el
end

function extend_instrument_selection()
	if (ci < ci2) then
		ci0 = ci -- extend to left
		ci1 = ci2
	else
		ci1 = ci -- extend to right
		ci0 = ci2
	end
end

function extend_track_selection()
	if (ct < ct2) then
		ct0 = ct -- extend to left
		ct1 = ct2
	else
		ct1 = ct -- extend to right
		ct0 = ct2
	end
end

function extend_pattern_selection()
	if (cp < cp2) then
		cp0 = cp -- extend to left
		cp1 = cp2
	else
		cp1 = cp -- extend to right
		cp0 = cp2
	end
end


function create_instrument_chooser(el)
	local contents
	-- instrument chooser
	local container = el:attach{
		x=2,y=10,width=el.width-2,height=el.height-11,
		draw=function(self)
			-- some parent turned clipping off; can turn back on here
			clip(self.sx,self.sy,self.width,self.height)
		end,
		update=function(self)
			scroll[1] = contents.y
		end
	}
	contents = container:attach{
		x=0,y=0,width=86,height=512,
		draw=function(self)
			local i0 = mid(0, (-contents.y)\8, 63)
			local i1 = mid(0, i0 + 8, 63)
			for i=i0,i1 do
				if (i >= ci0 and i <= ci1 and mode=="instrument") then
					rectfill(0,i*8,self.width-1,i*8+6,31)
				end
				if (ci == i) then
					rectfill(0,i*8,self.width-1,i*8+6,
					mode=="instrument" and 14 or 16)
				end
				local fmt = (ci == i) and "%02x \f7%s " or "%02x \fd%s "
				print(string.format(fmt,i,get_inst_name(i)),0,1 + i*8, 7)--6)
				--print(string.format("%02i inst ",i),2,1 + i*8,6)
			end
		end,
		click=function(self,msg)
			ci = msg.my\8
			
			if (key"shift") then
				extend_instrument_selection()
				mode = "instrument"
			else
				ci0,ci1,ci2 = ci,ci,ci -- reset instrument selection
			end
			
			if (key"ctrl") set_mode("instrument")
			if (mode == "instrument") refresh_gui = true
		end,
		doubleclick = function(self,msg)
			ci = msg.my\8
			ci0,ci1,ci2 = ci,ci,ci
			set_mode("instrument")
			refresh_gui = true
		end
	}

	
	container:attach_scrollbars()
	
	-- start centered
	contents.y = -ci * 8 + 30
	if (scroll[1]) contents.y = scroll[1]

	-- clamp
	contents.y = mid(0, contents.y, - (contents.height - container.height))
end

sfx_thumb={}
function get_sfx_thumb(sfxi, use_cached)
	local addr = 0x50000 + sfxi * 328 + 8
	if not sfx_thumb[addr] or not use_cached then
		local bmp = userdata("u8",8,7)
		-- multiple dots per x
		for x=0,31 do
			local pitch = @(addr+x)
			local inst  = @(addr+x+64)
			if (inst != 0xff) set(bmp, x/4, mid(0,10-pitch/8,7), 8+(inst%24))
		end
--[[
		for x=0,7 do
			local pitch = 0
			local inst = 0xff
			for j=0,3 do
				local addr2=addr+x*4+j
				if (@addr2 > pitch) then
					pitch = @addr2 inst = @(addr2+64)
				end
			end
			set(bmp,x,10-pitch/6,8+(inst%24))
		end
--]]
		
		sfx_thumb[addr] = bmp
	end
	return sfx_thumb[addr]
end


function get_track_index_from_nav_mxy(mx, my)
	local xx  = mid(0, (mx-2) \ 9, 7)
	local yy  = (my-2)
	local yy1 = (yy\74)*8 + mid(0,(yy%74-8)\8,7)
	
	return flr(xx + yy1 * 8)
end
	


function create_track_chooser(el)

	local contents
	local container = el:attach{
		x=1,y=10,width=el.width-2,height=el.height-10,
		draw=function(self)
			-- some parent turned clipping off; can turn back on here
			clip(self.sx,self.sy,self.width,self.height)
		end,
		update=function(self)
			scroll[2] = contents.y
		end
	}
	
	contents = container:attach{
		x=0,y=0,width=86,height=74*6+2,
		draw=function(self)
		
			for group = 0,5 do
				local x = 2
				local y = 2 + group * 74
				print(string.format("%03d",group*64),x,y,13)
				y+=8
				-- clip by group
				if y + contents.y > -74 and y + contents.y < container.height then
				for i = group*64, group*64+63 do
					-- clip by line
					if y + contents.y > -12 and y + contents.y < container.height then
						rectfill(x,y,x+7,y+6,0)
						
						if (i >= ct0 and i <= ct1 and mode =="track") then
							-- track selection
							rect(x-1,y-1,x+8,y+7, 10)
						end
						if (ct == i) then
							-- current track highlighted
							rect(x-1,y-1,x+8,y+7, focus=="track_item" and 7 or 13)
						end
						
						-- show is playing
						local pr = playing_row(i)
						if (pr) then
							rectfill(x,y,x+7,y+6,5) -- just highlight background
							-- show position. not that useful!
							--line(x+pr/8, y, x+pr/8, y+6, 7)
							-- blinky bars: cuter, but too much
							--[[
							for j=0,2 do
								rectfill(x+j*3,y+6,x+1+j*3,y+6-max(cos(-j*.3+t()*3))*2,
									(time()*2+j/5)%1<.4 and 6 or 13)
							end
							]]
						end
						
						spr(get_sfx_thumb(i, i != ct),x,y)
						
					end
				
					x += 9
					if (x > 72) then
						x = 2 y += 8
					end
				
				end
				end
			end	

--[[
			for i=0,383 do
				local x = 2 + (i % 8) * 9
				local y = 2 + (i \ 8) * 8 + (i\64)*10
				--rectfill(x,y,x+7,y+6, ct == i and 29 or 18)
				rectfill(x,y,x+7,y+6,0)
				if (ct == i) rect(x-1,y-1,x+8,y+7,7)
				-- thumb
				local dat_addr = 0x50000 + i * 328 + 8
				spr(get_sfx_thumb(dat_addr, i != ct),x,y)
				
				--print(string.format("%02x",i),x+1,y+1,1)
				if (playing_row(i)) then
					for j=0,2 do
						--circfill(x+4+j*4,y+10,.8+cos(-j*.3+t()*2), 7)
						rectfill(x+3+j*4,y+11,x+5+j*4,y+11-max(cos(-j*.3+t()*3))*2,7)
					end
				end
			end
			]]
		end,
		
		release=function(self,msg)
			
			local sx=self.sx + msg.mx
			local sy=self.sy + msg.my
			
			local el2 = gui:el_at_xy(sx,sy)
			if (el2 and el2.drop_track_index) el2:drop_track_index{index=grabbed_track}
			
			grabbed_track = nil
		end,
		
		click=function(self, msg)
			grabbed_track = get_track_index_from_nav_mxy(msg.mx, msg.my)
			grabbed_track_t = time()
		end,
	
		
		tap=function(self, msg)
			checkpoint()
				
			ct = get_track_index_from_nav_mxy(msg.mx, msg.my)
			if (key"shift") then
				extend_track_selection()
			else
				ct0,ct1,ct2 = ct,ct,ct -- reset track selection
			end
			set_mode("track")
			refresh_gui = true
		end
	}
	container:attach_scrollbars()
	
	if (mode == "track") then
		-- if already in track mode, don't need to be able to
		-- drag track, and want selection be snappier (happen
		-- on click instead of tap)
		contents.click = contents.tap
		contents.tap = nil
	end
	
	if (scroll[2]) contents.y = scroll[2]
	
	
end

-- 128 patterns
-- can add a way to add more later, but > 128 becomes awkward to navigate
function create_pattern_chooser(el)

	local contents
	local container = el:attach{
		x=2,y=10,width=el.width-2,height=el.height-11,
		draw=function(self)
			-- some parent turned clipping off; can turn back on here
			clip(self.sx,self.sy,self.width,self.height)
		end,
		update=function(self)
			scroll[3] = contents.y
		end
	}
	contents = container:attach{
		x=0,y=0,width=86,height=(128/4*12)+4,
		
		draw=function(self)
			local playing_pattern = stat(466)
			i0 = mid(0, ((-contents.y) \ 12) * 4, 127)
			i1 = mid(0, i0 + 23, 127)
			for i=i0,i1 do
				local addr = 0x30100 + i * 20
				local flags = peek(addr+8)  -- flow flags
				local mask =  peek(addr+9) -- channel mask -- 4 channels
				
				local x = 0 + (i % 4) * 19
				local y = 2 + (i \ 4) * 12
				rectfill(x,y,x+16,y+8,
					(i >= cp0 and i <= cp1 and mode=="pattern") and 
					(focus == "pattern" and 14 or 30) or 
					(mask == 0 and 0 or 18))
				--rect(x,y,x+16,y+8, cp == i and 14 or 13)
				
				-- loop0: cut top left corner
				if (flags & 1 > 0) then
					pset(x,y,1)
					line(x,y+1,x+1,y,1)
				end
				-- loop1: cut top right corner
				if (flags & 2 > 0) then
					pset(x+16,y,1)
					line(x+16,y+1,x+15,y,1)
				end
				-- stop: cut bottom right corner
				if (flags & 4 > 0) then
					pset(x+16,y+8,1)
					line(x+16,y+7,x+15,y+8,1)
				end
				
				if (mask == 0) then
					
				elseif (mask & 0xf0) > 0 then
					-- 8 channels
					for j=0,7 do
						local index = @(addr+j)
						pset(1+x+j*2,y+10,(mask & (1<<j)) > 0 and 8+(index%16) or 0)
					end
				else
					-- only use channels 0..3
					for j=0,3 do
						local index = @(addr+j)
						local xx=1+x+j*4
						local yy=y+10
						line(xx,yy,xx+2,yy,(mask & (1<<j)) > 0 and 8+(index%16) or 0)
					end
				end
				local istr=string.format("%02i",i)
				print(istr,x+9-#istr*2,y+2, cp == i and 7 or 1)
				
				-- blinky verion when playing back
				
				if (playing_pattern == i) then
					local ww = (mask & 0xf0) > 0 and 2 or 4
					local jj = (mask & 0xf0) > 0 and 7 or 3
					for j=0,jj do
						local index = @(addr+j)
						local col = (mask & (1<<j)) > 0 and 8+(index%16) or 0
						local xx=1+x+j*ww
						local yy=y+10
						if ((time()*2-(j*5.7))%1 < 0.4) col = 7 -- blink white
						rectfill(xx,yy+cos(time()*2-j/5)*0.5,xx+ww-2,yy,col)
					end
				end
				
			end
		end,
		
		tap=function(self, msg)
			checkpoint()
			cp = flr(mid(0, msg.mx \ 20, 3) + ((msg.my-2) \ 12) * 4)
			
			if (key"shift") then
				extend_pattern_selection()
			else
				cp0,cp1,cp2 = cp,cp,cp -- reset pattern selection
			end
			
			set_mode("pattern")
			refresh_gui = true
		end
	}
	container:attach_scrollbars()
	
	contents.y = -(cp\4) * 12 + 20
	if (scroll[3]) contents.y = scroll[3]

	-- clamp
	contents.y = mid(0, contents.y, - (contents.height - container.height))
	
end

function create_volume_chooser(x, y)
	local el ={
		x = x, y = y, width=48, height = 7,
		cursor = "pointer"
	}
	function el:draw(msg)
		clip()
		if (msg.mb>0 and msg.has_pointer) then
			print(cvol,-15,1,16)
		else
			print("vol",-15,1,16)
		end
		for i=0,7 do
			local sx = i * 5
			rectfill(sx,0,sx+4,6, (i+1)*0x8 == cvol&(~0x7) and 6 or 13)
			--print("\014"..(i+1),sx+1,1,13)
		end
	end
	function el:drag(msg)
		cvol = mid(1,(1+(msg.mx\5)),8)*0x8
	end
	
	return el
end

 
function create_octave_chooser(x, y)
	local el ={
		x = x, y = y, width=48, height = 7,
		cursor = "pointer"
	}
	function el:draw()
		clip()
		print("oct",-15,1,16)
		for i=0,7 do
			local sx = i * 5
			rectfill(sx,0,sx+4,6,i+1 == coct and 6 or 13)
			print("\014"..(i+1),sx+1,1,i+1 == coct and 13 or 13)
		end
	end
	function el:drag(msg)
		coct = mid(1,1+(msg.mx\5),8)
	end
	
	return el
end


function generate_gui_track()

	local xx = 92
	track_pane = gui:attach(create_pane("\f6sfx "..ct,xx,4,384,82,0x1001))
	
	track_pane.click = function()
		-- copy/paste applies to the whole sfx, not note selection 
		-- click on track to change focus to track (note selection)
		focus = "track_item"
	end
	
	focus = "track_item"
	
	local track_addr = 0x50000 + ct * 328
	-- don't expose length for now; always 64
	-- future: when change len, need to update stride to match!
	--track_pane:attach(create_tiny_num_field("len",  track_addr + 0,100,1))
	
--[[ deleteme -- moved to left pane
	track_pane:attach(create_octave_chooser( 75,1))
	track_pane:attach(create_volume_chooser(145,1))
]]

-- is not just play length -- dictates how data is arranged (stride between columns)
--	track_pane:attach(create_tiny_num_field("len",  track_addr + 0,230,1,  1,64))

	
	track_pane:attach(create_tiny_num_field("spd",  track_addr + 2,260,1,1))
	track_pane:attach(create_tiny_num_field("loop0", track_addr + 3,310,1))
	track_pane:attach(create_tiny_num_field("loop1",track_addr + 4,360,1))
	
	-- 8 segments of same track
	for i=0,7 do
		track_pane:attach(create_track_segment{
			x=2 + i * 48, y=12, rows=8,
			row0 = i*8,
			index = ct -- sfx_index
		})
	end
	
	
	gui:attach(create_pane("\f6pitch ",xx,90,384,88,0x1000))
		:attach(create_pitch_scribbler{
			x=0,y=10,width=384,height=76,addr=track_addr + 8,stride=64})
	
	gui:attach(create_pane("\f6volume ",xx,180,386,76,0x1000))
		:attach(create_volume_scribbler{
			x=0,y=10,width=384,height=66,addr=track_addr + 8 + 128,stride=64})
	
end

local function create_flow_toggle(el)
	el.width = 7
	el.height = 7
	el.cursor = "pointer"
	local addr = 0x30100 + cp*20+8
	function el:draw()
		poke(0x30100 + cp*20+8)
		local selected = (peek(addr) & el.bit) > 0
		--rectfill(0,0,6,6,selected and 10 or 13)
		pal(7, selected and 10 or 1)
		spr(el.icon,0,0)
		pal()
	
	end
	function el:tap()
		poke(addr, peek(addr) ^^ el.bit)
	end
	return el
end


local function create_inst_flag_toggle(el)
	local inst_addr = 0x40000 + ci*0x200
	local el = el or {}
	el.width = 40
	el.height = 17
	el.cursor = "pointer"
	local addr = inst_addr + 0x1df -- one byte before wt definition
	function el:draw()
		local selected = (peek(addr) & el.bit) > 0
		rectfill(1,1,5,5,1)
		if (selected) rectfill(2,2,4,4,7)
		print(el.label, 10, 1, selected and 7 or 1)
	end
	function el:tap()
		poke(addr, peek(addr) ^^ el.bit)
		refresh_gui = true
	end
	return el
end


function create_channel_scope(i, x, y)
	local el={
		x=x,y=y,
		width=40, height=20
	}
	function el:draw()
		rectfill(0,0,self.width-1, self.height-1,0)
		if (something_is_playing) then
			local n = stat(400+i,19,0x90000)
			for xx=0,self.width-1 do
				local yy=10+peek2(0x90000+ xx*16)/3276
				pset(xx, yy, 16)
				yy=10+peek2(0x90002+ xx*16)/3276
				pset(xx, yy, pget(xx,yy)==0 and 24 or 30)
				
				
			end
		end
	end
	
	return el
end


function generate_gui_pattern()

	local pane = gui:attach(create_pane("\f6pattern "..cp,92,4,384+4,252,0x1001))
	
	pane.click = function() 
		focus = "pattern"
	end
	
	-- focus for copying / pasting
	focus = "pattern"

--[[ deleteme
	pane:attach(create_octave_chooser( 75,1))
	pane:attach(create_volume_chooser(145,1))
]]

	-- playback flow flag toggles: start, end, stop
	
	pane:attach(create_flow_toggle{
		x = 350, y = 1, bit = 0x1, icon = get_spr(58)
	})
	pane:attach(create_flow_toggle{
		x = 360, y = 1, bit = 0x2, icon = get_spr(59)
	})
	pane:attach(create_flow_toggle{
		x = 370, y = 1, bit = 0x4, icon = get_spr(60)
	})
	
	
	local container = pane:attach{
		x=0,y=24+22,width=pane.width,height=228-32,
		draw=function()	end -- to get clipping
	}
	

	local contents = container:attach{
		x=0, y=0, width=pane.width, height=521,
		draw = function()
			-- markers showing rows
			--[[
			fillp(0xf000)
			for i=0,7,2 do
				rectfill(0,i*64, 1000,i*64+64,16+i/2)	
			end
			fillp()
			]]
		end
		
	}
	
	pattern_contents = contents
	
	-- whole track for each channel
	local chan_mask = peek(0x30100 + cp * 20 + 9)
	track_seg_el = {}
		
	for i=0,7 do
	
		local sx = 2 + i*47
		local sy = 13
		local ww = 7
		
		-- drag and drop track index into a channel to assign it
		-- (callback on any channel-specific elements)
		local drop_track_index = function(self,msg)
			checkpoint()
			chan_mask |= (1 << i)
			poke(0x30100 + cp*20+9, chan_mask)
			poke(0x30100 + cp*20+i, msg.index)
			refresh_gui = true
		end
		
		
		if (chan_mask & (1 << i) > 0) then
			local tiny = pane:attach(
				create_tiny_num_field("",0x30100 + cp * 20 + i, sx+15, sy)
			)
			
			tiny.drop_track_index = drop_track_index
			
		else
			ww = 24
		end
		
		pane:attach(create_channel_scope(i, sx+2, sy+10))
		
		-- toggle channel bit
		pane:attach{
			x = sx+5, y = sy,
			width=ww, height = 7,
			draw=function(self)
				rect(0,0,6,6,5)
				if (chan_mask & (1 << i) > 0) then
					rect(0,0,6,6,16)
					rectfill(2,2,4,4,6)
				else
					rectfill(9,0,24,7, 0)
				end
				
			end,
			tap=function()
				chan_mask ^^= (1 << i)
				poke(0x30100 + cp*20+9, chan_mask)
				refresh_gui = true
			end,
			drop_track_index=drop_track_index
			
		}
		
		-- edit track
		pane:attach{
			x = sx+33, y = sy,
			width=ww, height = 7, cursor="pointer",
			draw=function(self)
				spr(23,0,0)
			end,
			tap=function()
				mode="track"
				ct=peek(0x30100 + cp * 20 + i)
				refresh_gui = true
			end
		}
	
		if (chan_mask & (1 << i) > 0) then
			track_seg_el[i] = contents:attach(create_track_segment{
				x= sx, y=0, rows=64,
				live_index = true,
				chan_i = i,
				index = peek(0x30100 + cp * 20 + i), -- track (sfx) index
				drop_track_index=drop_track_index
			})
		else
			-- dummy
			contents:attach{
				x=sx, y=0,
				width = 44, height = 64 * 8 + 2, -- match size in create_track_segment
				draw = function(self, msg)
					rectfill(0,0,self.width-1,self.height-1, 0)
					if (grabbed_track and
						msg.mx>=0 and msg.mx <self.width and msg.my >= 0 ) then
						rect(0,0,self.width-1,self.height-1, 10)
					end
					--rect(0,0,self.width-1,self.height-1, 5)
				end,
				drop_track_index=drop_track_index
			}
		end
		
		-- jump to channel pencil
	end
	
	container:attach_scrollbars()
	
	-- info at bottom
	pane:attach{
		x=3,y=244,width=80,height=10,
		draw=function()
			if (something_is_playing and following_playback) then
				local row = stat(400 + stat(467),9)
				print("playing row: "..flr(row),0,0,13)
			else
				local row = cur_y - (0x50000 + (ct * 328) + 8)
				print("row: "..flr(row),0,0,13)
			end
			
		end
		
	}
	

end


function create_play_button()
	local el = gui:attach{
		x=2,y=3,
		width=26,height=17,
		cursor="pointer"
	}
	
	function el:draw()
		rectfill(1,0,self.width-2,self.height-1,13)
		rectfill(0,1,self.width-1,self.height-2,13)
		spr(something_is_playing and 63 or 62,5,1)
	end
	
	-- use tap so that following_playback is not cancelled by click
	function el:tap()
		if something_is_playing then
			note()
		elseif mode == "instrument" then
			-- play insturment on channel 8
			-- will be release in _update()
			note(coct*12,ci,cvol,0,0, 8, true)
		elseif mode == "track" then
			sfx(ct)
		elseif mode == "pattern" then
			music(cp) following_playback = true
		end
	end
	
end


function set_mode(which)
	checkpoint()
	-- last_mode used to decide if space plays sfx or pattern (from inst editor)
	if (last_mode ~= mode) last_mode = mode 
	mode = which
	readtext(true) -- clear buffer
	refresh_gui = true
end

function generate_gui()

	ci = mid(0,ci,63)
	ct = mid(0,ct,383)
	cp = mid(0,cp,127)
	
	gui = create_gui()

	-- mode buttons; now redundant -- use chooser headers, or press tab
--[[	
	local mode_label={[0]="inst","sfx","pat"}
	local mode_name ={[0]="instrument","track","pattern"}
	
	for i=0,2 do
		gui:attach{
			x=2 + i*29,y=2+21,
			width=27,height=11,
			label=mode_label[i],
			mode=mode_name[i],
			draw=function(self)
				local sel = self.mode==mode
				rectfill(0,0,self.width-1,self.height-1, sel and 14 or 1)
				print(self.label,self.width/2 - #self.label*2, 3,sel and 7 or 13)
			end,
			tap=function(self)
				checkpoint()
				mode = self.mode
				readtext(true) -- clear buffer
				refresh_gui = true
			end
		}
	end
]]
	-- play button
	
	create_play_button()
	
	-- octave and volume choosers
	
	gui:attach(create_octave_chooser(47,3))
	gui:attach(create_volume_chooser(47,13))
	
	local yy = 37-14
	local ww = 86 
	local pcol = mode == "instrument" and 0x0e01 or 0x0701
	local el = gui:attach(
		create_pane("instruments",2,yy,ww,63+14, pcol,
		function() set_mode("instrument") end))

	--[[ 
		--pencil to show can click to enter instrument mode? not consistent
		-- can can double click anyway
		el:attach{x=78,y=1,width=7,height=7,
			cursor="pointer",
			draw=function()spr(23,0,0)end
		}
	]]
	create_instrument_chooser(el)
	yy += el.height + 4
	
	pcol = mode == "track" and 0x0e01 or 0x0701
	local el = gui:attach(create_pane("sfx",2,yy,ww,76,pcol,
		function() set_mode("track") end))
	create_track_chooser(el)
	yy += el.height + 4
	
	pcol = mode == "pattern" and 0x0e01 or 0x0701
	local el = gui:attach(create_pane("patterns",2,yy,ww,72,pcol,
		function() set_mode("pattern") end))
	create_pattern_chooser(el)
	

	if (mode == "instrument") generate_gui_instrument()
	if (mode == "track")      generate_gui_track()
	if (mode == "pattern")    generate_gui_pattern()
	
end


function add_instrument_attributes(parent)

	-- instrument attributes (put inside node_content -- can scroll out)
	
	inst_name_editor = parent:attach_text_editor{
		x=24, y=1,
		width = 72, height=7,
		bgcol = 1, fgcol = 6, curcol = 8,
		block_scrolling = true, max_lines = 1,
		margin_top = 1,
		key_callback = {
			enter = function () 
				set_inst_name(ci,inst_name_editor:get_text()[1])
				inst_name_editor:set_keyboard_focus(false)
			end
		},
		update = function(self)
			-- update in realtime -- don't need to press enter to change
			if (inst_name_editor:has_keyboard_focus()) then
				set_inst_name(ci,inst_name_editor:get_text()[1])
			end
		end
	}
	inst_name_editor:set_text{get_inst_name(ci)}
	
	parent:attach(create_inst_flag_toggle{
		x = 110, y = 1,
		bit = 0x1,
		label = "retrig" -- means: "always retrigger when inst is given in row"
	})
	
	parent:attach(create_inst_flag_toggle{
		x = 154, y = 1,
		bit = 0x2,
		label = "wide" -- means: "can vary panning of depth:1 osc nodes"
	})
	
end


function generate_gui_instrument()
	
	-- add nodes to a scrollable area
	
	local node_container = gui:attach{
	
		x = 92, y = 0, width = 300, height = 252,

		mousewheel = function(self, msg)
			self.child[1].y += msg.wheel_y * 16
			self.child[1].y = mid(0, self.child[1].y, self.height - self.child[1].height)
			last_node_content_inst = ci
			last_node_content_y = self.child[1].y
		end,
		
		drag = function(self, msg)
			self.child[1].y += msg.dy
			self.child[1].y = mid(0, self.child[1].y, self.height - self.child[1].height)
			last_node_content_inst = ci
			last_node_content_y = self.child[1].y
		end,
		
		update = function(self)
			--if (self.child[1]) self.child[1].y += 1
		end
	}
	
	local node_content = node_container:attach{
		x=0,y=0,width=node_container.width,height=300
	}
	
	local yy = 4
	node_depth={}
	node_parent_index={}
	
	
	-- calculate node depth first
	-- (needed to decide when to create sibling shuffle buttons)
	for i=0,7 do
		local inst_addr = 0x40000 + ci*0x200
		local node_addr = inst_addr + i*0x20
		local node_type = peek(node_addr+1) & 0xf
		local node_parent = peek(node_addr+0) & 0x7
		
		node_depth[i] = node_depth[node_parent] and node_depth[node_parent]+1 or 0
		node_parent_index[i] = node_parent
		if (node_type == 0) node_depth[i] = -1
	end
	
	for i=0,7 do
	
		local inst_addr = 0x40000 + ci*0x200
		local node_addr = inst_addr + i*0x20
		local node_type = peek(node_addr+1) & 0xf
		local node_parent = peek(node_addr+0) & 0x7
		
		local x0 = node_depth[i] * 8
	
		if (node_type > 0) then
			local n = create_node_editor(node_content, i, x0, yy, node_depth[i])
--[[ deleteme
			if (i == 0) then
				n:attach(create_octave_chooser(80,1))
				n:attach(create_volume_chooser(145,1))
			end
]]
			if (i==0) add_instrument_attributes(n)	
			
			yy += n.height + 4
		end
		
		node_content.height = max(yy + 16, node_container.height)
		
		
	end
	
	
	-- envelope container
	-- (dupe from node_container)

	local env_container = gui:attach{
	
		x = 396, y = 0, width = 84, height = 250,

		mousewheel = function(self, msg)
			self.child[1].y += msg.wheel_y * 16
			self.child[1].y = mid(0, self.child[1].y, self.height - self.child[1].height)
			last_env_content_inst = ci
			last_env_content_y = self.child[1].y
		end,
		
		drag = function(self, msg)
			self.child[1].y += msg.dy
			self.child[1].y = mid(0, self.child[1].y, self.height - self.child[1].height)
			last_env_content_inst = ci
			last_env_content_y = self.child[1].y
		end,
		
		update = function(self)
			--if (self.child[1]) self.child[1].y += 1
		end
	}
	

	-- envelopes
	
--	local env_content = gui:attach{
--		x=396,y=0,width=100,height=300
--	}
	local env_content = env_container:attach{
		x=0,y=0,width=env_container.width,height=400
	}
	
	local yy = 4
	for i=0,4 do -- 0.1.0h: 5 envelopes fit nicely; usually enough?
		local inst_addr = 0x40000 + ci*0x200
		local env_addr = inst_addr + 256 + i * 24
		local e = env_content:attach(create_env_editor(i,env_addr,"env-"..i,0,yy,80))
		yy += e.height + 4
	end
	
	env_content.height = max(yy + 16, env_container.height)
	
	-- preserve node content scroll position
	-- to do: find a less silly way to do this
	if (last_node_content_inst == ci) then
		node_content.y = last_node_content_y
	end
	if (last_env_content_inst == ci) then
		env_content.y = last_env_content_y
	end
	
end


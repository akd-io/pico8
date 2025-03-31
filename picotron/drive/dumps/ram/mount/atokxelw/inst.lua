--[[pod_format="raw",created="2023-10-27 18:16:38",modified="2024-09-12 16:58:56",revision=9459]]

function get_inst_name(i)
	local inst_addr = 0x40000 + i*0x200
	local len = 16
	for j=15,0,-1 do
		if (peek(inst_addr+496+j) == 0) len = j
	end
	return chr(peek(inst_addr+496,len))
end

function set_inst_name(i, str)
	local inst_addr = 0x40000 + i*0x200
	memset(inst_addr+496,0,16)
	poke(inst_addr+496,ord(str,1,min(16,#str)))
end



-- 0x1702
local node_type_col = {
	[0]=0x1,0x0e05,0x0705,0x5,
	0,0,0,0,
	0x0c05,0x0c05,0x0c05,0x0c05,
	--0x1105,0x0c05,0x1905,0x0805,
}

-- labels: max 5 chars (4 preferred)

function create_mval_knob(label,node_type,mval_index,addr,x,y)

	local el = {
		x = x, y = y, 
		width = 54, -- includes the number box; and envelope connection
		height = 20,
		label=label,
		addr=addr,
		mval_index=mval_index,
		v0 = -128, v1 = 127, -- editable range for signed values
		vz = 0, -- "zero" -- where to fill pie from / until
		ac = 1, -- angle coefficient (notch angle)
		a0 = 0.0,
		-- cursor = "grab", -- to do: shouldn't set cursor while drag outside of element
		node_col = node_type_col[node_type],
		click = checkpoint,
		dval = 0,
		cursor = "dial"
		--cursor="grab" -- to do: dial spinning cursor that disappears
	}
	
	if (label == "vol") el.v0, el.v1 = 0, 64
	
	-- maybe later
	--if (label == "tune") el.v0,el.v1 = -120, 120 el.ac = 20 el.a0 = 0.5
	if (label == "wave") el.v0,el.v1 = 0, 255
	
	-- fx parameters are all 0..255 (flag 0x8 is not set)
	if (node_type >= 8) el.v0,el.v1 = 0, 255
		
	-- gain mix; can use *8 if want to over mix!
	if (label == "mix") el.v0, el.v1 = 0, 64
	
	function el:drop_env_plug(msg)
		checkpoint()
		--printh("setting "..pod(msg))
		poke(addr+3, (peek(addr+3) & ~0xf) | msg.index)
		--set observe_envelope bit
		poke(addr, peek(addr) | 0x4)
	end
	
	function el:update(msg)
		if (not (msg.mx and msg.my)) return -- to do: should that ever happen?
		self.cursor = (msg.mx < 18) and "dial" or "pointer"
	end
	
	function el:draw(msg)
	
		--rectfill(0,0,1000,1000,8+addr/4)
			
		local xx,yy = 8.5,6.5
		
		circfill(xx-1,yy+1,7,(self.node_col&0x5 == 5) and 1 or 21)
		circfill(xx,yy,7,0)
		
		-- draw mval	
		local flags,val1,val0,env = peek(addr,4)
		local num = 1 + val1 % 16
		local den = 1 + val1 \ 16
		
		
		if (el.v1 < 128) then -- signed int8's
			if (val1 >= 128) val1 -= 256
			if (val0 >= 128) val0 -= 256
		end
		
		local range = self.v1 - self.v0
		
		-- 0.7 - 0.9 * ..
		--local p0,p1 = 0.7,0.9 -- wedge at bottom
		local p0, p1 = 0.75, 1.0 
		
		
		local a0 = self.a0 + p0 - p1 * (val1 - self.v0) * self.ac / range
		
		local a1 = p0 - p1 * (val0 - self.v0) / range
		
		
		--local a1 = self.a0 + p0 - (self.vz - self.v0) * self.ac * p1 / range
	
		-- show range (to do: decide on flags for that)
		color (peek(self.addr) & 0x4 > 0 and 12 or 14)
		
		-- ** to do: optimise **
		if (false) then  
			for k=0,1,1/(abs(a1-a0)*32) do
				local aa = a1+(a0-a1)*k
				line(xx,yy,xx+cos(aa)*6, yy+sin(aa)*6)
			end
		end
		
		-- dotty arc version

		local aa0,aa1 = a0, a1
		if (aa0 > aa1) aa0,aa1 = aa1,aa0
		for aa = -.25, .75, 1/32 do
			if (aa >= aa0 and aa <= aa1) then
				pset(xx+cos(aa)*5, yy+sin(aa)*5)
			end
		end		
		
		line(xx+cos(a0)*2, yy+sin(a0)*2, xx+cos(a0)*6, yy+sin(a0)*6, 7)

		clip()
		print(self.label, -20,4,6)
		
		rectfill(xx+7,2,xx+36,10,0)
		
		-------------------------------------------
		--   envelope assignment plug to right   --
		-------------------------------------------
		
		if (peek(self.addr) & 0x4 > 0) then
			rectfill(xx+37,2,xx+44,10,7)
			rectfill(xx+37,3,xx+45,9,7)
			
			if (peek(self.addr) & 0x8 > 0) then
				print(peek(self.addr+3)&0xf, xx+40, 3, 12)
				print("\^:1500000000000000",xx+39,9,12) -- 3 dots
			else
				print(peek(self.addr+3)&0xf, xx+40, 4, 12)
			end
		else
			-- choose randomly from range
			if (peek(self.addr) & 0x10 > 0) then
				rectfill(xx+37,2,xx+44,10,14)
				rectfill(xx+37,3,xx+45,9,14)
				print("r", xx+40, 4, 7)
			end
		end
		
		-------------------------------------------
		--      scale underneath at right        --
		-------------------------------------------
		
		local sval = peek(self.addr+3)
		
		if (sval & 0xc0 > 0) then

			str2 = (sval & 0x20 == 0) and 
				"\^:5020500000000000" or  -- *
				"\^:4020100000000000"     -- /
			
			if (sval & 0xc0 == 0x40) str2 ..= "\^:5070400000000000" -- 4
			if (sval & 0xc0 == 0x80) str2 ..= "\^:1372770000000000" -- 16
			if (sval & 0xc0 == 0xc0) str2 ..= "\^:5177470000000000" -- 64
			
			--rectfill(xx+24,11,xx+36,15,13)
			print(str2, xx+20,12,7)
		end
		
		-------------------------------------------
		--     value and parent relationship     --
		-------------------------------------------
		
		if (flags & 0x3 > 0) then
			local letter = "?"
			if (flags & 0x3 == 0x1) letter = "+"
			if (flags & 0x3 == 0x2) letter = "*"
			print(letter,35-4*4,4,3)
		end
		
		-- show value
		local str, str_col = tostr(val1), 27
		
		if (msg.mb == 2 and msg.has_pointer and
			 msg.mx <= 44 and msg.my <= 12) then
			str = tostr(val0)
			str_col = 14
		end
		
		if (flags & 0x3 == 2 and label=="tune") then
			-- multiply by ratio
			-- only makes sense for pitch
			str = num.."/"..den
		end
		
		-- everything else: show raw value
		print(str, xx+35-#str*4, 4, str_col)
		
		circ(xx,yy,7,13)--self.node_col&0xff)
		--circ(xx,yy,8,node_col&0xff)
		
		
	end
	
	-- turn mouse locking on while dragging (and set undo checkpoint)
	function el:click(msg)
		mouselock(0x4|0x8, 0.5, 0.05) -- 0x4 lock 0x8 auto-release, event speed, move speed 
		checkpoint()
	end
	
	function el:drag(msg)
		local flags,val1,val0,env = peek(addr,4)
	
		local dval = (msg.dx - msg.dy)
		
		if (self.label=="tune" and (flags & 3) == 2) then
			-- special case: use u8 for integer fraction mode
			val1 = mid(0, val1 + dval, 255)
		else
			-- signed int8 behaviour
			if (el.v1 < 128) then 
				if (val0>=128) val0 -= 256
				if (val1>=128) val1 -= 256
			end
			
			if (msg.mb > 1) then
				-- drag val0 (start of range)
				val0 = mid(self.v0, val0 + dval, self.v1)
			else
				-- regular white needle dragging
				val1 = mid(self.v0, val1 + dval, self.v1)
			end	
		
		end
		
		poke(addr+1,val1)
		poke(addr+2,val0)
		return 1 -- don't drag the node content
	end
	
	function el:tap(msg)
		checkpoint()
		local flags,val1,val0,env = peek(addr,4)
		
		-- use same gui el / can still grab and drag value without
		-- having to avoid the operator area. usually operator stays
		-- untouched, so preferable to have a little friction to change it.
		
		if (msg.my > 11 and msg.mx > 34) then
			-- change scale bits
			local ctrl_held = key("ctrl")
			local val = peek(addr+3) & 0xe0
			if (val == 0)        then val = 0x00 | 0x40 -- *4
			elseif (val == 0x40) then val = 0x20 | 0x40 -- /4
			elseif (val == 0x60 and ctrl_held) then val = 0x00 | 0x80 -- *16
			elseif (val == 0x80 and ctrl_held) then val = 0x20 | 0x80 -- /16
			elseif (val == 0xa0 and ctrl_held) then val = 0x00 | 0xc0 -- *64
			elseif (val == 0xc0 and ctrl_held) then val = 0x20 | 0xc0 -- /64
			else val = 0 end
			poke(addr+3,(peek(addr+3) & ~0xe0) | val)
		elseif (msg.mx >= 18 and msg.mx <= 24) then
		
			-- change parent operator
			
			if node_type >= 8 and self.label ~= "res" and self.label ~= "mix" then
				-- filter:res and shape:mix can multiply with parent.
				-- any other fx filter mvals shouldn't have any parent operators
				poke(addr, flags & ~0x3)
			elseif (flags & 0x3 > 0) then
				if (self.label == "tune") then
					poke(addr, (flags & ~0x3) | ((flags & 2 > 0) and 0 or 2))
				else
					poke(addr, flags & ~0x3) -- clear add / mult bit
				end
			else
				if (self.label == "vol" or self.label == "mix" or self.label == "res")
				then
					-- set bit: mult parent
					poke(addr, flags | 0x2)
				else
					-- set bit: add parent
					poke(addr, flags | 0x1)
				end
			end
		elseif (msg.mx >= 45) then
			-- toggle envelope assignment bit
			-- mb2 to toggle continuation
			if (peek(addr) & 0x4 > 0 or msg.last_mb == 1) then
				poke(addr, peek(addr) ^^ (msg.last_mb == 1 and 0x4 or 0x8))
			else
				-- toggle rnd
				poke(addr, peek(addr) ^^ 0x10)
			end
		else
			-- set val0 to val?
			-- nah -- just always drag mb2
			-- poke(addr+2,val1)
		end
	end
	
	
	return el
end

function get_mval_scale(addr)
	local val = @addr
	local bits = 0
	if (val & 0xc0 == 0) return 1
	if (val & 0x40 >  0) bits += 2
	if (val & 0x80 >  0) bits += 2
	return (val & 0x20) > 0 and 1/(1<<bits) or (1<<bits)
end


-- address is of the wavetables
function create_scope(addr, node_index, x, y, w, h)
	local el = gui:attach{
		x=x,y=y,
		width=w, height=h,
		addr=addr,
		bmp=userdata("u8",w,h),
		dither_t = 7,
		refresh = true
	}
	function el:click(msg)
		checkpoint()
		local inst_addr = 0x40000 + ci*0x200
		local node_addr = inst_addr + node_index*0x20
		local wt_index = peek(node_addr+1)>>4
		
		if (msg.mx < 18 and msg.my < 10) then
			wt_index = (wt_index + 1) % 4
			poke(node_addr+1, (peek(node_addr+1) & ~0xf0) | (wt_index << 4))
		end
	end
	
	function el:draw(msg)
	
		self.dither_t = (self.dither_t + 1) % 8

		set_draw_target(self.bmp)
		camera() -- to do: should camera get reset the same way as clipping?
		
		-- grab instrument attributes
		local inst_addr = 0x40000 + ci*0x200
		local node_addr = inst_addr + node_index*0x20
		local node_type = peek(node_addr+1) & 0xf
		local wave_addr = node_addr + 4 + 4*4
		local wave_val  = peek(wave_addr+1)
		
		-- wavetable
		local wt_index = (peek(node_addr+1)>>4)
		local wt_addr = el.addr + wt_index * 4
		local addr0, addr1, width_bits, wt_height = peek(wt_addr,4)
		local dat_addr = (addr0 << 8) | (addr1 << 16)
		local wt_width = 1 << width_bits
		
		dat_addr += (wave_val * wt_height >> 8) * wt_width*2
		
		local phase_addr = node_addr + 4 + 5*4
		local phase_val  = (peek(phase_addr+1) + 128) % 256 - 128
	
		local stretch_addr = node_addr + 4 + 5*4
		local stretch_val  = 0--peek(stretch_addr+1)
		
		if (stretch_val >= 128) stretch_val -= 256
		stretch_val = (stretch_val + 128) / 128 -- 0..2
		
	
		local vol_addr = node_addr + 4 + 0*4
		local vol_val  = peek(vol_addr+1)
		
		-- decide when to redraw scope;
		-- at least 8pfs, or every frame when mouse is down
		local refresh_scope =  msg.mb > 0 or self.dither_t==node_index
		if (self.refresh) refresh_scope = true self.refresh = false
		if (self.sy>270 or self.sy < -h) refresh_scope = false -- not visible
		--
		
		if (refresh_scope) self.bmp:clear()
		
		if (not refresh_scope) then
			-- nothing happening (mouse button up): update 4fps
			
		elseif (node_type == 2 and not something_is_playing) then
			-- osc when nothing is playing: visualise waveform
			line()
			self.bmp:clear()
			--for i = self.dither_t, self.width-1, 4 do
			for i = 0, self.width-1,.5 do
			
				local samx = i / self.width
				samx += phase_val/256
				samx = (samx * stretch_val) % 1
				
				local i2 = flr(samx * wt_width)
				local val = peek2(dat_addr + i2*2)
				val *= (vol_val/0x40)
				
				local xx = i
				local yy = self.height/2 - val * self.height/72000
				--line(xx,yy,11)
				pset(xx,yy, pget(xx,yy) == 3 and 11 or 3)
				--poke(0x540a,0,0)
				--line(xx,0,xx,h,0)
				--pset(xx,yy,11)
			end
			
			print("wt-"..wt_index,2,2,3)
		elseif (node_type == 8) then
			local low    = peek(node_addr + 4 + 0*4 + 1) / 255.0
			local high   = peek(node_addr + 4 + 1*4 + 1) / 255.0
			local res    = peek(node_addr + 4 + 2*4 + 1) / 255.0
			
			-- to do: calculate cutoff in Hz or something?
	
		elseif (node_type == 9) then
			local delay   = peek(node_addr + 4 + 0*4 + 1)
			local vol     = peek(node_addr + 4 + 1*4 + 1) / 255.0
			local ww = self.width \ 7
			local hh = self.height - 4
			for i=0,6 do
				 local xx=2+ww*i
				 rectfill(xx+1,self.height-2,xx+ww-2,self.height-2-hh,12)
				 hh *= vol
			end
		elseif (node_type == 10) then
		
			local gain  = peek(node_addr + 4 + 0*4 + 1) * 7.0 / 255.0
			gain = 1.0 + gain * get_mval_scale(node_addr + 4 + 3)
			
			local elbow = peek(node_addr + 4 + 1*4 + 1) / 255.0
			elbow *= get_mval_scale(node_addr + 4 + 1*4 + 3)
			
			local cut   = 1.0 - peek(node_addr + 4 + 2*4 + 1) / 255.0
			local mix   = peek(node_addr + 4 + 3*4 + 1)
			local ww = self.width
			local hh = self.height
			
			
			fillp(0x5555)
			line(0, hh - cut * hh, ww, hh - cut * hh, 13)
			fillp()
			
			local elbow_y = cut
			local elbow_x = elbow_y / gain
			local slope = 0
			
			if (elbow_x == 1.0) then
				slope = 0
			elseif (elbow < 0.5) then
			
				local tt = elbow * 2
				local slope0 = (gain-elbow_y) / (1-elbow_x)
				local slope1 = (1-elbow_y) / (1-elbow_x)
				slope = (1-tt) * slope0 + (tt * slope1)
			else
				local tt = (elbow-.5)*2
				local slope0 = (1-elbow_y) / (1-elbow_x)
				slope = (1-tt) * slope0
			end
			
			for i = 0,self.width-1, .5 do
				local tt = i / self.width
				local val=0
				
				if tt < elbow_x then
					val = tt*gain
				else
					if elbow < 1 then
						val = elbow_y + (tt-elbow_x)*slope
					else
						-- foldback \m/
						local e2 = elbow-1
						local h2 = elbow_y / 2
						--val = h2 + cos((tt-elbow_x)*e2) * h2
						-- 0.1.0h: linear reflection
						val = ((tt-elbow_x)*e2)%1
						val = ((val < 0.5) and 1-val*4 or -1 + (val-0.5)*4)
						val = h2 + val * h2
					end
				end
				
				local xx = i
				local yy = self.height - val * self.height
			
				pset(xx,yy, pget(xx,yy) == 3 and 11 or 3)
			end
		else
			
			--------- live output ----------
			
			ci_channel = 8 -- ** assume channel 0
			
			if (ci_channel < 0) return -- don't know which channel [yet?] -- skip
			
			-- tick_len is never larger than 4k
			local tick_addr = 0x200000 + node_index * 8192
			
			local tick_len = stat(400 + ci_channel, 8)
	
			-- grab at 15fps (perf + so is readble)
			--if ((global_t + node_index) & 3 == 0 and (not msg.has_pointer or msg.mb==0)) 
			if (true)
			then
				tick_len = stat(400 + ci_channel, 20 + node_index, tick_addr)
			end
			
			for i = 0,self.width-1 do
				local i2 = i\.5 -- 2 samples per pixel
				local val = peek2(tick_addr + i2*2)
				local yy = self.height/2 - val * self.height/72000
				--pset(i,yy, pget(i,yy) == 3 and 11 or 3)
				pset(i,yy,11)
			end
		end
		
		set_draw_target()
		blit(self.bmp,nil,0,0,self.sx,self.sy)
		
	end
	return el
end	


function create_muted_node_toggle(addr,x,y)
	local el = { 
		addr = addr,
		x = x, y = y, width = 7, height = 7
	}
	function el:draw(msg)
		local yy = (msg.has_pointer and msg.mb > 0) and 1 or 0
		local val = (@self.addr) & 0x2
		clip()
		pal(7,1)
		spr((val & 0x2 > 0) and 57 or 56,0,0+yy)
		pal()
	end
	function el:tap()
		checkpoint()
		local val = peek(self.addr)
		val ^^= 0x2
		poke(self.addr, val)
		--refresh_gui = true
	end
	
	return el
end


function delete_node(index)
	local tr = read_node_tree(0x40000 + ci*0x200, 0, nil)
	checkpoint()
	-- op here
	local n, i = get_node_by_index(index, tr)
	local p = n.parent
	deli(p.child, i)
	
	-- write back out
	memset(0x40000 + ci*0x200, 0, 0x20 * 8)
	write_node_tree(0x40000 + ci*0x200, tr, 0, 0)
	refresh_gui = true
end


function create_child_node(parent_index, node_type, is_modulator, copy_from_parent)

	if (peek(0x40000 + ci*0x200 + 7 * 0x20 + 1) > 0) then
		notify("too many nodes (max: 8)")
		return
	end
	
	local tr = read_node_tree(0x40000 + ci*0x200, 0, nil)
	checkpoint()
	
	
	local p = get_node_by_index(parent_index, tr)
	
	-- create node item with default data
	
	local n = { content = userdata("u8",0x20), parent = p, child = {} }
	-- dummy; parent index is calculated at end when writing out tree
	local parent_index = p.index
	
	if (node_type == 0x2 and is_modulator) then
		set(n.content, 0,
			parent_index | 16,
			node_type, 0, 0,
			0x0,0x20,0,0,  -- volume:absolute
			0x0,0,0,0,     -- pan:  not used
			0x1,0,0,0,     -- tune: parent+0 -- not quantized
			0x1,0,0,0,     -- bend: parent+0
			0,0,0,0,       -- waveform
			0x0,0,0,0      -- phase
		)
	elseif (node_type == 0x2) then
		set(n.content, 0,
			parent_index, node_type, 0, 0,
			0x2,0x20,0,0,  -- volume: mult. 0x40 is max (-0x40 to invert, 0x7f to overamp)
			0x1,0,0,0,     -- pan:  parent+0
			0x21,0,0,0,    -- tune: parent+0   0x20 quantized;
			0x1,0,0,0,     -- bend: parent+0
			0,0,0,0,       -- waveform
			0x0,0,0,0      -- phase
		)
		
	else
		-- fx: no parent ops
		set(n.content, 0,
			parent_index, node_type, 0, 0
			-- all zero: fx knobs are all uint8, so don't need 0x8 flags set
		)
		-- ..except for fx:filter
		set(n.content, 4+2*4, 0x2)
	end
	
	-- copy data from parent when both are osc
	if (copy_from_parent) then
		set(n.content, 4,
			peek(0x40000 + ci*0x200 + parent_index*0x20 + 4, 28)
		)
	end
	
	-- add it to tree (at end of children) and write tree back out
	add(p.child, n)
	
	memset(0x40000 + ci*0x200, 0, 0x20 * 8)
	write_node_tree(0x40000 + ci*0x200, tr, 0, 0)
	refresh_gui = true
	
end


local node_op_str={
	[0]="carrier","fm mod","ring mod", "xor","or"
}
function create_op_toggle(addr,x,y)
	local el = { 
		addr = addr, cursor="pointer",
		x = x, y = y, width = 40, height = 7
	}
	function el:draw(msg)
		local yy = (msg.has_pointer and msg.mb > 0) and 1 or 0
		local val = (@self.addr) >> 4
		clip()
		pal(7,1)
		rectfill(0,0+yy,self.width-1,6+yy,msg.has_pointer and 14 or 6)--6+val*3)
		--spr(val,1,1+yy)
		print(node_op_str[val],2,1+yy,1)
		pal()
	end
	function el:click()
		checkpoint()
		local val = peek(self.addr) >> 4
		if (val > 0) then
			val = val == 1 and 2 or 1
			poke(self.addr, (peek(self.addr) & 0xf) | (val << 4))
		end
		--refresh_gui = true
	end
	
	return el
end

local node_fx_str={
	[8]="filter",[9]="echo",[10]="shape", [11]="crush"
}
function create_fx_type_toggle(addr,x,y)
	local el = { 
		addr = addr,
		x = x, y = y, width = 40, height = 7
	}
	function el:draw(msg)
		local yy = (msg.has_pointer and msg.mb > 0) and 1 or 0
		local val = (@self.addr) & 0xf
		clip()
		pal(7,1)
		rectfill(0,0+yy,self.width-1,6+yy,msg.has_pointer and 14 or 6)
		--spr(val,1,1+yy)
		print(node_fx_str[val],2,1+yy,1)
		pal()
	end
	function el:click()
		checkpoint()
		local val = peek(self.addr)
		val = 8 + (((val-8) + 1) % 3) -- only need filter, echo, gain
		poke(self.addr, (peek(self.addr) & 0xf0) | (val & 0x0f))
		refresh_gui = true
		
		-- reset parent operator bits to defaults (0 except for FX:FILTER:RES)
		for i=0,6 do
			local mval_addr = self.addr + 3 + i*4 -- first byte of mval (flags)
			poke(mval_addr, peek(mval_addr) & ~0x03) -- strip low 2 bits (op)
			-- only FX:FILTER:RES (type 8, node 2) has MF_MUL_PARENT set
			if (i == 2 and val == 8) poke(mval_addr,peek(mval_addr) | 0x2)
		end
	end
	
	return el
end


local node_type_str={
[0]="none", "","osc:","alias", -- root has no label -- put instrument name there
"","","","",
"fx:","fx:","fx:","fx:"
}

local mval_dat = {
	{"vol","pan","tune","bend","p0","p1"},
	{"vol","pan","tune","bend","wave","phase"},
	nil,
	nil,nil,nil,nil,
	-- really want fx boxes to be tiny and specialized
	-- (and to cost nodes! -- they are generally expensive on host)
	-- to do: standard "clip" for all fx nodes
	-- 0..127 means clip to max..osc_vol  128..255 means clip to osc_vol..0
	{"low","high","res"},
	{"delay","vol"},
	{"gain","elbow","cut","mix"},
	{"resx","resy","lpf"}, -- can adjust the sample rate, sample precision
}

function get_node_by_index(index, tr, childi)
	if (tr.index == index) return tr, childi
	for i=1,#tr.child do
		local res, childi = get_node_by_index(index, tr.child[i], i)
		if (res) then
			return res, childi
		end
	end
	return nil
end


function read_node_tree(addr, index, parent)
	local tr = {parent = parent}
	
	tr.content = userdata("u8", 32)
	tr.index = index -- the original index before transformation
	tr.content:set(0, peek(addr + index * 0x20, 0x20))
	tr.child = {}

	-- add children if they exist
	for i=index+1,7 do
		--printh(" looking for child at i "..i.."  parent:"..peek(addr + i*0x20))
		if (peek(addr + i*0x20) & 0xf) == index -- parent is given index
			and peek(addr + i*0x20 + 1)&0xf > 0 -- non-empty node
		then
			add(tr.child, read_node_tree(addr, i, tr))
		end
	end	

	return tr
end

function write_node_tree(addr, tr, index, parent_index)
	if (tr.content[1] & 0xf == 0) return index -- type:none
	if (index >= 8) return index -- safety: too many nodes
	
	--printh("writing node "..index.." content:"..pod(tr.content,0))
	
	poke(addr + index * 0x20, get(tr.content))
	
	-- update parent index. (everything else is the same)
	poke(addr + index * 0x20,
		(peek(addr + index * 0x20) & 0xf0) | parent_index)
	
	local child_parent = index
	index += 1
	for i=1,#tr.child do
		index = write_node_tree(addr, tr.child[i], index, child_parent)
	end			
	return index
end

function print_node_tree(tr, depth)
	printh(depth.." @ "..tr.index.." "..pod(tr.content))
	for i=1,#tr.child do
		print_node_tree(tr.child[i],depth+1)
	end
end
	
-- read everyhting into a tree, modify the tree, then write back out.
function swap_node_branches(n0, n1)
	local tr = read_node_tree(0x40000 + ci*0x200, 0, nil)
	
	

	-- check can write back same as read in	
	-- if (1) write_node_tree(0x40000 + ci*0x200, tr, 0, 0) return
	
	local n0, i0 = get_node_by_index(n0, tr)
	local n1, i1 = get_node_by_index(n1, tr)
	
	if (not n0 or not n1) printh("@@@ could not find nodes") return
	
	local p = n0.parent
	
	checkpoint()
	--printh("before swap") print_node_tree(tr, 0)
	
	p.child[i0], p.child[i1] = p.child[i1], p.child[i0]
	
	-- printh("after swap") print_node_tree(tr, 0)
	memset(0x40000 + ci*0x200, 0, 0x20 * 8)
	write_node_tree(0x40000 + ci*0x200, tr, 0, 0)

	refresh_gui = true
end


function move_sibling_node(index, dir)
	
	if (dir == 0) then
		-- check there is another sibling at same level
		for i=1,7 do
			if i ~= index and node_parent_index[i] == node_parent_index[index]
			then
				return true -- some siblings
			end
		end
		return false -- no need for sibling shuffle button
	end
	
	local target = -1
	if dir < 0 then
		-- find previous sibling
		for i = index-1,1,-1 do
			if (node_depth[i] == node_depth[index] and target == -1) target = i
		end
	else
		-- find next sibling
		for i = index+1, 7 do
			if (node_depth[i] == node_depth[index] and target == -1) target = i
		end
	end
	
	if (target == -1) return -- couldn't move
	
	-- swap siblings
	swap_node_branches(target, index)
	
end

function create_node_editor(parent, node_index, x, y, depth)

	local inst_addr = 0x40000 + ci*0x200
	local node_addr = inst_addr + node_index*0x20
	local node_type = peek(node_addr+1) & 0xf
	local node_op = peek(node_addr) >> 4
	
	local labels = mval_dat[node_type] or {}
	
	local width = 240
	
	local rows = 3
	if (node_type == 1) rows=2
	if (node_type >= 8) rows=2 --width = 118
	
	local height = 20 + rows * 16
	
	
	
	local desc = node_type_str[node_type] or "??"
	if (desc == "") desc = string.format("%02x", ci)
	--if (node_type == 2) desc ..= " "..(node_op_str[node_op] or "??")
	
	local head_col = node_type_col[node_type]
	if (node_type == 2 and node_op > 0) head_col = 0xd05

	local el = parent:attach(create_pane("  "..desc, x, y, width, height, head_col))
		
	-- active / not active toggle
	el:attach(create_muted_node_toggle(node_addr+2, 3,1))
	
	-- operator button for oscillator children
	if (node_type == 2) then
		el:attach(create_op_toggle(node_addr, 34,1))
	end
	
	if (node_type >= 8) then
		el:attach(create_fx_type_toggle(node_addr+1, 30,1))
	end
	
	
	-- child creation buttons for oscillators / root
	if (node_type < 4) then
		local xx=el.width-72 
		if (node_type == 1) xx += 30
		if (node_type != 1) xx -= 20 -- not root: make space for sibling order buttons
		
		if (node_type == 2) then -- +mod only for carrier osc
		xx += el:attach{
			x=xx,y=1,width=19,height=7,cursor="pointer",
			draw = function(this,msg)
				rectfill(0,0,this.width,this.height,msg.has_pointer and 23 or 6) 
				print("+mod",2,1,5)
			end,
			tap = function() create_child_node(node_index,2,true) end
		}.width+2
		end
		xx+=el:attach{
			x=xx,y=1,width=19,height=7,cursor="pointer",
			draw = function(this,msg)
				rectfill(0,0,this.width,this.height,msg.has_pointer and 23 or 6) 
				print("+osc",2,1,5)
			end,
			tap = function() create_child_node(node_index,2, nil, true) end
		}.width+2
		
		xx+=el:attach{
			x=xx,y=1,width=15,height=7,cursor="pointer",
			draw = function(this,msg)
				rectfill(0,0,this.width,this.height,msg.has_pointer and 23 or 6) 
				print("+fx",2,1,5)
			end,
			tap = function() create_child_node(node_index,8) end
		}.width+2
	end
	
	if (node_type != 1) then
		-- sibling reordering
		local xx=el.width-30
		
		-- move up
		if (move_sibling_node(node_index,0)) then
			xx += el:attach{
				x=xx,y=1,width=7,height=7,cursor="pointer",
				draw = function(this,msg)
					rectfill(0,0,this.width,this.height,msg.has_pointer and 23 or 6) 
					print("\^:00040e1f00000000",1,1,13)
				end,
				tap = function() move_sibling_node(node_index, -1) end
			}.width+2
	
			xx += el:attach{
				x=xx,y=1,width=7,height=7,cursor="pointer",
				draw = function(this,msg)
					rectfill(0,0,this.width,this.height,msg.has_pointer and 23 or 6) 
					print("\^:001f0e0400000000",1,1,13)
				end,
				tap = function() move_sibling_node(node_index, 1) end
			}.width+2
		end
	end
	
	-- delete node
	if (node_type > 1) then
	el:attach{
		x=el.width-10,y=1,width=8,height=7,cursor="pointer",
		draw = function(this,msg)
			rectfill(0,0,this.width,this.height,msg.has_pointer and 8 or 6) 
			print("X",2,1,5)
		end,
		tap = function() delete_node(node_index) end
	}
	end
	
	
	-- knobs
	
	for y=0,rows-1 do for x=0,y==2 and rows-1 or 1 do
		local mval_index = y*2 + x
		local label = labels[mval_index+1] or "??"
		
		-- pan is only shown on depth:1 OSC and root
		if (label == "pan" and (
			depth > 1 or -- anything 2 or deeper does not have a stereo position
			(depth == 1 and node_type ~= 2) or -- only osc can have pan at level 1
			(depth == 1 and peek(inst_addr + 0x1df) & 0x2 == 0) -- stereo not enabled
		)) then
			label = nil -- hide
		end
		
		

		if (mval_index < #labels and label) then
			el:attach(create_mval_knob(label, node_type, mval_index,
				node_addr + 4 + mval_index*4, 26 + x*80, 13 + y*18))
		end
	end end
	
	el:attach(create_scope(inst_addr+0x1e0,node_index,164,14, 69, el.height-19))

	return el
end


function update_instrument_editor()

	-- copy and paste instruments
	if (key"ctrl") then
	
		if keyp("c") or keyp"x" then
			local ud = userdata("u8",0x200 * (ci1-ci0+1)):peek(0x40000+ci0*0x200)
			set_clipboard(pod({
				instrument=ud
			},7,{pod_type="instrument"}))
			if keyp"x" then
				for i=ci0,ci1 do clear_instrument(i) end
				notify("cut "..(ci1-ci0+1).." instruments")
				refresh_gui = true
			else
				notify("copied "..(ci1-ci0+1).." instruments")
			end
		end
		
		if keyp("v") then
			checkpoint()
			local dat = unpod(get_clipboard())
			
			if (dat and type(dat.instrument) == "userdata") then
				dat.instrument:poke(0x40000+ci*0x200)
				notify("pasted "..(#dat \ 0x200).." instruments")
				refresh_gui = true
			else
				notify("could not find instrument data to paste")
			end
		end
	
	end
end



--[[pod_format="raw",created="2023-10-27 18:49:18",modified="2024-09-12 17:23:50",revision=10368]]
--[[

	track editor

]]



function create_tiny_num_field(label,addr,x,y,  vmin, vmax)
	local el={
		x=x,y=y,
		width=15,height=14,
		label=label,addr=addr,
		vmin=vmin, vmax=vmax
	}
	
	function el:draw()
		local val=peek(self.addr)
		if (has_knob) then
			circ(7,5,5,13)
			local aa=.7-val*.9/255.0
			line(7.5+cos(aa),5.5+sin(aa),7.5+cos(aa)*4,5.5+sin(aa)*4,7)
		end
		
		clip()
		
		-- 
		local yy= 0
		rectfill(0,yy,14,yy+6,0)
		local str=tostr(val)
		print(str,14-#str*4,yy+1,3)
		
		local label = self.label
		if (label == "loop0" and peek(self.addr+1) <= val) label = "len"
		print(label,-(2+#label*4),yy+1,6)

	end
	
	function el:click(msg)
		mouselock(0x4|0x8, 0.25, 0.05) -- 0x4 lock 0x8 auto-release, event speed, move speed 
	end
	
	
	function el:drag(msg)
		local val=peek(self.addr)
		val += msg.dx - msg.dy
		local vmin = el.vmin or 0
		local vmax = el.vmax or 255
		
		val = mid(vmin,val,vmax)
		poke(self.addr, val)
	end
	
	return el
end


cur_x = 0
cur_y = 0x50000 + 8

local note_name = {[0]=
"c ","c#","d ","d#","e ","f ","f#","g ","g#","a ","a#","b "
}
local val_to_str_0xff = {}
local val_to_str_0x00 = {}
local val_to_note     = {}

for i=0,255 do
	val_to_str_0xff[i] = string.format("%02x",i) 
	val_to_str_0x00[i] = string.format("%02x",i) 
	val_to_note[i] = note_name[i%12]..(i\12)
end

--val_to_str_0x00[0x00] = ".."
val_to_str_0xff[0xff] = ".."
val_to_note    [0xff] = "..."


local function render_row(addr, stride)
	
	local freq = @addr addr += stride
	local inst = @addr addr += stride
	local vol  = @addr addr += stride
	local fx   = @addr addr += stride
	local fxp  = @addr
	
	-- to do: cpu cost for string.format
	-- could keep a large cache by int64 hash of input
	return string.format("%s\-h\fe%s\-h\fc%s\-h\fd%s\f6%s",
		val_to_note[freq],
		val_to_str_0xff[inst], val_to_str_0xff[vol],
		fx == 0 and "." or chr(fx),
		fx == 0 and ".." or val_to_str_0x00[fxp]
	)
	
end

local function render_selection(x0, x1)
	if (x0 > x1) x0,x1 = x1,x0
	local str=""
	local str1 = "  "
	for i=0,8 do
		if (x0 <= i and x1 >= i) then
			str..= "\^i"..str1.."\^-i"
		else
			str..= str1
		end
		str1 = " " -- subsequent items are a single character
		if (i == 0 or i == 2 or i == 4) str1 ..= "\-h" -- 1px space
	end
	

	return str
--[[
	return string.format("%s%s\-h%s\-h%s\-h%s%s",
		(x0 <= 0 and x1 >= 0) and "\^i  \^-i" or "  ",
		(x0 <= 1 and x1 >= 1) and "\^i \^-i" or " ",
		(x0 <= 2 and x1 >= 2) and "\^i  \^-i"  or "  ",
		(x0 <= 3 and x1 >= 3) and "\^i  \^-i"  or "  ",
		(x0 <= 4 and x1 >= 4) and "\^i \^-i"   or " ",
		(x0 <= 5 and x1 >= 5) and "\^i  \^-i"  or "  "
	)
]]
end

-- by sfx_index; could do by channel later esp
-- if playing same sfx on two diffrent channels
function playing_row(sfx_index)

	if (stat(464)==0) return nil -- nothing playing
	
	for i=0,7 do
		if (stat(400 + i, 12) == sfx_index) then
			--printh("playing_row for sfx "..sfx_index..": "..stat(400 + i, 9))
			return stat(400 + i, 9)
		end
	end
end

function create_track_segment(el)

	local row_h = 8
	
	el.x = el.x or 0
	el.y = el.y or 0
	el.rows    = el.rows or 32
	el.width   = 44 -- always 48
	el.height  = el.height or el.rows * row_h + 2
	el.row0    = el.row0 or 0
	el.index   = el.index or ct -- sfx index
	el.last_index = -1
	el.rowstr={}
	
	
	if (not tdat[el.index]) tdat[el.index] = {}
	local ddat = tdat[el.index] -- decoration data
	
	-- recall per-sfx cursor
	if (ddat.cur) then
		cur_x = ddat.cur.x
		cur_y = ddat.cur.y
	end
	
	--tdat[el.index].sel={x0=0,y0=0,x1=3,y1=5}

	-- e.g. 0x50008 for first element on first row of first track
	-- add + el.row0 to get address of first row in segment	
	local base_addr = 0x50000 + (el.index * 328) + 8
	
	function el:update()
		if (el.live_index) then
			el.index = peek(0x30100 + cp * 20 + el.chan_i)
			base_addr = 0x50000 + (el.index * 328) + 8
			
			-- create default track data when needed
			if (el.index ~= el.last_index) then
				el.last_index = el_index
				local addr = 0x50000 + (el.index * 328)
				if peek8(addr) == 0 and peek8(addr + 8) == 0 then
					init_track(addr)
				end
			end
			
		end
		ddat.cur={x=cur_x,y=cur_y} -- store per-sfx cursor
	end
	

	function el:draw(msg)
	
		local sel = ddat.sel
		
		rectfill(0,0,1000,1000,0)
		
		local y0 = 0
		local y1 = self.rows - 1
		
		y0 = mid(0, (-self.sy)\row_h + 1, self.rows-1)
		y1 = mid(0, y0 + 270\row_h, self.rows-1)
		
		
		
		for i = y0,y1 do
		
			if (i%8 == 0 and self.rows > 8) then
				rectfill(0,i*row_h, self.width-1,i*row_h+row_h, i == 32 and 2 or 21)
			end
			
			if (i + self.row0 == playing_row(el.index)) then
				rectfill(0,i*row_h, self.width-1,i*row_h+row_h, 18)
			end
			
			-- note(3) inst(2) vol(2) effect(3)
			
			--print("c 3\-h\fe..\-h\fc..\-h\fd..0", 1, 1+i*7, 6)
			
			-- selected (only when viewing current track)
			if el.index == ct then
			
				if sel then
					local x0,y0,x1,y1 = get_track_selection(sel)
					if i + el.row0 >= y0 and  i + el.row0 <= y1 then 
						print(render_selection(x0, x1), 1, 1+i*row_h, 10)
					end
				end
				
				-- single
				--[[ don't need -- single-cel selection always follows cursor now
				if (cur_y == base_addr + i + el.row0) then
					print(render_selection(cur_x, cur_x), 1, 1+i*row_h, 9)
				end
				]]
			end
			
			print(render_row(base_addr + i + el.row0, 64), 1, 2+i*row_h, 6)
			
		end
		
		--rectfill(43,0,45,self.rows*7-3,16)
		
		-- light up when tragging a track index over track segment
		-- (drop to assign track to pattern channel)
		if (self.drop_track_index and
			msg.mx>=0 and msg.mx <self.width and msg.my >= 0 and grabbed_track) then
			rect(0,0,self.width-1,self.height-1, 10)
		end
		
	end
	
	function el:click(msg)
	
		focus = "track"
		checkpoint()
		
		local i=(msg.my-2)\row_h
		cur_y = base_addr + i + el.row0
		ct = el.index
		
		--	printh(string.format("base_addr: %x i: %d", base_addr, i))
		
		local col_x = {[0]=0,8,13,17,22,26,31,35,39}
		for i=0,8 do
			if (msg.mx >= col_x[i]) cur_x = i
		end

		if (key"ctrl" and false) then
		
			--  search replace	

		elseif (msg.mb == 2) then
		
			-- pick up instrument
			if (cur_x>=3 and cur_x<=4 and peek(cur_y+64) ~= 0xff) ci = peek(cur_y+64)
			
			-- pick up volume
			if (cur_x>=5 and cur_x<=6 and peek(cur_y+128) ~= 0xff) cvol = peek(cur_y+128)
			
			-- start new selection
			ddat.sel = {
				x0=cur_x, y0=i + el.row0, 
				x1=cur_x, y1=i + el.row0
			}

		elseif (key"shift") then
			-- extend selection
			ddat.sel=ddat.sel or {x0=cur_x, y0=i + el.row0, x1=cur_x, y1=i + el.row0}
			ddat.sel.x1 = cur_x
			ddat.sel.y1 = i + el.row0
		else
			-- start new selection
			ddat.sel = {
				x0=cur_x, y0=i + el.row0, 
				x1=cur_x, y1=i + el.row0
			}
		end
		
		return true -- don't pass through to pane
	end
	
	function el:drag(msg)
		local i=(msg.my-2)\row_h
		cur_y = base_addr + i + el.row0
		local col_x = {[0]=0,8,13,17,22,26,31,35,39}
		for i=0,8 do
			if (msg.mx >= col_x[i]) cur_x = i
		end
		ddat.sel.x1 = cur_x
		ddat.sel.y1 = i + el.row0
	end
	
	-- if track is zeroed, set up default track value
	local addr = 0x50000 + (el.index * 328)
	if peek8(addr) == 0 and peek8(addr + 8) == 0 then
		-- can assume points to zeroed ram --> initialise
		init_track(addr)
	end
	
	return el
end


-- doodle pitch values
-- shift to paint only instrument
function create_pitch_scribbler(el)
	el.index 	= el.index or ct
	el.click 	= checkpoint
	local y_offset = 12
	function el:draw()
		line(0,self.height-1,self.width,self.height-1,1)
		for i=0,63 do
			local val = (@(el.addr + i))
			if (val ~= 0xff) then
				local xx = i * 6
				local inst = @(el.addr + i + el.stride)
				local yy = el.height - val - 1 + y_offset
				rectfill(xx+1, yy, xx + 4, el.height, i==playing_row(el.index) and 12 or 1)
				rectfill(xx+1, yy, xx + 4, yy+1 , 8 + inst%24)
			end
		end
		local track_addr = 0x50000 + ct * 328
		local xx = peek(track_addr+3)*6
		if (xx>0) line(xx,0,xx,self.height,12)
		local xx1 = peek(track_addr+4)*6
		if (xx1>xx) line(xx1,0,xx1,self.height,14)
	end
	
	function el:drag(msg)
		local xx  = mid(0, msg.mx \ 6, 63)
		local val = mid(0, el.height - msg.my + y_offset, 255)
		
		if (msg.mb == 2) then
			ci = peek(el.addr + xx + el.stride)
		else
			-- set instrument
			poke(el.addr + xx + el.stride, ci)
			
			-- set pitch [and volume] only when shift is not held
			if not key"shift" then
				poke(el.addr + xx, val)
				local vol_addr = el.addr + xx + el.stride*2
				if (@vol_addr == 0xff) poke(vol_addr, 32) -- set volume when undefined
			end
		end
	end
	
	return el
end


-- dupe
function create_volume_scribbler(el)
	el.index 	= el.index or ct
	el.click  	= checkpoint
	function el:draw()
		line(0,self.height-1,self.width,self.height-1,1)
		for i=0,63 do
			local val = @(el.addr + i)
			if (val ~= 0xff) then
			local xx = i * 6
			local yy = el.height - val - 1
			rect(xx+1, yy, xx + 4, yy, i==playing_row(el.index) and 7 or 12)
			end
		end
	end
	
	function el:drag(msg)
		local xx  = mid(0, msg.mx \ 6, 63)
		local val = mid(0, el.height - msg.my, 99)
		poke(el.addr + xx, val)
	end
	
	return el
end

function get_track_selection(sel)
	local x0,y0,x1,y1 = sel.x0, sel.y0, sel.x1, sel.y1
	if y0 > y1 or (y0 == y1 and x0 > x1) then
		x0,y0,x1,y1 = x1,y1,x0,y0
	end
	return x0,y0,x1,y1
end

function get_track_selection_size(tdat)
	if (not tdat) return 0
	if (not tdat.sel) return 0
	local sel = tdat.sel
	local x0,y0,x1,y1 = get_track_selection(sel)
	return max(x0-x1, y0-y1)
end



local fx_input = {
	["0"] = "\0", ["."] = "\0",
	["1"] = "s", s="s",
	["2"] = "v", v="v",
	["3"] = "-", ["-"] = "-", 
	["4"] = "<", ["<"] = "<", 
	["5"] = ">", [">"] = ">", 
	["6"] = "a", ["a"] = "a", 
	["7"] = "b", ["b"] = "b", 
	["8"] = "t", ["t"] = "t",
	["9"] = "+", ["+"] = "+",
	w = "w", 
	r = "r", c = "c", d = "d", 
	p = "p"
}

function clear_notes(addr0, addr1, x0, x1)
	x0 = x0 or 0
	x1 = x1 or 9
	for addr=addr0, addr1 do
		if (x0<=1) poke(addr,0xff)
		if (x0<=3 and x1>=2) poke(addr+64,0xff)
		if (x0<=5 and x1>=4) poke(addr+128,0xff)
		if (x0<=6 and x1>=6) poke(addr+192,0)
		if (x0<=8 and x1>=7) poke(addr+256,0)				
	end
end


function update_track_editor()	
	
	local row0_addr = 0x50000 + (ct * 328) + 8
	local stride = 64
	local max_addr = row0_addr + 63
	
	local last_cur_x, last_cur_y = cur_x, cur_y
	local entered_fx = false
	
	
	-- can play even when cursor is not in range
	if (keyp("space") and mode == "track") then
		if (something_is_playing) then
			-- stop all audio when something was playing
			note()
		else
		
			local start_row = 0
			-- to do: setting to play from cursor instead of group of 8
			if (key"shift") then
				-- safety; condition always true
				if (cur_y > row0_addr) start_row = (cur_y-row0_addr) & ~0x7
			end
			
			-- play on channel 0
			sfx(ct, 0, start_row, 0)
			
		end
	end
	
	-- select
	
	if (key("ctrl") and keyp("a")) then
		checkpoint()
		tdat[ct].sel = {x0=0,y0=0,x1=8,y1=63}
	end
	
	-- paste notes
	if key("ctrl") and keyp("v") then
		checkpoint()
		local dat = unpod(get_clipboard())
		if (dat and type(dat.notes) == "userdata") then
			local x0=tonum(dat.x0) or 0
			local x1=tonum(dat.x1) or 8
			local maxy = min(dat.notes:height()-1, 63-(cur_y-row0_addr))
			--notify(string.format("pasting %d %d %d",x0, x1, maxy))
			notify("pasted "..(maxy+1).." notes")
			for y=0,maxy do
				if (x0<=1) poke(cur_y+y,dat.notes:get(0,y))
				if (x0<=3 and x1>=2) poke(cur_y+y+64,dat.notes:get(1,y))
				if (x0<=5 and x1>=4) poke(cur_y+y+128,dat.notes:get(2,y))
				if (x0<=6 and x1>=6) poke(cur_y+y+192,dat.notes:get(3,y))
				if (x0<=8 and x1>=7) poke(cur_y+y+256,dat.notes:get(4,y))
			end
		elseif dat and type(dat.sfx) == "userdata" then
			dat.sfx:poke(0x50000 + ct0*328)
			sfx_thumb={} -- invalidate thumbs
			notify("pasted "..(#dat.sfx \ 328).. " sfx")
		else
			notify("could not find note data or sfx to paste")
		end
	end
	
	-- operations on selections
	
	if (focus == "track_item") then
		-- operations on the sfx
		if (keyp"c" or keyp"x") then
			-- copy a whole sfx (later: multiple sfx can just be longer userdata)
			-- later: variation to support variable length sfx in collection.
			-- avoid needing to decide if "sfxes" (blegh) is plural of sfx
			
			set_clipboard(pod({
				sfx = userdata("u8",(ct1-ct0+1)*328):peek(0x50000+ct0*328)
			},0x7,{pod_type="sfx"}))
			
			if (keyp"x") then
				-- clear
				for i=ct0, ct1 do
					clear_notes(0x50000+i*328+8,0x50000+i*328+8+63)
				end
				clear_notes(row0_addr+0, row0_addr+63)
				notify("cut "..(ct1-ct0+1).." sfx")
				sfx_thumb={}
			else
				notify("copied "..(ct1-ct0+1).." sfx")
			end
		
		end
	elseif (tdat[ct] and tdat[ct].sel) then
	
		local sel = tdat[ct].sel
		local x0,y0,x1,y1 = get_track_selection(tdat[ct].sel)
		local did_cut = false
		
		if (x0~=x1 or y0~=y1) then
			-- some operations shouldn't apply to single cel (deselect / delete)	
			
			-- remove selection
			if (keyp("enter")) then
				if (tdat[ct]) tdat[ct].sel = nil 
				tdat[ct].sel = {
					x0=cur_x, y0=cur_y - row0_addr,
					x1=cur_x, y1=cur_y - row0_addr
				}
				clear_key("enter") -- don't insert a line
			end
		
			-- clear (also use after cutting) -- 
			-- to do: allow clearing at the nibble level
			if (keyp("backspace") or keyp("delete") or did_cut) then
				checkpoint()
				clear_notes(row0_addr+y0, row0_addr+y1, x0, x1)
			end
			
		end
		
		-- copy note data (can do on single cel selection too)
		-- always all vals but record range to write on paste
		if key("ctrl") and (keyp("x") or keyp("c")) then
			did_cut = keyp("x")
			local ud = userdata("u8",5,y1-y0+1)
			for x=0,4 do
				for y=y0,y1 do
					ud:set(x,y-y0,peek(row0_addr+x*64+y))
				end
			end
			set_clipboard(pod({
				notes=ud,
				x0=x0, x1=x1
			},7,{pod_type="notes"}))
			notify("copied "..(y1-y0+1).." notes ")
			--notify("copied "..(y1-y0+1).." notes "..pod{x0,x1,y0,y1}) -- debug
		end
			
			
		--------------------------------------
		--[[
		if (x0~=x1 or y0~=y1) -- let single-cel selection pass through
		and not key"shift"    -- not trying to change size of selection
		then
			readtext(true) -- discard any leftover keypresses
			return
		end
		]]
		--------------------------------------
	end
	
	-- to do: cur_y per track
	-- cursor isn't in current track; don't allow editing
	
	if (cur_y < row0_addr or cur_y >= row0_addr + 64) then
	
		readtext(true) -- consume (and ignore) any text entry

		--------------------------------------
		return	 
		--------------------------------------
	end
	

	
	if key"ctrl" then
	
		readtext(true) -- clear buffer
		
		--------------------------------------
		return -- nothing else to process
		--------------------------------------
	end
	
	
	if (keyp("left"))  cur_x -= 1
	if (keyp("right")) cur_x += 1
	if (keyp("up"))    cur_y -= 1
	if (keyp("down"))  cur_y += 1
	if (keyp("pageup"))    cur_y -= 4
	if (keyp("pagedown"))  cur_y += 4
	
	
	
--[[
	to do: how to handle limits? track vs pattern
	while (cur_y <  0x50008+ct*328+00) cur_y += 64
	while (cur_y >= 0x50008+ct*328+64) cur_y -= 64
]]
	

	
	
	-- going over side means diffrent things depending on layout
	if (mode == "track") then
		if (cur_x > 8) then
			cur_x = 0
			cur_y += 8
		end
		if (cur_x < 0) then
			cur_x = 8
			cur_y -= 8
		end
	end
	
	if (mode == "pattern") then
		-- jump to right
		-- 1. find out current
		local pats = 0x30100 + cp * 20
		local chani = nil
		local i0,i1 = nil,nil
		if (cur_x > 8) i0,i1=0,7
		if (cur_x < 0) i0,i1=7,0
		
		if (i0) then
			for i=i0,i1,sgn(i1-i0) do
				if (peek(pats+i) == ct) then
					chani = i
				elseif chani and ((peek(pats+9) & (1 << i)) > 0) then
					cur_y -= ct * 328
					ct = peek(pats+i)
					cur_y += ct * 328
					cur_x %= 9
					row0_addr = 0x50000 + (ct * 328) + 8
					
					tdat[ct] = tdat[ct] or {}
					tdat[ct].sel = {
						x0=cur_x, y0=cur_y - row0_addr,
						x1=cur_x, y1=cur_y - row0_addr
					}
					last_cur_x = cur_x
					last_cur_y = cur_y
					
--					track_seg_el[i]:set_keyboard_focus(true) -- test
--					refresh_gui = true -- not needed, but why does it break kbd input?
					
					return
				end
			end
			cur_x = mid(0,cur_x,8) -- stop moving
		end
		
	end

	-- in any case: wrap
	cur_x %= 9
	
	-- enter data
	
	local q = 64 -- stride
	
	-- key_pitch: use scancodes rather than textinput
	
	if (cur_x == 0) then
		for i=1,#key_pitch do
			if keyp(sub(key_pitch,i,i)) then
				checkpoint()
				poke(cur_y, 35+i + (coct*12-48))
				if (peek(cur_y+q)   == 0xff) poke(cur_y + q,   ci)   -- set inst
				if (peek(cur_y+q*2) == 0xff) poke(cur_y + q*2, cvol) -- set volume
				
				-- play the track from that note
				sfx(ct, 0, cur_y-row0_addr, 1)
				cur_y += 1
			end
		end
	end
	
	if (keyp("del") or (keyp("backspace") and cur_y > row0_addr)) then
		checkpoint()
		if (keyp("backspace")) cur_y -= 1
		for addr = cur_y, max_addr-1 do
			for j=0,4 do
				poke(addr + j*stride, peek(addr+j*stride+1))
			end
		end
		for j=0,4 do
			poke(max_addr + j * stride, j > 2 and 0 or 0xff) -- blank last line
		end
	end
	
	if (keyp("enter") and cur_y < max_addr and get_track_selection_size(tdat[ct]) < 2) then
		checkpoint()
		for addr = max_addr, cur_y+1, -1 do
			for j=0,4 do
				poke(addr + j*stride, peek(addr+j*stride-1))
			end
		end
		for j=0,4 do
			poke(cur_y + j * stride, j > 2 and 0 or 0xff) -- blank current line
		end
		cur_y += 1
	end
	
	-----
	
	while peektext() do
	
		local c = readtext()
	
		-- checkpoint() -- too agressive!
			
		-- fx
		if (cur_x == 6) then
			
			-- to do: map P8 numbers to chars.
			-- table can also be used to check is a valid effect char
			
			if (fx_input[c]) then
				checkpoint()
				poke(cur_y + q*3, ord(fx_input[c]))
				cur_y += 1
				entered_fx = true
			else
				--notify("effect not found") -- could be " " to play
			end
		else

			local num = nil
			
			if (c >= "a" and c <= "f") num = 10 + ord(c) - ord("a")
			if (c >= "A" and c <= "F") num = 10 + ord(c) - ord("A")
			if (c >= "0" and c <= "9") num = 00 + ord(c) - ord("0")
			
			if (num) then
				checkpoint()
				if (cur_x == 1) poke(cur_y, num*12 + peek(cur_y) % 12)
		
				if (cur_x >= 2 and cur_x <= 3 and peek(cur_y+q) == 0xff) poke(cur_y+q,0)
				if (cur_x == 2) poke(cur_y + q, peek(cur_y + q) % 16 + num * 16)
				if (cur_x == 3) poke(cur_y + q, peek(cur_y + q) &~15 | num )
		
				-- volume
				if (cur_x >= 4 and cur_x <= 5 and peek(cur_y+q*2) == 0xff) poke(cur_y+q*2,0)
				if (cur_x == 4) poke(cur_y + q*2, peek(cur_y + q*2) % 16 + num * 16)
				if (cur_x == 5) poke(cur_y + q*2, peek(cur_y + q*2) &~15 | num )
		
				-- fxp: commented until the mixer can deal with them!
				
				if (cur_x >= 7 and cur_x <= 8 and peek(cur_y+q*4) == 0xff) poke(cur_y+q*4,0)
				if (cur_x == 7) poke(cur_y + q*4, peek(cur_y + q*4) % 16 + num * 16)
				if (cur_x == 8) poke(cur_y + q*4, peek(cur_y + q*4) &~15 | num )
				if (cur_x > 0) cur_y += 1
				
				
				--cur_y += 1
				--if (cur_x > 1) cur_y += 1
			end
			
			-- . button to set whole byte for 
			if (c == ".") then
				checkpoint()
				if (cur_x == 0 or cur_x == 1) poke(cur_y + q*0, 0xff) cur_y += 1
				if (cur_x == 2 or cur_x == 3) poke(cur_y + q*1, 0xff)
				if (cur_x == 4 or cur_x == 5) poke(cur_y + q*2, 0xff)
				--if (cur_x == 6)               poke(cur_y + q*3, 0) -- handled above
				if (cur_x >  6)               poke(cur_y + q*4, 0)
				if (cur_x > 0) cur_y += 1
			end
			
		end
	
	end
	
	-- cursor movement wraps within track
	while (cur_y < row0_addr) cur_y += 64
	while (cur_y >= row0_addr + 64) cur_y -= 64
	
	-- vertical cursor movement in pattern mode: auto-scroll
	if (cur_y ~= last_cur_y and mode == "pattern") then
		local row = cur_y - row0_addr
		
		-- keep cursor within relative row 4,12 (*8 = 32px,96px)
		pattern_contents.y = mid(32 - row * 8, pattern_contents.y, 96 - row*8)
		
		-- clamp
		--pattern_contents.y = mid(0, 64 - row * 8, -- ref: playback following
		pattern_contents.y = mid(0, pattern_contents.y,
			 pattern_contents.parent.height - pattern_contents.height)
	end

	-- cursor movement modifies selection
	
	if tdat[ct] and (cur_x ~= last_cur_x or cur_y ~= last_cur_y)
	then
		
		-- default to selection of last cursor position
		tdat[ct].sel = tdat[ct].sel or
		{
			x0 = last_cur_x, x1 = last_cur_x,
			y0 = last_cur_y - row0_addr,
			y1 = last_cur_y - row0_addr
		}


		if key"shift" and not entered_fx then
			checkpoint()
			-- holding shift (and not for entering an fx like <)
			tdat[ct].sel.x1 = cur_x
			tdat[ct].sel.y1 += (cur_y - last_cur_y)
		else
	
			-- when cursor changes, and selection is a single cel,
			-- move selection with cursor
		
			local x0,y0,x1,y1 = get_track_selection(tdat[ct].sel)
			
			if x0==x1 and y0==y1 then
				tdat[ct].sel={
					x0 = cur_x, x1 = cur_x,
					-- to do: fix awkward change in meaning between cursor / selections
					-- maybe nice that it includes track though
					y0 = tdat[ct].sel.y0 + (cur_y - last_cur_y),
					y1 = tdat[ct].sel.y1 + (cur_y - last_cur_y)
				}
			else
				-- clear selection
				tdat[ct].sel = nil
			end
		end
		
	end
	
	
end

-- applied even when focus is on track
function update_pattern_editor_playback()
	if (keyp("space")) then
		if (something_is_playing) then
			-- stop all audio when something was playing
			note()
		else
			-- to do: hold shift to play from group of 8. 
			-- calculate from cursor track? needs to be handled by mudo_play_pattern()
			music(cp) following_playback = true
		end
	end
end

function update_pattern_editor()

	if ( key"ctrl" and (keyp"c" or keyp"x")) then
		local ud=userdata("u8",20 * (cp1-cp0+1)):peek(0x30100 + cp0*20)
		set_clipboard(pod({
			pattern=ud
		},7,{pod_type="pattern"}))
		
		if key"x" then
			for i=cp0,cp1 do clear_pattern(i) end
			notify("cut "..(cp1-cp0+1).." patterns")
			refresh_gui = true
		else
			notify("copied "..(cp1-cp0+1).." patterns")
		end
	end
	
	if (key"ctrl" and keyp"v") then
		checkpoint()
		local dat = unpod(get_clipboard())
		if (dat and type(dat.pattern) == "userdata") then
			dat.pattern:poke(0x30100 + cp0*20)
			notify("pasted "..(#dat.pattern\20).." patterns")
			refresh_gui = true
		else
			notify("could not paste pattern")
		end
	end
end

--[[pod_format="raw",created="2023-10-08 03:32:58",modified="2024-09-12 16:58:56",revision=7901,stored="2023-36-29 04:36:40"]]

-- flags: lerp, random start position
-- used by DATA envelope
function create_env_flag_toggle(addr,flag,label,x,y)
	local el = {
		addr = addr, flag = flag, label=label,
		x = x, y = y, width = 18+#label*4, height = 7
	}
	function el:draw(msg)
		local yy = (msg.has_pointer and msg.mb > 0) and 1 or 0
		local val = (@self.addr) & self.flag
		--clip()
		--rectfill(0,0+yy,self.width-1,6+yy,msg.has_pointer and 14 or 
		--	(val>0 and 7 or 13))
		local str=val>0 and "[/] " or "[ ] "
		if (self.flag == 0x10) str = "" -- EF_ADVANCED_OPTS doesn't have checkbox
		print(str..self.label,2,1+yy,13)
	end
	function el:click()
		checkpoint()
		local val = peek(self.addr)
		val ^^= self.flag
		poke(self.addr, val)
		refresh_gui = true
	end
	
	return el
end


env_type_str = {[0]=
	"adsr",
	"lfo",
	"data",
}



function create_env_type_toggle(addr,x,y)
	local el = { 
		addr = addr,
		x = x, y = y, width = 20, height = 7
	}
	function el:draw(msg)
		local yy = (msg.has_pointer and msg.mb > 0) and 1 or 0
		local val = (@self.addr) & 0xf
		clip()
		--pal(7,1)
		rectfill(0,0+yy,self.width-1,6+yy,msg.has_pointer and 14 or 6)
		--spr(val,1,1+yy)
		print(env_type_str[val],2,1+yy,1)
		--pal()
	end
	function el:click()
		checkpoint()
		local val = peek(self.addr)
		val = (val + 1) % 3
		poke(self.addr, (peek(self.addr) & 0xf0) | (val & 0x0f))
		refresh_gui = true
	end
	
	return el
end

function create_env_plug(index, x, y)
	local el = {
		x=x,y=y,width=7,height=7,index=index,
		click=checkpoint
	}
	function el:draw(msg)
		circfill(3,3,2,13)
		circ(3,3,2,1)
	end
	function el:release(msg)
		local sx=self.sx + msg.mx
		local sy=self.sy + msg.my
		
		local el2 = gui:el_at_xy(sx,sy)
		if (el2.drop_env_plug) el2:drop_env_plug{index=self.index}
		
	end
	
	return el
end


--[[
	edit an 8-bit value in memory
]]
function create_tiny_knob(label,addr,x,y,has_knob)
	local el={
		x=x,y=y,
		width=15,height=has_knob and 24 or 14,
		label=label,addr=addr,
		dval=0,
		cursor="dial"
		--cursor="grab" -- to do: dial spinning cursor that disappears
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
		local yy=has_knob and 14 or 2
		rectfill(0,yy,14,yy+6,0)
		local str=tostr(val)
		print(str,14-#str*4,yy+1,3)
		
		print(self.label,9-#self.label*2,yy+10,13)

	end
	
	-- turn mouse locking on while dragging
	function el:click(msg)
		mouselock(0x4|0x8, 0.5, 0.05) -- 0x4 lock 0x8 auto-release, event speed, move speed 
	end
	
	function el:drag(msg)
		local val=peek(self.addr)
		-- accumulate change at 0.5 per pixel
		el.dval += (msg.dx - msg.dy) * 0.5
		if (el.dval <= -1) then
			val -= flr(-el.dval)
			el.dval += flr(-el.dval)
		end
		if (el.dval >= 1) then
			val += flr(el.dval)
			el.dval %= 1
		end
		val = mid(0,val,255)
		poke(self.addr, val)
		return true -- don't drag env_content
	end
	
--[[
	-- annoying
	-- doesn't mix with drag control
	-- pico-8 actually suffers from the same problem!
	-- (just not pronounced because easy to keep the cursor still,
	--  and hard to drag -1 or +1 while starting and ending inside el)
	
	function el:tap(msg)
		local val = peek(self.addr)
		local mag = key("ctrl") and 8 or 1
		val += msg.last_mb == 2 and -mag or mag
		poke(self.addr,mid(0,val,255))
	end
]]
	
	return el
end


function create_data_env_editor(addr, x, y, width, height)
	local el={
		addr=addr,
		x=x,y=y,width=width,height=height
	}
	function el:draw()
		rectfill(0,0,self.width-1,self.height-1,0)
		local ww=width\16
		local hh=self.height
		local loop0 = @(addr+3)
		local loop1 = @(addr+4)
		
		-- show loop points
		fillp(0x5a5a)
		col = loop0 < loop1 and 6 or 5
		line(loop0*ww-1,0, loop0*ww-1,self.height,col)
		line(loop1*ww-1,0, loop1*ww-1,self.height,col)
		fillp()
		
		-- show data
		for i=0,15 do
			local sx = i*ww
			local val = peek(self.addr+i+8)
			local col = i >= loop0 and i < loop1 and 13 or 12
			rectfill(sx,hh,sx+ww-2,hh-val*hh/255,col)
			rectfill(sx,hh-val*hh/255,sx+ww-2,hh-val*hh/255,28)
		end
		
	end
	
	function el:drag(msg)
		local ww=width\16
		local hh=self.height
		local xx=mid(0,msg.mx\ww,15)
		local yy=(msg.my) * 255 / self.height
		poke(self.addr+xx+8,mid(0,255-yy,255))
		return true -- don't drag env_content
	end
	
	return el
end


function create_env_editor(index, addr, label, x, y, width)

	local height = 46
	if (@addr == 1) height = 54 -- lfo
	if (@addr == 2) height = 86 -- data
	
	local height0 = height
	
	if (peek(addr+1)&0x10>0 and @addr<2) then
		height += 28
	end
	
	local pane = gui:attach(create_pane("\fh"..label, x, y, width, height, 0x0701))
	pane.index = index
	
	-- don't need plug! just drag whole pane
	--pane:attach(create_env_plug(index,2,1))
	
	
	pane:attach(create_env_type_toggle(addr,44,1))
	
	
	-- adsr
	if (peek(addr) == 0) then
		-- no labels: it's in the name of the envelope!
		--local knob_name={[0]="atk","dcy","sus","rel"}
		for i=0,3 do
			pane:attach(create_tiny_knob("",addr+8+i,2+i*20,16,true))
		end
	end
	
	-- lfo
	if (peek(addr) == 1) then
		pane:attach(create_tiny_knob("freq",addr+12+0,8,16,true))
		--pane:attach(create_tiny_knob("func",addr+13+0,31,28,false))
		pane:attach(create_tiny_knob("phase",addr+14+0,54,16,true))
		
	end
	
	-- data footer thing
	if (peek(addr) == 2 or peek(addr+1)&0x10>0) then
		
		if (peek(addr) != 2) then
			-- non-data only needs the start at rnd(t0), so can have more verbose version
			--pane:attach(create_env_flag_toggle(addr+1,0x8,"rnd start",20,pane.height-27))
			pane:attach(create_env_flag_toggle(addr+1,0x8,"rnd",46,pane.height-27))
		end
		
		-- starting from env_def[1]  -- env_def[0] is flags
		local knob_name={[0]="spd","lp0","lp1","t0"}
		for i=0,3 do
			pane:attach(create_tiny_knob(knob_name[i],addr+2+i,2+i*20,
				pane.height-20,false))
		end
		
	end
	
	-- data editor
	if (peek(addr) == 2) then
		pane:attach(create_data_env_editor(addr,0,9,80,48))
	
		-- lerp, rnd_start
		pane:attach(create_env_flag_toggle(addr+1,0x1,"lerp",2,pane.height-27))
		pane:attach(create_env_flag_toggle(addr+1,0x8,"rnd",46,pane.height-27))
		
	end
	
	-- show advanced options / ... button
	if (peek(addr) < 2) then
		local str="\f5\^:0000001500000000" -- ...
		if (peek(addr+1)&0x10>0) str="\f5\^:0000040e1f000000" -- up arrow
		pane:attach(create_env_flag_toggle(addr+1,0x10,str,width/2-6,height0-8))
	end
	
	-- don't scroll when grabbing "env-0" part of title bar
	--> so that can drag and drop without scrolling env container
	pane:attach{
		x=0,y=0,width=26,height=10,
		cursor="grab",
		click=function(self)
			grabbed_envelope = pane.index
			return
		end,
		drag=function()
			return true 
		end
	}
	
	-- can drag and drop anywhere on pane
	function pane:release(msg)
		local sx=self.sx + msg.mx
		local sy=self.sy + msg.my
		
		local el2 = gui:el_at_xy(sx,sy)
		if (el2 and el2.drop_env_plug) el2:drop_env_plug{index=self.index}
		
		grabbed_envelope = nil
	end
	
	return pane
end









































































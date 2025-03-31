--[[pod_format="raw",created="2023-10-11 02:18:48",modified="2024-08-18 16:06:41",revision=4518,stored="2023-24-28 00:24:00"]]
--[[
	navigate sprite bank
	+ top-level operations (resize bitmap)

	tab to toggle pane (and dock/undock toolbar!)
]]

local icons=
{
	-- notes
	"[gfx]08087777770077777700700007007777770070000700777777000777777000000000[/gfx]",
	
	-- scale
	"[gfx]08087070707000000000700000700000000077700070777000007770707000000000[/gfx]",
	
	-- unlock, lock
	"[gfx]08080077700007000700070000000777770007707700077777000000000000000000[/gfx]",
	"[gfx]08080000000000777000070007000777770007707700077777000000000000000000[/gfx]"
}

function make_toggle_button(el)

	local el = el or {}
	el.width = el.width or 7
	el.height = el.height or 7
	el.set = el.set or function() end
	el.get = el.get or function() end
	el.cursor="pointer"
	
	function el:draw()
		local b = el.bmp0
		if (self.get() and el.bmp1) b = el.bmp1
		local col = self.get() and 7 or 13
		pal(7,col)
		spr(b, 0, 0)
		pal()
	end
	
	function el:click()
		el.set(not el.get())
	end
	
	return el
end


-- to do: lock aspect button 
-- (only need to change width to go from 12x8 -> 24x16)
function resize_item(index, width, height)
	-- note: userdata only takes numbers for sizes, not strings (!)

	if (width) width=tonum(width)
	if (height) height=tonum(height)
	
	--item[index].undo_state:checkpoint()
	
	local ww = item[index].bmp:width()
	local hh = item[index].bmp:height()
	local aspect = ww / hh

	local ww = tonum(width) or ww
	local hh = tonum(height) or hh
	
	if (lock_aspect) then
		if (not width)  width  = hh * aspect
		if (not height) height = ww / aspect
	else
		width = width or ww
		height = height or hh
	end
	
	--printh("width:"..tostr(width).."  height:"..tostr(height))
	--printh("type(width):"..type(width).."  type(height):"..type(height))

	if (width < 1 or width > 8192 or
		height < 1 or height > 8192 or
		width * height > 1024*1024) then
		-- to do: error "bad size" or "too big"
		return
	end
		
	local old = item[index].bmp
	local new = userdata("u8", width, height)
	
	blit(old, new, 0,0, 
		new:width()\2 - old:width()\2,
		new:height()\2 - old:height()\2
	)
	
	item[index].bmp = new
end


function create_item_info(el)

	el = gui:new(el)

	function el:draw()
		--rect(0,0,self.width-1, self.height-1, 13)
	end
	
	-- preview thumb
	el:attach{
		x=0,y=0,width=16,height=16,
		draw=function(self)
			rectfill(0,0,23,23,0)
			local b= item[current_item].bmp
			spr(b,self.width/2 - b:width()/2, self.height/2-b:height()/2)
		end
	}
	
	local xx0 = 20
	local yy  = 0
	-- index
	el:attach{
		x=xx0,y=yy,width=15,height=7,
		draw=function(self)
			local b= item[current_item].bmp
			rectfill(0,0,self.width-1,self.height-1,0)
			print(string.format("%03d",current_item),2,1,7)
		end
	}
	
	local xx = xx0 + 18
	
	-- width
	el:attach_field{
		x=xx,y=yy,width=15,height=7,
		get=function() return item[current_item].bmp:width() end,
		set=function(self,val) 
			for index in all(multi_op(get_region_indexes(region),true)) do
				resize_item(index, val, nil)
			end
			--resize_item(current_item, val, nil)
			set_current_item() refresh_gui = true -- update
		end,
		label=""--size:"
	}
	
	-- toggle lock
	el:attach(make_toggle_button{
		x=xx+16,y=0,
		bmp0=userdata(icons[3]),
		bmp1=userdata(icons[4]),
		set=function(val) lock_aspect = val end,
		get=function() return lock_aspect end,
	})
	
	-- height
	el:attach_field{
		x=xx+24,y=yy,width=15,height=7,
		get=function() return item[current_item].bmp:height() end,
		set=function(self,val) 
			for index in all(multi_op(get_region_indexes(region),true)) do
				resize_item(index, nil, val)
			end
			--resize_item(current_item, nil, val)
			set_current_item() refresh_gui = true -- update
		end,
		label=""
	}	
	
	-- sprite flags
	for i=0,7 do
		el:attach{
		cursor="pointer",
		--x=xx0+i*7,
		x=81+i*6,
		y=0,
		width=5,height=9,
		index=i,
		draw=function(self)
			local col0 = 1
			local col1 = 13
			if (item[current_item].flags & (1<<self.index)) > 0 then
				col0 = 8 + self.index
				col1 = 7
			end
			circfill(2,2,2,col0)
			circ(2,2,2,0)
		end,
		
		click = function(self)
			backup_state()
			local bit = (1<<self.index)
			local state1 = (item[current_item].flags & bit) ^^ bit
			
			--item[current_item].flags ^^= (1<<self.index)
			
			for index in all(multi_op(get_region_indexes(region),true)) do
				item[index].flags = (item[index].flags & ~bit) | state1
			end
		end,
	}
	end
	
	-- edit extra. later!
	--[[
	el:attach(make_toggle_button{
		x=20,y=9,
		bmp0=userdata(icons[1])
	})
	]]
	
	-- stretch; don't need
	--[[
	el:attach(make_toggle_button{
		x=54,y=9,
		bmp0=userdata(icons[2])
	})	
	]]

	return el
end


function create_bank_tabs(el)

	el = gui:new(el)

	function el:draw()
		--rect(0,0,self.width-1, self.height-1, 13)
	end
	
	for i=0,3 do
		local y_offs = i == current_bank and 0 or 1
		local tab = el:attach({
			x=i*12,y=y_offs,width=11,height=el.height - y_offs,
			index=i,
			cursor="pointer",
			draw = function(self)
				local sel = current_bank == self.index
				rectfill(0,0,self.width-1, self.height-1, sel and 7 or 6)
				pset(0,0,5)
				line(0,1,1,0,5)
				line(0,2,2,0,5)
				
				pset(self.width-1,0,5)
				
				line(0,self.height-1,self.width-1,self.height-1,13)
				print(self.index,5,1,13)
			end,
			click = function(self)
				set_current_bank(self.index)
				refresh_gui = true
			end
			
		})
	end
	

	
	return el
end

function create_nav(el)

	function el:draw()
		clip()
		rectfill(-1,-1,self.width, self.height, 0)
		
		for y=0,7 do
			for x=0,7 do
				local scale = 1
				local ii = x + y*8 + current_bank*64
				local bmp = item[ii].bmp
				local ww,hh = bmp:width(), bmp:height()
				-- to do: this makes very thin bmps invisible in preview
				scale = 16 / max(ww,hh)
				if (scale >= 1) then
					scale = scale \ 1
				elseif (scale >= 0.666) then
					scale = 1 -- up to 24x24, still show pixel for pixel
				end
				clip(self.sx + x*16, self.sy + y*16, 16,16)
				sspr(bmp,
					0,0,nil,nil,
					x*16 + 8 - ww * scale/2,
					y*16 + 8 - hh * scale/2,
					ww*scale, hh*scale)
			end
		end
		
		-- region
		local xx = region.x * 16
		local yy = (region.y - current_bank*8) * 16
		local ww = region.w * 16
		local hh = region.h * 16
		clip(el.sx-2,el.sy-2,el.width+4,el.height+4)
		rect(xx-2,yy-2, xx+ww+1, yy+hh+1, 0)
		rect(xx-1,yy-1, xx+ww+0, yy+hh+0, 7)
		
		--[[
		if (current_bank == current_item\64) then
			
			local ii = (current_item - current_bank*64)
			local xx = (ii % 8) * 16
			local yy = (ii \ 8) * 16
	
			clip()
			
			rect(xx-2,yy-2,xx+17,yy+17,0)
			rect(xx-1,yy-1,xx+16,yy+16,7)
		end
		]]
		
	end
	

	function el:drag(msg)
		local rx = msg.mx * 8 \ self.width
		local ry = msg.my * 8 \ self.height + (current_bank*8)
		local i = rx + ry * 8
		
		if key"shift" then
			-- extend region
			rx0=min(rx, region.x0)
			ry0=min(ry, region.y0)
			region = {
				x=rx0, y=ry0,
				w=max(rx,region.x0)-rx0+1,
				h=max(ry,region.y0)-ry0+1,
				x0=region.x0, y0=region.y0
			}
		else	
			region={
				x=rx, y=ry, w=1, h=1, x0=region.x0, y0=region.y0
			}
		end
		
		set_current_item(i)
		--printh("setting item: "..i)
	end
	
	function el:click(msg)
		-- reset region even if shift-clicking (p8 behaviour)
		local rx = msg.mx * 8 \ self.width
		local ry = msg.my * 8 \ self.height + (current_bank*8)
		region={	x=rx, y=ry, w=1, h=1, x0=rx, y0=ry }
	end
	
	return el
end








































































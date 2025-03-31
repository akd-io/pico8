--[[pod_format="raw",created="2023-10-11 02:18:48",modified="2024-07-18 22:58:53",revision=3942]]
--[[
	navigate sprite bank
	
	to do: pin tabs from multiple sprite banks at once
	(but 4 tabs on the right "0".."3" are always from selected .gfx file)

]]
icons =
{
	-- notes
	"[gfx]08087777770077777700700007007777770070000700777777000777777000000000[/gfx]",
	
	-- scale
	"[gfx]08087070707000000000700000700000000077700070777000007770707000000000[/gfx]",
	
	-- unlock, lock
	lock0="[gfx]08080077700007000700070000000777770007707700077777000000000000000000[/gfx]",
	lock1="[gfx]08080000000000777000070007000777770007707700077777000000000000000000[/gfx]",

	hidden0=unpod("b64:bHo0AB8AAAAhAAAA8wNweHUAQyAICASQJzAHAAcABxACAIAABwAHMCfwAw=="),
	hidden1=unpod("b64:bHo0AA8AAAAOAAAA4HB4dQBDIAgIBPAIZ-AR"),
	
	bucket_cursor=unpod("b64:bHo0AE8AAABPAAAA8gBweHUAQyAVFQTQAfADAQcFAPAr4EEHAcABZwGgAQcBRwGwAQcRJwHAAQcBAAEHAdABBwEQAdABIAHgAQcgBwHgASAB8AEBBwHwAwHwjQ=="),
	add_layer=unpod("b64:bHo0ACAAAAAhAAAA4XB4dQBDIAgIBG0ALQctBADgDUcNAC0HLQAtBy0AbYA="),
	del_layer=unpod("b64:bHo0ACgAAAArAAAA8wVweHUAQyAICAQNRw0AZwAHDScNBwYAQCcNJwAWAIANBw0HDQcNgA=="),

	edit = unpod("b64:bHo0ABkAAAAXAAAA8AhweHUAQyAICASwB1AnMCcwBwAHQBfwBQ=="),
	
	layer_up = unpod("b64:bHo0ABYAAAAUAAAA8AVweHUAQyAICATwAwdQJzBHQAfwBA=="),
	layer_down = unpod("b64:bHo0ABYAAAAUAAAA8AVweHUAQyAICATwAwdARzAnUAfwBA=="),
	
}

function make_toggle_button(el)
	local el = el or {}
	el.width = el.width or 7
	el.height = el.height or 7
	el.set = el.set or function() end
	el.get = el.get or function() end
	
	el.cursor = "pointer"
	
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



function make_operation_button(el)
	local el = el or {}
	el.width = el.width or 7
	el.height = el.height or 7
	
	el.cursor = "pointer"
	
	function el:draw()
		local b = el.bmp0
		local col = 7
		pal(7,col)
		spr(b, 0, 0)
		pal()
	end
	
	return el
end


-- (only need to change width to go from 12x8 -> 24x16)
function resize_map(index, width, height)
	-- note: userdata only takes numbers for sizes, not strings (!)
	if (width) width=tonum(width)
	if (height) height=tonum(height)
	
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
	
	if (width < 1 or width > 8192 or
		height < 1 or height > 8192 or
		width * height > 1024*1024) then
		-- to do: error "bad size" or "too big"
		return
	end
		
	local old = item[index].bmp
	local new = userdata("u16", width, height)
	
	blit(old, new, 0,0, 
		new:width()\2 - old:width()\2,
		new:height()\2 - old:height()\2
	)
	
	item[index].bmp = new
	
	refresh_gui = true
	set_current_item()
end

function move_layer(index, dindex)
	local i1 = index + dindex
	if (i1 < 1 or i1 > #item) return
	item[i1],item[index] = item[index],item[i1]
	if (current_item == i1) then
		set_current_item(index)
	elseif current_item == index then
		set_current_item(i1)
	end
	
	refresh_gui = true
end


-- note: normally only need < ~4 layers, so
-- scrollbar would be normally not needed
-- placeholder. will have: layer name, visible, [parent / tree structure]
-- ** each layer has a type that influences ui **
function create_layer_nav(el)

	local item_h = 8
	
	el = gui:new(el)
	function el:draw()
		rectfill(0,0,self.width-1,self.height-1,0)
		local yy = 2
		for i=1,#item do
			local selected = i == current_item
			label = item[i].name or "[layer "..i.."]"
			if (selected and not layer_name_editor) rectfill(4,yy,self.width-5,yy+6,12)
			
			clip(el.sx,el.sy,5+72,1000)
			print(label,5,yy+1, i == 0 and 7 or 6)
			clip()
			spr(item[i].hidden and icons.hidden1 or icons.hidden0,self.width-14,yy)
			spr(icons.edit,self.width-26,yy)
			pal(7,13)
			spr(icons.layer_up,self.width-38,yy)
			spr(icons.layer_down,self.width-48,yy)
			pal(7,7)
			
			yy += item_h
		end
		
	end
	
	function el:click(msg)
		if (layer_name_editor) refresh_gui = true
	end
	
	function el:doubletap(msg)
		-- same as tap on edit button
		msg.mx = self.width-29
		el:tap(msg)
	end
	
	
	function el:tap(msg)
		local index = 1 + (msg.my - 2) \ item_h
		index = mid(1, index, #item)
		if (msg.mx > self.width - 18) then
			item[index].hidden = not item[index].hidden
		elseif (msg.mx > self.width - 30) then
			readtext(true) -- clear input buffer (to do:should attach_text_editor do that?)
			layer_name_editor = el:attach_text_editor{
				x=2, y= 0+ (index-1)*item_h, width=74, height= 9, 
				block_scrolling = true, max_lines = 1,
				key_callback = {
					enter = function () 
						item[index].name = layer_name_editor:get_text()[1]
						layer_name_editor = nil
						refresh_gui = true
					end
				},
				-- block mouse messages from selecting other layers
				click = function() return true end,
				tap = function() return true end
			}
			layer_name_editor:set_text({(item[index].name or "")})
			layer_name_editor:set_keyboard_focus(true)
			layer_name_editor:set_cursor(1000,1)
			window{capture_escapes = true}
			
		elseif (msg.mx > self.width - 42) then
			move_layer(index, -1)
		elseif (msg.mx > self.width - 52) then
			move_layer(index, 1)
		else
			set_current_item(index)
		end
	end

	return el
end

function create_layer_info(el)
	el = gui:new(el)
	
	local xx = 20 + 24
	local yy = 0
	
	-- map width
	el:attach_field
	{
		x=xx,y=yy,width=20,height=7,
		get=function() return item[current_item].bmp:width() end,
		set=function(self,val)
			backup_state()
			resize_map(current_item, val, nil)
		end,
		label="layer size:"
	}
	
	-- toggle aspect lock
	el:attach(make_toggle_button{
		x=xx+21,y=0,
		bmp0=userdata(icons.lock0),
		bmp1=userdata(icons.lock1),
		set=function(val) lock_aspect = val end,
		get=function() return lock_aspect end,
	})
	
	-- map height
	el:attach_field{
		x=xx+29,y=yy,width=20,height=7,
		get=function() return item[current_item].bmp:height() end,
		set=function(self,val) 
			backup_state()
			resize_map(current_item, nil, val)
		end,
		label=""
	}
	
	-- add layer
	el:attach(make_operation_button{
		x=xx+60,y=0,
		bmp0=icons.add_layer,
		tap=function()
			if (#item >= 6) then
				notify("maximum: 6 layers")
				return
			end
			backup_layers()
			--printh(pod(item[current_item].bmp))
			local new_item = {}
			for k,v in pairs(ci) do
				new_item[k] = unpod(pod(v))
			end
			add_undo_stack(new_item)
			new_item.name = nil
			new_item.bmp:clear()
			
			add(item, new_item, current_item+1)
			refresh_gui = true
		end
	})
	
	-- delete layer
	el:attach(make_operation_button{
		x=xx+72,y=0,
		bmp0=icons.del_layer,
		tap=function()
			if (#item > 1) then
				backup_layers()
				deli(item, current_item)
				set_current_item()
			else
				notify("must have at least one layer")
			end
		end
	})
		
	return el	
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
			local b = get_spr(col)
			if (b) spr(b,self.width/2 - b:width()/2, self.height/2-b:height()/2)
		end,
		tap=function(self)
			current_bank = col\256
			current_bank_page = (col&0xff)\64
			refresh_gui = true
		end
	}
	
	local xx0 = 20
	local yy  = 0
	local hex_mode = true
		
	-- index (is 16-bit index in map editor)
	-- to do: toggle hex mode / decimal mode
	el:attach{
		x=xx0,y=yy,width=27,height=7,
		draw=function(self)
			local b= item[current_item].bmp
			rectfill(0,0,self.width-1,self.height-1,13)
			local str = hex_mode and
				string.format("0X%04x",col) or
				string.format("%d",col)
			print(str,self.width-1-#str*4,1,7)
		end,
		tap=function(self)
			hex_mode = not hex_mode
		end
	}
	
	-- bank selection placeholder
	-- click to choose file
	-- maybe pin pages / files? 
	-- (create primary set of tabs, where pages are secondary)
	el:attach{
		x=xx0 + 52,y=yy,width=48,height=7,
		draw=function(self)
			local b= item[current_item].bmp
			rectfill(0,0,self.width-1,self.height-1,1)
			
			local gfx_fn = gfx_file[current_bank] or "??"
			
			print(string.format(gfx_fn:basename(),col),2,1,13)
			
		end
	}
	
	el:attach{x=xx0 + 42,y=yy,width=8,height=7,cursor="pointer",
		draw=function(self)
			rectfill(0,0,self.width-1,self.height-1,13) print("<",2,1,7)
		end,
		tap=function(self) set_current_bank(nil, -1) end
	}
	
	el:attach{x=xx0 + 101,y=yy,width=8,height=7,cursor="pointer",
		draw=function(self)
			rectfill(0,0,self.width-1,self.height-1,13) print(">",2,1,7)
		end,
		tap=function(self) set_current_bank(nil, 1) end
	}
	
	return el
end
	
function create_bank_tabs(el)
	el = gui:new(el)
	function el:draw()
		--rect(0,0,self.width-1, self.height-1, 13)
	end
	
	for i=0,3 do
		local y_offs = i == current_bank_page and 0 or 1
		local tab = el:attach({
			x=i*12,y=y_offs,width=11,height=el.height - y_offs,
			index=i,
			draw = function(self)
				local sel = current_bank_page == self.index
				rectfill(0,0,self.width-1, self.height-1, sel and 7 or 6)
				pset(0,0,5)
				line(0,1,1,0,5)
				line(0,2,2,0,5)
				
				pset(self.width-1,0,5)
				
				line(0,self.height-1,self.width-1,self.height-1,13)
				print(self.index,5,1,13)
			end,
			click = function(self)
				set_current_bank_page(self.index, 1)
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
				local bmp = get_spr(x + y*8 + current_bank_page*64 + current_bank*256)
				if (bmp) then
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
		end
		
	
		if (current_bank == col\256 and current_bank_page == (col&0xff)\64) then
			
			local ii = (col - current_bank_page*64) & 0xff
			local xx = (ii % 8) * 16
			local yy = (ii \ 8) * 16
	
			clip()
			
			rect(xx-2,yy-2,xx+17,yy+17,0)
			rect(xx-1,yy-1,xx+16,yy+16,7)
		end
		
		
	end
	
	-- select sprite
	function el:drag(msg)
		local x = mid(0,msg.mx * 8 \ self.width,7)
		local y = mid(0,msg.my * 8 \ self.height, 7)
		local i = x + y * 8
		col = i + current_bank_page*64 + current_bank*256
	end
	return el
end



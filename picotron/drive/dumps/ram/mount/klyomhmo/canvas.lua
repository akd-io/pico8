--[[pod_format="raw",created="2023-04-11 02:04:02",modified="2024-07-18 22:58:53",revision=3395]]

local ww,hh=0,0
local fill_cpu=0
local x0,y0=0,0

--[[
local tile_w = 16
local tile_h = 16
]]

function do_fill_0(bmp, x, y, tc)
	if (get(bmp,x,y) != tc) return
	if (x < 0 or y < 0 or x >= ww or y >= hh) return
	local l,r=x,x
	while(get(bmp,l,y)==tc and l>=0) l-=1
	l+=1
	while(get(bmp,r,y)==tc and r<ww) r+=1
	r-=1
	
	for xx=l,r do
		set(bmp,xx,y,col)	
	end
	
	if (y > 0) then
		local last = nil
		for xx=l,r do
			local val = get(bmp,xx,y-1) == tc
			if (val and not last) then
				do_fill_0(bmp,xx,y-1,tc)
			end
			last = val
		end
	end
	
	if (y < hh-1) then
		local last = nil
		for xx=l,r do
			local val = get(bmp,xx,y+1) == tc
			if (val and not last) then
				do_fill_0(bmp,xx,y+1,tc)
			end
			last = val
		end
	end
	
	-- #putaflipinit
	-- to do: why is this causing wm flicker w/ low values (0.25) ~ how is that possible?
	-- oh.. is just the app gui? need to manually hold frame again after flip. bleh.
	--[[
	if (stat(1) - fill_cpu > 2) then
		fill_cpu = stat(1) gui:draw_all() flip()
		poke(0x547c, 1) -- keep holding frame
	end
	]]
end

function do_fill(bmp, x, y)
	local tc = get(bmp, x, y)
	if (col == tc) return
	ww,hh = bmp:width(), bmp:height()
	fill_cpu = 0
	return do_fill_0(bmp, x, y, tc)
end

-- use pan of current item
-- to do: global pan/scale mode?
local mline = userdata("i16", 4096, 1)

function draw_layer(el, ii, pan_x, pan_y, scale)

	local lbmp = ii.bmp
	if (not lbmp) return
	if (ii.hidden) return
	
	local tile_w = ii.tile_w or 16
	local tile_h = ii.tile_h or 16
	
	local tile_ww = tile_w * scale
	local tile_hh = tile_h * scale

	-- pixel looking at in center
	local ww = (lbmp:width() * tile_w)
	local hh = (lbmp:height() * tile_h)
	local px = ww /2  + pan_x
	local py = hh /2 + pan_y
	
	local x0 = el.width\2  - px * scale
	local y0 = el.height\2 - py * scale
	
		
	local x1,y1 = x0 + ww * scale, y0 + hh * scale
	
	
	-- use for drawing grid lines
	local min_x = mid(0, (0 - x0) \ tile_ww - 1, lbmp:width()-1)
	local min_y = mid(0, (0 - y0) \ tile_hh - 1, lbmp:height()-1)
	local max_x = mid(0, min_x + (el.width \ tile_ww) + 2, lbmp:width()-1)
	local max_y = mid(0, min_y + (el.height \ tile_hh) + 2, lbmp:height()-1)


	if (true) then
	
		map(lbmp,0,0,x0,y0,nil,nil,0, tile_ww, tile_hh)

	-- tline
	--printh((max_x-min_x)*(max_y-min_y))
	--if ((max_x-min_x)*(max_y-min_y) > 2000) then
	elseif (false) then -- testing tline3d
		
		local last_myi = -10000
		for y=0, el.height-1 do
			-- where in map?
			local my = (y - y0) / tile_hh
			if (my >=0 and my < lbmp:height()) then
				if last_myi ~= my\1 then
					last_myi = my\1
					-- if (last_myi>=0 and last_myi<lbmp:height()) 
					if (true) -- should be clipped!
					then
						blit(lbmp,mline,0,last_myi,0,0,lbmp:width(),1) -- copy line
					end
				end
				tline3d(mline,x0,y,x0+ww*scale,y,   0,my%1,lbmp:width(),my%1)
			end
		end

	end

	-- grid lines on current grid (to do: tinted)
	-- don't draw when pressing space in text editor
	if (key("space") and ii == ci and not gui:get_keyboard_focus_element()) then
		fillp() pal()
		--fillp(0xff00)
		for x=min_x*tile_ww,max_x*tile_ww,tile_ww do
			line(x0+x,y0,x0+x,y1-1,0x0201)
		end
	
		--fillp(0x6666)
		for y=min_y*tile_hh,max_y*tile_hh,tile_hh do
			line(x0,y0+y,x1-1,y0+y,0x0201)
		end
		
		fillp()
	end 
	
end


function create_outline(bmp, ww, hh)

	--printh("creating outline: "..pod{ww,hh})

	local out = userdata("u8", ww+2, hh+2) -- 1px boundary
	set_draw_target(out)
	
	sspr(bmp, 0, 0, _, _,1, 1, ww, hh)
	
	ww += 2 hh += 2
	
	local out0 = out:copy()
	
	--out = out:add(out, out, nil, 2) -- whoa!
	-- src_offset, dest_offset, item_width, src_stride, dest_stride, num_items
	out:add(out0, true, ww+1, ww+0, ww-1, ww, ww, hh-2)
	out:add(out0, true, ww+1, ww+2, ww-1, ww, ww, hh-2)
	out:add(out0, true, ww+1, ww*0+1, ww-1, ww, ww, hh-2)
	out:add(out0, true, ww+1, ww*2+1, ww-1, ww, ww, hh-2)
	
	-- disco
	for y=0,hh-1 do
		out:add(8+((y\3)%3)*8, true, 0, y*ww, 4, 0, 8, ww/8+1)
	end
	
	out:add(8, true,  0, 0, ww*4, ww, ww*8, hh/8+1)
	
	set_draw_target()
	return out
end


function udrectfill(ud, x0, y0, x1,y1, col)
	if (type(ud) ~= "userdata") return
	x0\=1 y0\=1 x1\=1 y1\=1
	if (x1<x0)x0,x1=x1,x0
	if (y1<y0)y0,y1=y1,y0
	
	x0 = max(0, x0)
	y0 = max(0, y0)

	local width, height = (x1-x0)+1, (y1-y0)+1
	width = min(width, ud:width()-x0)
	height = min(height, ud:height()-y0)
	
	if (width < 1 or height < 1) return
	
	local udw = ud:width()
	ud:copy(col, true, nil, x0+y0*udw,width, nil,udw,height)
end


function create_canvas(el)
	local ww,hh,x0,y0
	local drag_x0,drag_y0 = 0,0
	
	function el:update(msg)
	
		el.cursor = "crosshair"
		if (mtool == "pan") el.cursor = "grab"
		if (mtool == "fill") el.cursor = icons.bucket_cursor

		-- safety [during dev]
		ci.zoom = item[1].zoom or 1
		ci.pan_x = item[1].pan_x or 0
		ci.pan_y = item[1].pan_y or 0
		
		-- temporary: set layer to size of sprite 0
		-- (later: allow per-layer tile size)
		local spr0 = get_spr(0)
		if (spr0) ci.tile_w, ci.tile_h = spr0:width(), spr0:height()
		

		tile_w = ci.tile_w
		tile_h = ci.tile_h
		ww = cbmp_width  * ci.zoom * tile_w
		hh = cbmp_height * ci.zoom * tile_h

		mtool = ctool
		if (key"space") mtool = "pan"
		if (key"s") mtool = msg.mb and msg.mb > 1 and "pick" or "select"
		
		-- pixel looking at in center
		local px = (cbmp_width * tile_w) /2  + ci.pan_x
		local py = (cbmp_height * tile_h) /2 + ci.pan_y
		
		x0 = el.width\2  - px * ci.zoom
		y0 = el.height\2 - py * ci.zoom
	end
	
	function el:click(msg)
		
		backup_state()

		if mtool == "select" or mtool == "pick" then
			-- needs to happen first for calculating x,y
			clear_selection()
		end


		local x = (msg.mx - x0) \ (ci.zoom * tile_w)
		local y = (msg.my - y0) \ (ci.zoom * tile_h)
		local xx,yy = x,y
		
		if (ci.layer) x-= ci.layer_x y-= ci.layer_y

		-- targe bitmap: draw to floating layer if it exists
		local tbmp = ci.layer or cbmp 
		local tbmp_width, tbmp_height = tbmp:attribs()
		if (type(tbmp)~="userdata") tbmp=cbmp printh("** no tbmp!!")

		drag_x0  = x  drag_y0  = y
		click_x0 = x  click_y0 = y 
		click_xx0 = xx  click_yy0 = yy
		op_bmp = tbmp:copy()
		blit(tbmp, op_bmp) -- to do: remove
		
		if mtool == "fill" and not key"space" and msg.mb == 1 then
			do_fill(tbmp, x, y)
		end
		--[[
		if (mtool == "pick") then
			-- 1x1 selection (dupe)
			
			ci.layer = userdata("i16",1,1)
			ci.layer_x = xx
			ci.layer_y = yy
			ci.layer0 = cbmp:copy()
			ci.layer0:set(xx,yy,0) -- cut out
			-- copy from map to floating layer
			blit(cbmp,ci.layer,xx,yy,0,0,1,1)
		end
		]]
		-- replace
		if (mtool == "pencil" and key"ctrl") then
			local col0 = get(tbmp, x,y)
			for yy=0,tbmp_height-1 do
				for xx=0,tbmp_width-1 do
					if (get(tbmp,xx,yy) == col0) set(tbmp,xx,yy,col)
				end
			end
		end
		
		
	end
	
	
	function el:drag(msg)

		local tbmp = ci.layer or cbmp 
		
		-- set_draw_target(cbmp)
		
		local x = (msg.mx - x0) \ (ci.zoom * tile_w)
		local y = (msg.my - y0) \ (ci.zoom * tile_h)
		local draw_target = ci.bmp
		local xx,yy = x,y
		if (ci.layer) then
			-- set_draw_target(ci.layer)
			draw_target = ci.layer
			x-= ci.layer_x y-= ci.layer_y
		end
		
		if (mtool == "pan" or key"space") then
			--ci.pan_x -= msg.dx / ci.zoom
			--ci.pan_y -= msg.dy / ci.zoom
			item[1].pan_x -= msg.dx / ci.zoom
			item[1].pan_y -= msg.dy / ci.zoom
			
		elseif (mtool == "select") then
			-- xx,yy -- not relative to selection
			set_draw_target(csel)
			rectfill(0,0,1024,1024,0)
			rectfill(click_xx0 +.5, click_yy0 +.5, xx +.5, yy +.5, 1)
			csel_outline = nil -- regenerate
		elseif (mtool == "pick") then
			-- 1x1 selection (dupe)
			
			ci.layer = userdata("i16",1,1)
			ci.layer_x = xx
			ci.layer_y = yy
			ci.layer0 = cbmp:copy()
			ci.layer0:set(xx,yy,0) -- cut out
			-- copy from map to floating layer
			blit(cbmp,ci.layer,xx,yy,0,0,1,1)
		elseif (msg.mb == 2) then
			-- anything after this: mb2 means pick up tile
			col = get(tbmp, x, y)
		elseif (mtool == "pencil" or mtool == "eraser") then
			if (msg.mb == 1) then
				local dx, dy = x-drag_x0, y-drag_y0
				local steps = max(abs(dx),abs(dy))
				dx /= steps dy /= steps
				local xx = drag_x0
				local yy = drag_y0
				
				for i=0,steps do
					set(draw_target, xx, yy, col)
					xx += dx
					yy += dy
				end
			
			end
		elseif mtool == "rect" then
			blit(op_bmp, tbmp)
			udrectfill(tbmp, click_x0 +.5, click_y0 +.5, x +.5, y +.5, col)
		elseif mtool == "stamp" then
			if (last_stamp_bmp_str ~= get_clipboard()) then
				last_stamp_bmp_str = get_clipboard()
				last_stamp_bmp = unpod(last_stamp_bmp_str)
			end
		
			local bmp = last_stamp_bmp
			if (type(bmp) == "userdata") then
				blit(op_bmp, tbmp)
				local ww,hh = bmp:attribs()
				blit(bmp, tbmp, 0, 0, x, y) -- tlc more common; to do: option
				--blit(bmp, tbmp, 0, 0, x - ww/2 + (ww&1)/2, y - hh/2 + (hh&1)/2)
				
			end
			
		elseif mtool == "line" then
			blit(op_bmp, tbmp)
			--line(click_x0 +.5, click_y0 +.5, x +.5, y +.5, col) -- to do -- draw line on tbmp
		end
		
		drag_x0 = x 
		drag_y0 = y
		
		-- update cbmp with any changes drawn to ci.layer
		if (ci.layer) blit(ci.layer, cbmp, 0, 0, ci.layer_x, ci.layer_y)
		
	end

	function el:release(msg)
		
		local x = (msg.mx - x0) \ (ci.zoom * tile_w)
		local y = (msg.my - y0) \ (ci.zoom * tile_h)
		
		if (mtool == "select") then
			if (click_x0 == x and click_y0 == y) then
				-- can't select single tile unless hold for a half a second
				-- deselect
				clear_selection()
			else
				-- create floating layer
				if (x < click_x0) click_x0,x = x,click_x0
				if (y < click_y0) click_y0,y = y,click_y0
				local ww = x - click_x0 + 1
				local hh = y - click_y0 + 1
				
				ci.layer = userdata("i16",ww,hh)
				ci.layer_x = click_x0
				ci.layer_y = click_y0
				
				-- copy of the image 
				ci.layer0 = cbmp:copy()
				-- .. with that area cut out
				udrectfill(ci.layer0, click_x0, click_y0, click_x0 + ww-1, click_y0 + hh-1, 0)

				-- copy from map to floating layer
				blit(cbmp,ci.layer,click_x0, click_y0,0,0,ww,hh)
			end
		end	
		click_x0, click_y0 = nil -- don't draw a selection in progress
	end
	
	function el:draw(msg)
		
		local x = (msg.mx - x0) \ (ci.zoom * tile_w)
		local y = (msg.my - y0) \ (ci.zoom * tile_h)
		
		local scale = ci.zoom
		local tile_ww = tile_w * scale
		local tile_hh = tile_h * scale
		
		
		fillp(0x936c)
		rectfill(0,0,self.width,self.height,1)
		fillp()
		rectfill(x0-1,y0-1,x0+ww,y0+hh,0)
		rect   (x0-2,y0-2,x0+ww+1,y0+hh+1,6)
		
		-- draw bottom to top
		for i=#item,1,-1 do
			draw_layer(el, item[i], item[1].pan_x, item[1].pan_y, item[1].zoom)
		end
		
		
		--[[
		-- tline version: draw a bunch of tlines; clip to viewable area
		-- only works for n^2 map sizes
		local yy0=max(0,0-y0)
		local yy1=min(hh,self.height-y0)-1
		for yy=yy0,yy1 do
			local sy = y0+yy
			-- 0x100 for half-open mode (don't draw last pixel -- simplifies math)
			tline3d(cbmp, x0,sy,x1,sy, 0,yy/tile_hh,cbmp:width(),yy/tile_hh, nil,nil,0x100)
		end
		]]
		
		-- edge guidelines
		--[[
		line(x0-1, 0, x0-1, 1000, 5)
		line(x1+0, 0, x1+0, 1000, 5)
		line(0, y0-1, 1000, y0-1, 5)
		line(0, y1+0, 1000, y1+0, 5)
	 
		print(pod{yy0, yy1, stat(1)},20,20,7)
		]]
		
		
		
		fillp()


		---------- draw selection

		if (false) then
--		if (csel) then
		
			local sel_scale = min(scale, 0.5)

			while sel_scale < scale and 
				sel_scale * cbmp:width() * tile_w < 128 and
				sel_scale * cbmp:height() * tile_h < 128 do
				sel_scale += 1
			end
			local sel_ww = cbmp:width() * tile_w * sel_scale
			local sel_hh = cbmp:height() * tile_h * sel_scale
		
			-- to do: also update high bits in image to protect
			-- pixels outside of selection from modification
--[[
			if (not csel_outline or sel_ww ~= last_outline_ww) then
				csel_outline = create_outline(csel, sel_ww, sel_hh)
				last_outline_ww = sel_ww
			end
]]
		
			--spr(csel_outline,x0,y0)
			for i=0,63 do
				palt(i,true)
			end
			palt(1,false) palt(2,false)
			
			pal(1,7) pal(2,7)
			
			local cc=(t()*8)%8
			pal(9,  8 + (cc+0)%8)
			pal(17, 8 + (cc+2)%8)
			pal(25, 8 + (cc+4)%8)
			pal(33, 8 + (cc+6)%8)
			
			
			fillp(0xc936936c36c96c93 >> (((time()*15)\1)%4)*16)
			
			-- to do: fix matching
			local qq = 1
			if (sel_scale < scale) qq = 2
			
			--qq = scale / sel_scale
			--pal() fillp()

			pal()

			
--			sspr(csel_outline, 0, 0, _, _, x0-qq, y0-qq, ww+qq*2, hh+qq*2)

			
			
		end

		pal()
		fillp(0xc936936c36c96c93 >> (((time()*15)\1)%4)*16)

		if (ci.layer and ci.layer_x) then
			local sx0 = x0 + ci.layer_x * tile_w * scale
			local sy0 = y0 + ci.layer_y * tile_h * scale
			local sx1 = sx0 + ci.layer:width() * tile_w * scale
			local sy1 = sy0 + ci.layer:height() * tile_h * scale

			rect(sx0-1,sy0-1,sx1,sy1,0x0701)

		elseif (click_x0 and mtool == "select" and msg.mb == 1) then
		
			-- selection in progress
			local mx0 = click_x0
			local my0 = click_y0
			local mx1 = x
			local my1 = y
			if (mx0 > mx1) mx0,mx1 = mx1,mx0
			if (my0 > my1) my0,my1 = my1,my0
			
			local sx0 = x0 + mx0 * tile_w * scale
			local sy0 = y0 + my0 * tile_h * scale
			local sx1 = x0 + (mx1+1) * tile_w * scale
			local sy1 = y0 + (my1+1) * tile_h * scale

			rect(sx0-1,sy0-1,sx1,sy1,0x0701)

		end

		fillp() pal()

		print(string.format("\#0 %3d %3d ",x,y), 12,  self.height-14, 6)
		
		--print(stat(1),10,10,7)

--		if (ci.layer) print("layer: "..pod{ci.layer_x,ci.layer_y,ci.layer:attribs()}, 20, 20,7) -- to do: draw selection. create_outline on demand etc
--		print("mtool: "..mtool,20,30,7)
	end
	
	function el:mousewheel(msg)
	
		local ii = item[1] -- global zoom for now
		if (ii.zoom <= 1) then
			if (msg.wheel_y < 0) ii.zoom /= 2
			if (msg.wheel_y > 0) ii.zoom *= 2
		else
			ii.zoom += msg.wheel_y
		end
		
		local min_scale = 0.25
		local max_scale = 16 -- was 4
		
		-- can zoom out further when wouldn't fit otherwise
		-- if (cbmp:width()  >= self.width ) min_scale = 0.5
		-- if (cbmp:height() >= self.height) min_scale = 0.5		
		
		ii.zoom = mid(min_scale, ii.zoom, max_scale)
		if (ii.zoom >= 1) ii.zoom \= 1
	end
	
	
	return el
end





































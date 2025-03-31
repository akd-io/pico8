--[[pod_format="raw",created="2023-04-11 02:04:02",modified="2024-08-18 16:06:41",revision=4007,stored="2023-24-28 00:24:00"]]
local ww,hh=0,0
local fill_cpu=0
local x0,y0=0,0
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
	ww,hh = bmp:attribs()
	fill_cpu = 0
	return do_fill_0(bmp, x, y, tc)
end

function create_outline(bmp, ww, hh)

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
	local mtool
	
	
	
	function el:update()
	
		el.cursor = "crosshair"
		if (mtool == "pan") el.cursor = "grab"
		if (mtool == "fill") el.cursor = get_spr(56)
		
		
		-- safety [during dev]
		ci.zoom = ci.zoom or 1
		ci.pan_x = ci.pan_x or 0
		ci.pan_y = ci.pan_y or 0
		
		ww = cbmp_width  * ci.zoom
		hh = cbmp_height * ci.zoom
		
		mtool = ctool
		if (key"space") mtool = "pan"
		if (key"s") mtool = "select"
		
		-- pixel looking at in center
		local px = cbmp_width/2  + ci.pan_x
		local py = cbmp_height/2 + ci.pan_y
		
		x0 = el.width\2  - px * ci.zoom
		y0 = el.height\2 - py * ci.zoom
		
	end
	
	function el:click(msg)
		backup_state()
		
		if mtool == "select" then
			-- needs to happen first for calculating x,y
			clear_selection()
		end
		
		local x = (msg.mx - x0) \ ci.zoom
		local y = (msg.my - y0) \ ci.zoom
		local xx,yy = x,y
		if (ci.layer) x-= ci.layer_x y-= ci.layer_y
		--printh("click: "..pod{x,y})
		
		
		-- targe bitmap: draw to floating layer if it exists
		local tbmp = ci.layer or cbmp 
		local tbmp_width, tbmp_height = tbmp:attribs()
		if (type(tbmp)~="userdata") tbmp=cbmp printh("** no tbmp!!")
		
		drag_x0  = x  drag_y0  = y
		click_x0 = x  click_y0 = y 
		click_xx0 = xx  click_yy0 = yy
		op_bmp = tbmp:copy()
		blit(tbmp, op_bmp) -- to do: remove
		
		
		
		if mtool == "fill" then
			do_fill(tbmp, x, y)
		end
		
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
		-- targe bitmap: draw to floating layer if it exists
		local tbmp = ci.layer or cbmp 
		
		set_draw_target(tbmp)
		
		local x = (msg.mx - x0) \ ci.zoom
		local y = (msg.my - y0) \ ci.zoom
		local xx,yy = x,y
		if (ci.layer) then
			set_draw_target(ci.layer)
			x-= ci.layer_x y-= ci.layer_y
		end
		
		if (mtool == "pan") then
			ci.pan_x -= msg.dx / ci.zoom
			ci.pan_y -= msg.dy / ci.zoom
		elseif mtool == "stamp" then
			if (last_stamp_bmp_str ~= get_clipboard()) then
				last_stamp_bmp_str = get_clipboard()
				last_stamp_bmp = unpod(last_stamp_bmp_str)
			end
		
			local bmp = last_stamp_bmp
			if (type(bmp) == "userdata") then
				blit(op_bmp, tbmp)
				set_draw_target(tbmp)
				local ww,hh = bmp:attribs()
				-- inverted pico-8 behaviour! transparency by default
				if (key"ctrl") rectfill(x-ww/2,y-hh/2,x+ww/2-1,y+hh/2-1,0)
				spr(bmp, x - ww/2, y - hh/2)
				set_draw_target()
			end
		
		elseif (mtool == "select") then
			-- xx,yy -- not relative to selection
			csel:clear()
			set_draw_target(csel)
			rectfill(click_xx0 +.5, click_yy0 +.5, xx +.5, yy +.5, 1)
			set_draw_target()
			csel_outline = nil -- regenerate
		elseif (mtool == "pencil" or mtool == "brush") then
			if (msg.mb == 1) then
				local dx, dy = x-drag_x0, y-drag_y0
				local steps = max(abs(dx),abs(dy)) * 2
				dx /= steps dy /= steps
				local xx = drag_x0
				local yy = drag_y0
				if (mtool == "brush") then
					-- provisional rule:
					-- only transparent when draw colour is not 0
					fillp(brush.pat) poke(0x550b,col == 0 and 0x00 or 0xff)
					pal(7,col)
					local brush_sprite = brush_gfx[brush.which]
					
					for i=0,steps do
						--circfill(xx, yy, brush.thickness, col)
						
						spr(brush_sprite,xx-3,yy-3)
						xx += dx
						yy += dy
					end
					pal()
					fillp() palt() poke(0x550b,0x00)
				else
					for i=0,steps do
						set(tbmp, xx, yy, col)
						xx += dx
						yy += dy
					end
				end
			end
			if (msg.mb == 2) col = get(tbmp, x, y)
		elseif mtool == "circ" or mtool == "rect" then
			blit(op_bmp, tbmp)
			local func = mtool == "rect" and
				(key("ctrl") and rectfill or rect) or
				(key("ctrl") and ovalfill or oval)
			local ww,hh = x - click_x0, y-click_y0
			if key("shift") then
				if abs(ww)>abs(hh) then
					hh = ww else ww = hh
				end
			end
			func(click_x0 +.5, click_y0 +.5, click_x0 +.5 + ww, click_y0 +.5 + hh, col)
		elseif mtool == "line" then
			blit(op_bmp, tbmp)
			local x0,y0=click_x0 +.5, click_y0 +.5
			local x1,y1=x +.5, y +.5
			-- snap
			if key("shift") then
				local dx,dy = x1-x0,y1-y0
				local mag   = sqrt(dx*dx+dy*dy)
				local a     = atan2(dx,dy)
				a += 1/32
				a = (a * 16) \ 1
				a &= 15
				if (a%2 == 1) then
					-- isometric -- use 2:1 gradient
					mag = max(abs(dx),abs(dy)) \ 1
					mag = (mag+1) & ~1
					if abs(dx) > abs(dy) then
						dx,dy = sgn(dx)*mag,sgn(dy)*mag/2
					else
						dx,dy = sgn(dx)*mag/2,sgn(dy)*mag
					end
					-- one step back to get even steps (line() is not half open)
					dx -= sgn(dx)
					dy -= sgn(dy)
					
					x1 = x0 + dx
					y1 = y0 + dy
				else
					a /= 16
					x1 = x0 + cos(a) * mag
					y1 = y0 + sin(a) * mag
				end
				
			end
			line(x0,y0, x1,y1, col)
		end
		
		drag_x0 = x 
		drag_y0 = y
		
		-- update cbmp with any changes drawn to ci.layer
		if (ci.layer) blit(ci.layer, cbmp, 0, 0, ci.layer_x, ci.layer_y)
		
	end
	
	function el:release(msg)

		local x = (msg.mx - x0) \ ci.zoom
		local y = (msg.my - y0) \ ci.zoom
		
		if (mtool == "select") then
			if (click_x0 == x and click_y0 == y) then
				-- can't select single pixel; deselect
				clear_selection()
			else
				-- create floating layer
				if (x < click_x0) click_x0,x = x,click_x0
				if (y < click_y0) click_y0,y = y,click_y0
				local ww = x - click_x0 + 1
				local hh = y - click_y0 + 1
				
				ci.layer = userdata("u8",ww,hh)
				ci.layer_x = click_x0
				ci.layer_y = click_y0
				ci.layer0 = cbmp:copy()
				set_draw_target(ci.layer0)
				rectfill(click_x0, click_y0, click_x0 + ww-1, click_y0 + hh-1, 0)
				set_draw_target()
				blit(cbmp,ci.layer,click_x0, click_y0,0,0,ww,hh)
			end
		end	

	end
	
	
	function el:draw(msg)
		local x = (msg.mx - x0) \ ci.zoom
		local y = (msg.my - y0) \ ci.zoom
		
		--fillp(0x1248)
		fillp()
		rectfill(0,0,self.width,self.height,32)
		fillp()	
		
		local x1,y1 = x0 + ww, y0 + hh
		local scale = ci.zoom

		color(5)
		line(x0-2,y0-1*scale-1,x0-2,y1+1*scale)
		line(x1+1,y0-1*scale-1,x1+1,y1+1*scale)
		
		line(x0-1*scale-1,y0-2,x1+1*scale,y0-2)
		line(x0-1*scale-1,y1+1,x1+1*scale,y1+1)
		
		rectfill(x0-1,y0-1,x0+ww,y0+hh,0)
		sspr(cbmp, 0, 0, _, _, x0,y0,ww,hh)
		
		if (csel) then
		
			local sel_scale = min(scale, 1)
			while sel_scale < scale and 
				sel_scale * cbmp:width() < 512 and
				sel_scale * cbmp:height() < 512 do
				sel_scale += 1
			end
			local sel_ww = cbmp:width() * sel_scale
			local sel_hh = cbmp:height() * sel_scale
		
			-- to do: also update high bits in image to protect
			-- pixels outside of selection from modification
			if (not csel_outline or sel_ww ~= last_outline_ww) then
				csel_outline = create_outline(csel,sel_ww,sel_hh)
				last_outline_ww = sel_ww
			end
			
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
			sspr(csel_outline, 0, 0, _, _, 
				x0-qq, y0-qq, ww+qq*2, hh+qq*2)
			
		end
		
		--print(pod{sel_scale,x0,y0,ww,hh},2,2,7)
		pal() fillp()
		
		print(string.format("\#0 %3d %3d ",x,y), 12,  self.height-14, 6)
		
		
		
		--print(pod{ci.pan_x, ci.pan_y, ci.zoom},2,2,7)
	end
	
	function el:mousewheel(msg)
	
		ci.zoom += msg.wheel_y
		--scale *= (msg.wheel_y < 0) and 0.5 or 2.0
		
		 -- to do: can scale 0.5 for large images?
		
		local min_scale = 1.0
		local max_scale = 16.0
		
		-- can zoom out further when wouldn't fit otherwise
		if (cbmp:width()  >= self.width ) min_scale = 0.5
		if (cbmp:height() >= self.height) min_scale = 0.5		
		
		ci.zoom = mid(min_scale, ci.zoom, max_scale)
		if (ci.zoom >= 1) ci.zoom \= 1
	end
	
	return el

end


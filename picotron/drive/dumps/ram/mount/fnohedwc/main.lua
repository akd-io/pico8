--[[pod_format="raw",created="2023-04-11 02:04:54",modified="2024-08-18 16:06:41",revision=3825,stored="2023-24-28 00:24:00"]]
--[[
	gfx6: region selection / multi-copy/paste
]]

include "draw.lua"
include "update.lua"
include "gui.lua"
include "canvas.lua"
include "pal.lua"
include "nav.lua"
include "undo.lua"

cbmp,cbmp_width,cbmp_height,csel = nil,nil,nil

--[[
	selection layer state is not saved
]]
function save_working_file()
	--printh("@@ [gfx] saving working file")
	local output = {}
	for i=0,#item do
		local ii=item[i]
		output[i] = {
			bmp = ii.bmp,
			flags = ii.flags,
			pan_x = ii.pan_x,
			pan_y = ii.pan_y,
			zoom = ii.zoom,
			extra = ii.extra
		}
	end
	return output
end

function load_working_file(item_1)

	item_1 = item_1 or {}

		item = {}
		for i=0,255 do
			src = item_1[i] or {}
			item[i] = {
				bmp   = src.bmp or userdata("u8",16,16),
				sel   = src.sel or userdata("u8",16,16),
				flags = src.flags or 0,
				extra = src.extra or nil, -- text. maybe "notes"?
				pan_x = src.pan_x or 0,
				pan_y = src.pan_y or 0,
				zoom = src.zoom or 8
			}
			
			if (i==0 and not src.bmp) then
				-- x
				item[i].bmp:set(6,6,7,0,0,7)
				item[i].bmp:set(6,7,0,7,7,0)
				item[i].bmp:set(6,8,0,7,7,0)
				item[i].bmp:set(6,9,7,0,0,7)
			end
			
			add_undo_stack(item[i])
			
			--printh("loaded item "..i.."  bmp width:"..item[i].bmp:width())
		end	
		
	set_current_item(0)
	
end

function _init()

	poke(0x4000,get(fetch"/system/fonts/p8.font"))
	
	window{
		tabbed = true,
		icon = userdata"[gfx]08087770077777700777777007777777777770777707707777077777777700000000[/gfx]"
	}
	
	mkdir("/ram/cart/gfx")
	
	wrangle_working_file(
		save_working_file,
		load_working_file,
		"/ram/cart/gfx/0.gfx" -- default
	)
	
	set_current_item(1)
	set_current_bank(0)
	
	-- region of selected sprites
	region={
		x=1,y=0,w=1,h=1,
		x0=1,y0=0
	}
	
	item0,item1,item2 = 1,1,1

	generate_gui()
	
	col = 7
	ctool = "pencil"
	
	brush = {
		spacing=1,
		thickness=2,
		which=3,
		pat=0x0
	}
	
	refresh_gui = true
	
end

function set_current_bank(i)
	--printh("setting bank: "..i)
	current_bank = i
end

function set_neighbours_view(i, di)
	if (not i) return
	if (i < 0 or i > 255) return
	local b = item[i].bmp
	if (b and b:width() == cbmp_width and b:height() == cbmp_height) then
		item[i].pan_x = ci.pan_x
		item[i].pan_y = ci.pan_y
		item[i].zoom  = ci.zoom
		set_neighbours_view(i + di, di)
	end
end

function set_current_item(i, show_in_navigator)

	i = (i or current_item)\1
	if (not item[i]) return -- out of range
	
	if (current_item) then
		set_neighbours_view(current_item+1,1)
		set_neighbours_view(current_item-1,-1)
	end
	
	current_item = i
	ci = item[current_item]

	cbmp = item[current_item].bmp
	cbmp_width, cbmp_height = cbmp:width(), cbmp:height()

	if not item[current_item].sel or
		item[current_item].sel:width() ~= cbmp_width or
		item[current_item].sel:height() ~= cbmp_height
	then
		item[current_item].sel = userdata("u8",cbmp_width, cbmp_height)
	end
	
	csel = item[current_item].sel
	csel_outline = item[current_item].sel_outline
	
	-- single-item region moves with current_item
	if (not region or (region.w==1 and region.h==1)) then
		local rx = current_item % 8
		local ry = current_item \ 8
		region={x=rx,y=ry,x0=rx,y0=ry,w=1,h=1}
	end

	if (show_in_navigator) then
		current_bank = current_item \ 64
	end
	
	-- generate_gui()
	-- refresh_gui = true
end

on_event("lost_focus",
	function (msg)
		map_gfx_state = map_gfx_state or fetch"/ram/shared/map_gfx.pod" or {}
		map_gfx_state.current_sprite_index = current_item
		map_gfx_state.gfx_proc_id = pid()
		store("/ram/shared/map_gfx.pod", map_gfx_state)
	end
)

on_event("gained_focus",
	function()
		map_gfx_state = fetch"/ram/shared/map_gfx.pod"
		if (map_gfx_state) then
			set_current_item(map_gfx_state.current_sprite_index, true)
		end
	end
)

on_event("set_palette",
	function(msg)
		if (type(msg.palette) == "userdata") then
			local w, h, type = msg.palette:attribs()
			if (w == 64 and type == "i32") then
				custom_palette = msg.palette
			end
		end
	end
)

--[[
	
]]
function colour_fit(bmp, pal0)

	local cols = pal0:width()
	local pal1 = {}
	
	for i=0,cols-1 do
		local r = (pal0:get(i) >> 16) & 0xff
		local g = (pal0:get(i) >>  8) & 0xff
		local b = (pal0:get(i) >>  0) & 0xff
		
		local best_dist, best_col = 100000000, 0
		for i=0,63 do
			local r1 = peek(0x5000+i*4+2)
			local g1 = peek(0x5000+i*4+1)
			local b1 = peek(0x5000+i*4+0)
			local dist = (r1-r)^2 + (g1-g)^2 + (b1-b)^2
			if (dist < best_dist) best_col = i best_dist = dist
		end
		
		pal1[i] = best_col
	end
	
	-- set draw pal and draw on to self
	palt(0) -- no transparency
	pal(pal1)
	
	set_draw_target(bmp)
	spr(bmp)
	set_draw_target()
	
	return bmp
end


on_event("drop_items",function(msg)

	-- single file for now
	local dropped_item = msg.items[1]
	if dropped_item and dropped_item.pod_type == "file_reference" and 
		type(dropped_item.fullpath) == "string" and
		dropped_item.fullpath:ext() == "png" then
		
		local g = fetch(dropped_item.fullpath)
		if (type(g) == "userdata") then
			
			local bmp, pal1 = g:convert("u8", true)
			backup_state()
			item[current_item].bmp = colour_fit(bmp, pal1)
			set_current_item(current_item)
			clear_selection()
		end

	else
		notify("could not load dropped file")
	end
	
	
end)




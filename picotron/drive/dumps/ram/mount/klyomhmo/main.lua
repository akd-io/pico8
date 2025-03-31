--[[pod_format="raw",created="2023-04-11 02:04:54",modified="2024-07-18 22:58:53",revision=3148]]
--[[
	Picotron Map Editor
]]
include "draw.lua"
include "update.lua"
include "gui.lua"
include "canvas.lua"
include "nav.lua"
include "undo.lua"
-- deleteme
cbmp,cbmp_width,cbmp_height = nil,nil,nil

-- to do: unify with load_working_file
function create_default_maps()
	-- default maps
	bmp = {}
	item = {}
	for i=1,1 do
		item[i] = {
			bmp   = userdata("u16",32,32),
			name = nil, --"layer "..i, -- later: custom names for layers
			extra = nil, -- text. maybe "notes"?
			pan_x = 0,
			pan_y = 0,
			scale = 1,
			tile_w = 16,
			tile_h = 16
		}
		add_undo_stack(item[i])
	end
end

function save_working_file()
	local output = {}
	for i=1,#item do
		local ii=item[i]
		output[i] = {
			name = ii.name,
			bmp = ii.bmp,
			pan_x = ii.pan_x,
			pan_y = ii.pan_y,
			zoom = ii.zoom,
			tile_w = ii.tile_w,
			tile_h = ii.tile_h,
			hidden = ii.hidden
		}
	end
	
	return output
end

function load_working_file(item_1)
	
	item_1 = type(item_1) == "table" and item_1 or {}
	
	-- dev legacy: zero-based layer collection
	if (not item_1[1] and item_1[0]) then
		item_1 = {item_1[0]}
	end
	item = {}

	for i=1,#item_1 do
		if (type(item_1.layer)=="table") item_1 = item_1.layer -- legacy
		item[i] = item_1[i] or {}
		
		local itm = item[i]

		itm.bmp   = itm.bmp or userdata("i16",16,16)
		itm.sel   = itm.sel or userdata("u8", 16,16)
		itm.name  = itm.name or nil
		itm.extra = itm.extra or nil -- text. maybe "notes"?
		itm.pan_x = itm.pan_x or 0
		itm.pan_y = itm.pan_y or 0
		itm.zoom  = itm.zoom or 1
		itm.tile_w = itm.tile_w or 16
		itm.tile_h = itm.tile_h or 16
		itm.hidden = itm.hidden or false
		add_undo_stack(item[i])
	end	
	
	set_current_item(1)
	
end

--[[
	load everything in /ram/cart/gfx
	to do: per bank invalidation
	to do: gfx files relative to map file?
		-- might want to make maps outside of cart context
]]
function load_spritebanks()
--	printh(" -- load_spritebanks() --")
	gfx_ls = ls("/ram/cart/gfx")
	gfx_file = {}
	for i=1,#gfx_ls do
		local fn = gfx_ls[i]
		local num = tonum(string.sub(fn,1,1))
		fn = "/ram/cart/gfx/"..fn 
--		printh("loading "..fn)
		if (num) then
			gfx_file[num] = fn
			local gfx_dat = fetch(fn)
			if (type(gfx_dat == "table") and gfx_dat[0] and gfx_dat[0].bmp) then
				for i=0,#gfx_dat do
					set_spr(num * 256 + i, gfx_dat[i].bmp)
				end
			end
		end
	end
end

function _init()
	
	poke(0x4000,get(fetch"/system/fonts/p8.font"))
	--poke(0x4002,6) -- to do: should be attribute of p8.font
	
	-- default filename is dummy for now
	-- note: saved inside self (gfx.p64) when loaded as cproj
	--create_default_bank()
	window{
		tabbed = true,
		icon = userdata"[gfx]08080000077777770777777707777777000077777770777777707777777000000000[/gfx]"
	}
		
	mkdir("/ram/cart/map")
	
	wrangle_working_file(
		save_working_file,
		load_working_file,
		"/ram/cart/map/0.map" -- default
	)

	load_spritebanks()
	
	set_current_item(1)
	set_current_bank(0)
	set_current_bank_page(0)
	
	generate_gui()
	
	col = 1 -- sprite index
	
	ctool = "pencil"
	mtool = ctool
	if (key"s") mtool = "select"
	
	brush = {
		spacing=1,
		thickness=2,
		which=3,
		pat=0x0
	}
	
	refresh_gui = true
	
end
function set_current_bank_page(i)
	--printh("setting bank: "..i)
	current_bank_page = i
end
function set_current_bank(i, di)

	i = i or current_bank

	if (di) then
		
		local i0 = i
		i += di
		if (not gfx_file[i]) then
			i = (i + di) % 64
			while (not gfx_file[i] and i ~= i0) do
				i = (i + di) % 64
			end
		end
	end
	
	current_bank = i
	refresh_gui = true
end
function set_current_item(i)

	-- to do: remove
	if (#item == 0) then
		create_default_maps()
	end

	assert(#item > 0)
	i = i or current_item
	i = mid(1, i, #item)
	--printh("setting item: "..i)
	current_item = flr(i)  -- want it to be an integer
	ci = item[current_item]
	cbmp = item[current_item].bmp
	cbmp_width, cbmp_height = cbmp:width(), cbmp:height()

	-- selection
	if not item[current_item].sel or
		item[current_item].sel:width()  ~= cbmp_width or
		item[current_item].sel:height() ~= cbmp_height
	then
		item[current_item].sel = userdata("u8", cbmp_width, cbmp_height)
	end
	
	csel = item[current_item].sel
	csel_outline = item[current_item].sel_outline
end

on_event("lost_focus",
	function (msg)
		map_gfx_state = map_gfx_state or fetch"/ram/shared/map_gfx.pod" or {}
		map_gfx_state.current_sprite_index = col
		map_gfx_state.map_proc_id = pid()
		store("/ram/shared/map_gfx.pod", map_gfx_state)
	end
)
on_event("gained_focus",
	function (msg)
		--printh("@@ [map] reloading spritebanks on gaining focus")
		load_spritebanks()

		-- temporary: set tile sizes to sprite0
		local spr0 = get_spr(0)
		if (spr0) then
			for i=1,#item do
				item[i].tile_w, item[i].tile_h = spr0:width(), spr0:height()
			end
		end

		
		map_gfx_state = fetch"/ram/shared/map_gfx.pod"
		if (map_gfx_state) then
			col = map_gfx_state.current_sprite_index
			sprite_bank = col \ 256
			sprite_bank_page = (col%256) \ 64
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



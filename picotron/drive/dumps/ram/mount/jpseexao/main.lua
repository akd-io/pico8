--[[pod_format="raw",created="2023-02-24 19:02:00",modified="2024-06-06 06:13:11",revision=330]]
local ce

function _draw()

	g:draw_all() -- covers whole screen; don't need to cls()

end

function _update()

	-- code editor always has keyboard focus when search is not open
	if (not ce:search_box_is_open()) ce:set_keyboard_focus(true)

	g:update_all()

end

function apply_settings()
	if (not sdat) return
	
	poke(0x4000, get(sdat.monospace and
		fetch("/system/fonts/lil_mono.font") or		
		fetch("/system/fonts/lil.font")
	))
	
	-- update menu items
	menuitem{id="monospace", label = sdat.monospace and
		"\^:007f4f4f4f7f0000 Monospace:On" or
		"\^:007f7979797f0000 Monospace:Off"
	}
	
	-- live editor update (just stuff everything in there)
	if (ce) then
		for k,v in pairs(sdat) do
			ce[k] = v
		end
	end
	
end

function store_settings()
	store("/appdata/system/code.pod",sdat)
end


function _init()

	sdat = fetch("/appdata/system/code.pod") 
	
	if not sdat then
		sdat = {
			monospace = false,
			bgcol = 1,
			curcol = 14,
			selcol = 10,
			lncol = 16,
			syntax_highlighting = true,
			show_line_numbers = true
		}
		store("/appdata/system/code.pod", sdat)
	end

	window{
		tabbed = true,
		icon   = userdata("[gfx]08080770077077000077770000777700007777000077770000770770077000000000[/gfx]"),
	}

	g = create_gui()
	
	ce = g:attach_text_editor({
		x=0,y=0,
		width=get_display():width(),
		height=get_display():height(),
		syntax_highlighting=sdat.syntax_highlighting,
		show_line_numbers=sdat.show_line_numbers,
		markup=false, -- to do: remove markup from editor widget
		embed_pods=true,
		has_search=true,
		bgcol = sdat.bgcol,
		curcol = sdat.curcol,
		selcol = sdat.selcol	,
		lncol = sdat.lncol
	})

	ce:attach_scrollbars()
	
	wrangle_working_file(

		-- save to obj
		function ()
			return table.concat(ce:get_text(),"\n")
		end,

		-- load from obj (assumed to be a string)
		function (str, meta)
			local text = split(str, "\n", false)
			--if (text) printh("code: loaded "..#text.." lines")
			if (not text or #text == 0) then text = {""} end
			ce:set_text(text)
			ce.syntax_highlighting = pwf():ext() == "lua"
		end,

		-- default filename
		"untitled.lua", 

		-- location string
		function()
			local x,y = ce:get_cursor()
			return y
		end,

		-- process location string. if it is a number, jump to that number
		-- to do: "hoge.lua#function:foo"? or just "hoge.lua#foo" to search for that string?

		function(loc)
			--printh("code recieved loc: "..pod(loc))
			if tonum(loc) then
				--printh("[code] setting cursor y to: "..loc)
				ce:set_cursor(nil, tonum(loc))
				--ce:center_cursor(0.3) -- 0.3 put cursor nearer to top.  to do: why does this not work on first load via infobar?
			end
		end

	)
	
	-- to do: menu items
	--[[
	"\^:304884844c360300 Find Text     (CTRL-F)",
	"\^:1f003f003e007c00 Jump to Line  (CTRL-L)",
	]]
	
	--menuitem{divider=true} -- to do

	menuitem{
		stay_open = true,
		id="monospace",
		label="Monospace",
		action=function()
			sdat.monospace = not sdat.monospace
			store_settings() -- triggers apply_settings() via file change
			return true
		end
	}
	
	
	apply_settings()

	-- test
	ce:center_cursor(0.5)

end

on_event("modified:/appdata/system/code.pod",
	function(msg)
		sdat = fetch(msg.filename)
		apply_settings()
	end
)



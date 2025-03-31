--[[pod_format="raw",created="2023-10-22 07:30:04",modified="2024-09-12 16:58:56",revision=14222,stored="2023-36-29 04:36:40"]]
--[[
	Picotron Tracker
	(c) Lexaloffle Games LLP
]]

include "data.lua"
include "inst.lua"
include "track.lua"
include "env.lua"
include "gui.lua"
include "update.lua"
include "undo.lua"

include "debug.lua"

function _init()
	
	poke(0x4000, get(fetch"/system/fonts/p8.font"))
	
	window{
		tabbed=true,
		icon = userdata"[gfx]08080077777700700007007000070070000700700777777007777770000000000000[/gfx]",
		title="sfx"
	}
	
	mkdir "/ram/cart/sfx"
	
	wrangle_working_file(
		function()
			local ud = userdata("u8",0x40000)
			for i=0,0x3f do
				set(ud, i * 0x1000, peek(0x30000 + i * 0x1000, 0x1000))
			end
			return ud
		end,
		function (ud)
			if (type(ud)~="userdata") then
				init_data()
			else
				memset(0x30000, 0, 0x40000) -- incase stored short / legacy userdata
				for i=0,0x3f do
					poke(0x30000 + i * 0x1000, get(ud, i * 0x1000, 0x1000))
				end
			end
			tdat={}
			init_undo()
		end,
		"/ram/cart/sfx/0.sfx"
	)
	

	-- current node, instrument, track, pattern
	cn = 0
	ci = 0
	ct = 0
	cp = 0
	
	-- item selection ranges for instruments, tracks, patterns
	ci0,ci1,ci2 = 0,0,0
	ct0,ct1,ct2 = 0,0,0
	cp0,cp1,cp2 = 0,0,0
	
	cvol = 0x20
	coct = 4
	
	mode = "track"
	
	scroll = {} -- scroll position for choosers

	init_undo()
	
end

-- for mocking up
function draw_pane(title, x, y, w, h, col)
	col = col or 5
	y = y + 2
	rectfill(x,y,x+w-1,y+h-1,col)
	rectfill(x,y,x+w-1,y+6,7)
	print(title,x+4,y+1,1)
	
	--pset(x,y,0) pset(x+w-1,y,0)
	--pset(x,y+h-1,0)	pset(x+w-1,y+h-1,0)
end


function draw_node_attr(label, x, y)

--	rectfill(x, y, x+60, y+8, 6)


	rectfill(x+30,y,x+70,y+8,0)

	-- *2.0+1 means *2.0 relative to parent,  +1 semitone
	-- special for tune. click label to toggle between *2.0+1 and +1
	-- other attributes: click label to toggle between 1.0 and *1.0

	if (label == "tune") then
		print("*2.00+1",x+42,y+2, 13)
	else
		print("1.000",x+47,y+2, 13)
	end

	circfill(x+30,y+4,7,0)
	circ    (x+30,y+4,7,7)
	
	
	print(label, x+2, y+2, 6)

end

function _draw()


	--fillp(1)
	--fillp(~0x813d)
	fillp(~0x8239) -- brushed metal? something industrial
	rectfill(0,0,480,270,32 | (33*256))
	fillp()
	
	--rectfill(368,0,480,270,5)
	--rectfill(0,0,108,270,5)
	
--[[
	draw_pane("song info", 2,2,96,56,1)
	draw_pane("instruments",2,62,96,98,1)
	--draw_pane("mudo state",2,164,96,90,0)
]]
	
	
	-- operations during _update can request a
	-- gui update before it is next draw (avoid flicker)
	if (refresh_gui or not gui) then
		readtext(true) -- clear text input buffer
		generate_gui()
		-- gui:draw_all() expects :update_all() called first on current state of gui
		gui:update_all()
		refresh_gui = false
	end
	
	gui:draw_all()
	
	if (mode == "instrument" and grabbed_envelope) then
		local mx,my,mb=mouse()
		if (mb>0) print("\#7  env-"..grabbed_envelope,mx-3,my,17)	
	end
	
	if (mode != "instrument" and grabbed_track and time()>grabbed_track_t+.25) then
		local mx,my,mb=mouse()
		if (mb>0) then
			
			local sx,sy=mx-20,my-8
			rectfill(sx,sy,sx+39,sy+8,5)
			palt(0)
			spr(get_sfx_thumb(grabbed_track),sx+2,sy+1)
			print("sfx:"..grabbed_track,sx+12,sy+2,11)
			palt()
		end
	end
	
	-- custom display palette
	-- at end.. something in :draw_all() probably calls pal()
	poke4(0x5000+32*4, 0x202020)
	
	--poke4(0x5000+32*4, 0xf020f0) -- debug flashing
	
--	print(string.format("cpu:%3.3f",stat(1)),440,250,7)
--draw_mudo_state(380,200)
	
	
end


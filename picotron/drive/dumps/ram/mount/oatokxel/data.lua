--[[pod_format="raw",created="2023-10-24 00:36:58",modified="2024-09-12 16:58:56",revision=11004,stored="2023-36-29 04:36:40"]]

function init_track(addr)
--	printh("init_track "..addr)
	poke2(addr, 64) -- len
	poke(addr+2,16) -- spd
	poke(addr+3,0)  -- loop0
	poke(addr+4,0)  -- loop1
	poke(addr+5,0)  -- delay
	poke(addr+6,0)  -- flags (0x1 mute)
	poke(addr+7,0)  -- unused
	
	-- pitch, inst, vol: not set (0xff)
	memset(addr+8, 0xff, 64*3)
	
	-- fx, fx_p: clear
	memset(addr+8+64*3, 0x0, 64*2)
end

function clear_pattern(i)
	local addr = 0x30100 + i*20
	memset(addr,0,20)
end

function clear_instrument(i)
	local addr = 0x40000 + i * 0x200
	
	memset(addr, 0, 0x200)
	
	-- node 0: root
	poke(addr + (0 * 32), -- node 0
	
			0,    -- parent (0x7)  op (0xf0)
			1,    -- kind (0x0f): 1 root  kind_p (0xf0): 0  -- wavetable_index
			0,    -- flags
			0,    -- unused extra
				
			-- MVALs:  kind/flags,  val0, val1, envelope_index
			
			0x2|0x4,0x20,0,0,  -- volume: mult. 0x40 is max (-0x40 to invert, 0x7f to overamp)
			0x1,0,0,0,     -- pan:   add. center
			0x1,0,0,0,     -- tune: +0 -- 0,48,0,0 absolute for middle c (c4) 261.6 Hz
			0x1,0,0,0,     -- bend: none
			-- following shouldn't be in root
			0x0,0,0,0,     -- wave: use wave 0 
			0x0,0,0,0      -- phase 
	)
	
	
	-- node 1: sine
	poke(addr + (1 * 32), -- instrument 0, node 1
	
			0,    -- parent (0x7)  op (0xf0)
			2,    -- kind (0x0f): 2 osc  kind_p (0xf0): 0  -- wavetable_index
			0,    -- flags
			0,    -- unused extra
				
			-- MVALs:  kind/flags,  val0, val1, envelope_index
			
			0x2,0x20,0,0,  -- volume: mult. 0x40 is max (-0x40 to invert, 0x7f to overamp)
			0x1,0,0,0,     -- pan:   add. center
			0x21,0,0,0,    -- tune: +0 -- 0,48,0,0 absolute for middle c (c4) 261.6 Hz
			               -- tune is quantized to semitones with 0x20
			0x1,0,0,0,     -- bend: none
			0x0,0x40,0,0,  -- wave: triangle
			0x0,0,0,0      -- phase 
	)
	
	
	-- wavetables
	poke(addr + 0x1e0,
		0x00, -- address (low)  in 256 byte increments
		0xf8, -- address (high) in 64k increments
		0x0a, -- samples (1 << n) 1024
		0xff,  -- wt_height 256(0); wave mval points at one of the entries
		
		-- white noise
		0x80,
		0xf7,
		0x0d, -- samples (1 << n) 8192
		0x01
	)

	-- envelope 0 inst 1
	
	poke(addr + 0x100,
		0,0,0,0, 0,0,0,0,
		0,40,255,0 -- adsr
	)
end


function init_data()

	-- use 256k from 0x30000
	-- gives 399 SFX and managemable size for undo state comparisons
	-- if change this need, to adjust undo stack size and loader/saver
	
	memset(0x30000, 0, 0x40000)
	

	-- index (0x30000)
	
	-- first 3 values are almost metadata only -- not currently
	-- acted on anywhere. perhaps useful in future for deciding
	-- scope of copy/paste, and gui cues, but can be calculated
	-- from content.
	
	poke2(0x30000,
		64,  -- num_instruments
		512, -- num_tracks (64 patterns * 8 channels for default indexing)
		64,  -- num_patterns
		-- flags: 0x1 use default track indexing (base+0x20000, increments of 328 bytes)
		0x1
	)
	poke4(0x30010,
		0x10000, -- insts_addr      (I32)    relative address of instruments
		0x20000, -- tracks_addr     (I32)    relative address of track index
		0,       -- patterns_addr   (I32)    relative address of pattern data
		0        -- unused          (I32)    should be 0
	)
	poke2(0x30020,
		0,  -- tick len (0 for default -- custom vals not supported yet)
		64, -- default track length
		16 -- default track spd
	)
	
	-- default track speed (+3 unused)
	poke(0x30026, 16, 0, 0, 0) 
	
	-- pattern data: first 16 patterns
	-- want to keep default sfx file quite tiny
	-- .. should be ok to save a whole .sfx for just one inst / experiment
	-- later: interface to generate more default patterns
	
	for pp = 0,3
	do
		local addr = 0x30100 + pp * 20
		for i = 0, 3 do
			poke(addr+i, pp*4 + i)
		end
		poke(addr+8, 0x0)  -- flow flags
		poke(addr+9, 0x0f) -- channel mask -- 4 channels
		poke(addr+10, 0,0) -- length (I16)
		
	end
	
	
	----------------------------------------------------------------------------
	-- single instrument at 0x40000 (instrument 0)
	
	clear_instrument(0)
	
	-- copy default instrument to 1..31
	for i=1,31 do
		memcpy(0x40000 + 0x200*i, 0x40000, 0x200)
	end
	
	
	--------------------------------------------------
	-- Track Data  0x50000
	--------------------------------------------------
	
	-- Default track size is 5 * 64 rows + 8 = 328 bytes
	
	-- header (8)
	
	init_track(0x50000)
	
	-- copy to other tracks: 128k worth
	-- ** only first 399 are saved / undoable (0x20000\328) **
	-- 384 used in tracker
	--[[
	for i=1,398 do
		memcpy(0x50000 + i*328, 0x50000, 328)
	end
	]]

end






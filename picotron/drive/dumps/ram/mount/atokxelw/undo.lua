--[[pod_format="raw",created="2024-03-30 19:03:19",modified="2024-09-12 16:58:56",revision=2205]]
--[[

	single undo stack for whole .sfx file

]]

function init_undo()

	undo_stack = create_undo_stack(
		function()
			local mem = userdata("u8",0x40000):peek(0x30000)
			local ranges = {ci0,ci1,ci2, ct0,ct1,ct2, cp0,cp1,cp2}
			return {mem,tdat,mode,ci,ct,cp,ranges}
		end,
		function(state)
			state[1]:poke(0x30000)
			tdat,mode,ci,ct,cp=state[2],state[3],state[4],state[5],state[6]
			ci0,ci1,ci2, ct0,ct1,ct2, cp0,cp1,cp2 = unpack(state[7])
		end,		
		-- use raw binary encoding suitable for fixed size memory block (same as gfx)
		--> faster encoding,  smaller patches
		0x11 -- (0x1 binary  0x10 pxu raw)
	)
	
end

function checkpoint()
	undo_stack:checkpoint()
end

function undo()
	undo_stack:undo()
	sfx_thumb={} -- invalidate thumbs
	refresh_gui = true
end

function redo()
	undo_stack:redo()
	sfx_thumb={} -- invalidate thumbs
	refresh_gui = true
end
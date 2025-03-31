--[[pod_format="raw",created="2023-10-14 03:29:27",modified="2024-07-18 22:58:53",revision=2062]]
local layers_snapshot = nil
local layer_op = false -- next thing to undo is a layer operation

function add_undo_stack(ii)
	ii.undo_stack = create_undo_stack(undo_save_state, undo_load_state, 0x11, ii)
end
function undo_save_state(ii)
	return {
		ii.bmp:copy(),
		ii.sel and ii.sel:copy(),
		ii.layer0 and ii.layer0:copy(),
		ii.layer and ii.layer:copy(),
		ii.layer_x or 0,
		ii.layer_y or 0,
		ii.pan_x,
		ii.pan_y,
		ii.zoom
	}
end
function undo_load_state(s, ii)
	ii.bmp = s[1] or userdata("u8",16,16)
	ii.sel =   s[2] or nil
	ii.layer0 = s[3] or nil
	ii.layer = s[4] or nil
	ii.layer_x = s[5]
	ii.layer_y = s[6]
	ii.pan_x = s[7] or 0
	ii.pan_y = s[8] or 0
	ii.zoom = s[9] or 1
end

function backup_state()
	local ii = item[current_item]
	local tt0 = stat(1)
	
	ii.undo_stack:checkpoint()

--	printh(string.format("%3.3f",stat(1)-tt0).." // patch size:"..
--		#(ii.undo_stack.undo_stack[#ii.undo_stack.undo_stack]))

	-- invalidate any layer op. can release layers snapshot too
	-- (they could be the same thing)
	layer_op = false
	layers_snapshot = nil
	
end
function undo()
	if (layer_op and layers_snapshot) then
		-- undo delete or add layer
		layer_op = false -- can only undo layer operation once
		item = layers_snapshot
		refresh_gui = true
		set_current_item()
	else
		-- regular undo on a single layer
		local ii = item[current_item]
		ii.undo_stack:undo()
	end
end
function redo()
	local ii = item[current_item]
	ii.undo_stack:redo()
end



function backup_layers()
	layers_snapshot = {}
	for i=1,#item do
		add(layers_snapshot, item[i])
	end
	layer_op = true
end

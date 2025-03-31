--[[pod_format="raw",created="2023-10-14 03:29:27",modified="2024-08-18 16:06:41",revision=2083,stored="2023-24-28 00:24:00"]]
local group_op_items = nil

local function undo_save_state(ii)
	-- don't store nils, to preserve order
	return {
		
		ii.flags,
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

local function undo_load_state(s, ii)

	ii.flags = s[1]
	ii.bmp =   s[2]
	ii.sel =   s[3] or nil
	ii.layer0 = s[4] or nil
	ii.layer = s[5] or nil
	ii.layer_x = s[6]
	ii.layer_y = s[7]
	ii.pan_x = s[8]
	ii.pan_y = s[9]
	ii.zoom = s[10]
	
end

function backup_state()

	local ii = item[current_item]
	local tt0 = stat(1)
	ii.undo_stack:checkpoint()
	
	-- undo no longer applies to a group of items
	group_op_items = nil

--	printh(string.format("%3.3f",stat(1)-tt0).." // patch size:"..
--		#(ii.undo_stack.undo_stack[#ii.undo_stack.undo_stack]))
end


function undo()
	if (group_op_items) then
		-- undo on each item in group
		notify("undoing "..#group_op_items.." items")
		for i=1,#group_op_items do
			local ii = item[group_op_items[i]]
			if (ii) ii.undo_stack:undo()
		end
		-- can only do a single undo and no redos on group operations
		group_op_items = nil
	else
		-- single undo on current item
		local ii = item[current_item]
		ii.undo_stack:undo()
	end
end

function redo()
	local ii = item[current_item]
	ii.undo_stack:redo()
end

function add_undo_stack(ii)
	ii.undo_stack = create_undo_stack(undo_save_state, undo_load_state, 0x11, ii)
end

function multi_op(indexes, do_checkpoint)
	group_op_items = unpod(pod(indexes))
	if (do_checkpoint) then
		for i in all(group_op_items) do
			item[i].undo_stack:checkpoint()
		end
	end
	if (#indexes == 1) group_op_items = nil -- not a group op
	return indexes
end


--[[pod_format="raw",created="2023-10-11 09:19:20",modified="2024-10-15 23:31:36",revision=973,stored="2023-21-29 09:21:19"]]

function check_for_overwrites(msg)

	local fn
	local num = 0

	for i=1,#msg.items do
		local item = msg.items[i]
		if (item.pod_type == "file_reference") then
			local dest = pwd().."/"..item.fullpath:basename()
			--printh("checking: "..dest)
			
			if fstat(dest) then
				if (not fn) fn = item.fullpath:basename()
				num += 1
			end
		end
	end
	
	if (fn and num > 1) return fn.." (+"..(num-1)..")"
	if (fn) return fn
	
	return nil

end


-- happens after dropping files
function bring_selected_items_to_front()
	if (mode ~= "desktop") return

--[[
	for i=1,#fi do
		if (fi[i].finfo.selected) then
			local item = fi[i]
			item.z = top_z
			item:bring_to_front()
			top_z += 1
		end
	end
]]

	local processed = {}
	for i=1,#fi do
		local item = fi[i]
		if (item.finfo.selected) then
			if item.group_id then
				local g=group[item.group_id]
				if (not processed[g]) then
					processed[g] = true
					for i=1,#g do
						g[i].z = top_z
						g[i]:bring_to_front()
					end
				end
			else
				-- doesn't happen; always group of 1
				item.z = top_z
				item:bring_to_front()
			end
			top_z += 1
		end
	end

end



on_event("drop_items",function(msg)

	--printh("@@ dropped items from proc_id:"..msg.from_proc_id.." // mode:"..mode)
	
	-- drop into self
	
	if (msg.from_proc_id == pid()) then
		if (mode == "desktop") then
			shift_selected_desktop_items(msg.dx, msg.dy)
		end
		bring_selected_items_to_front() -- to do
		return
	end
	
	-- drop from somewhere else
	
	-- .. make sure not going to overwrite something first
	if (not msg.shift) then
		local res = check_for_overwrites(msg)
		if res then
			notify("** can not overwrite "..res.." ** (hold shift to force)")
			return
		end
	end
	
	--printh("@@ drop from a different process:"..pod(msg))
	
	local found_copy_op = false
	local err = nil
	local num_ok = 0

	for i=1,#msg.items do
		local item = msg.items[i]
		if (item.pod_type == "file_reference") then

			-- MOVE
			--printh(pod(item))
			-- printh("@@ moving "..tostring(item.fullpath).." to "..pwd())
			
			-- to do: define which attributes are requied for a well formed file_reference item
			-- shouldn't ever need .filename
			-- avoid introducing optional attributes / hints -- easy for another author to expect to exist on receiving end

			-- allowed to overwrite existing files in this case

			local res = nil

			if (item.op == "copy") then
				res = cp(item.fullpath, pwd().."/"..item.fullpath:basename())
				found_copy_op = true
			else
				-- everything else: move ("cut")
				res = mv(item.fullpath, pwd().."/"..item.fullpath:basename())
			end

			if res then
				err = tostring(res)
			elseif (mode == "desktop") then	
				num_ok += 1
				set_desktop_item_position(
					item.fullpath:basename(), 
					msg.mx - 58 + (item.xo and item.xo or 0), 
					msg.my - 6 + (item.yo and item.yo or 0)
				)
			end

		end
	end

	local total_str = #msg.items
	if (num_ok < #msg.items) total_str = num_ok.." / "..(#msg.items)
	local err_str = err and ("// "..err) or ""


	if (found_copy_op) then
		notify("copied "..#msg.items.." items "..err_str)
	else
		notify("moved "..#msg.items.." items "..err_str)
	end

	-- to do: bring selected (dropped) items to front next time 
	--[[
		update_file_info(true)
		bring_selected_items_to_front()
	]]

end)


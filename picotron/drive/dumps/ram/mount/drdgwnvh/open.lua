--[[pod_format="raw",created="2023-10-04 12:46:16",modified="2024-10-15 00:19:32",revision=3302,stored="2023-21-29 09:21:19"]]

	
	function click_on_file(filename, action, argv)
		
		--printh("opening: "..tostr(filename))
		
		--if (not intention and string.sub(filename,-4) == ".loc") then
		if (string.sub(filename,-4) == ".loc") -- 0.1.0c: always open as if folder
		then
			local dat = fetch(filename)
			-- switcheroony
			-- to do: ** loop danger! **
			if (dat and dat.location) then
				filename = fullpath(dat.location) -- dat.location can be relative
				click_on_file(filename, dat.action, dat.argv)
			else
				notify("not a valid location file")
			end
		elseif not intention and (
				string.sub(filename,-4) == ".p64" or
				string.sub(filename,-8) == ".p64.rom" or
				string.sub(filename,-8) == ".p64.png" or
				action == "run"
			)
			-- or string.sub(filename,-4) == ".lua" -- nah, usually want to edit
		then
			-- cartridge --> run it!
			
			create_process(filename,
				unpod(argv)
			)
		
		else
			-- to do: could grab from file item
			
			if (fstat(filename) == "folder") then
				-- directory
				if (mode == "desktop" or key("shift")) then
					-- open in a separate window
					-- to do: run self
					create_process("/system/apps/filenav.p64",
					{ 
						argv = {
							fullpath(filename), 
							fullpath(filename)
						}
					})
					
				else
					cd(filename)
					refresh_gui = true
				end
				
			else
			
				-- only selected intentions get processed by
				-- double clicking on a file. for example,
				-- under new_file (new tab) double clicking
				-- should still mean editing that file as usual
				-- update: couldn't find an intention that /is/
				-- appropriate here! -> always edit
				
				if (intention == "save_file_as" or intention == "select_file") then
					-- filename in text field should already be set
					process_intention()
				else
					-- open by file extension
					create_process(env().open_with and env().open_with or "/system/util/open.lua",
						{
							argv = {fullpath(filename)},
							--pwd = pwd()
						}
					)
				
				end
			
			end
		end
		
	end


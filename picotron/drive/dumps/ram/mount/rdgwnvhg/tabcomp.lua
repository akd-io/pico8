--[[pod_format="raw",created="2023-53-26 19:53:00",modified="2024-04-03 05:32:39",revision=59,stored="2023-59-07 07:59:44"]]
--[[
	fa: create gui with relative sizes
]]
-- ** incredibly inefficient! to do: need to replace with string matching
function find_common_prefix(s0, s1)
	if (type(s0) ~= "string") then return nil end
	if (type(s1) ~= "string") then return nil end
	if (s0 == s1) then return s0 end
	local len = 0
	while(sub(s0,1,len+1) == sub(s1,1,len+1)) do
		len = len + 1
		--printh(len)
	end
	return sub(s0,1,len)
end
function tab_complete_filename(cmd)
	if (cmd == "") then return cmd end
	-- get string
	local args = split(cmd, " \"", false)  -- also split on " to allow tab-completing filenames inside strings
	local prefix = args[#args] or ""
	-- construct path prefix  -- everything (canonical path) except the filename
	local prefix = fullpath(prefix)
	local pathseg = split(prefix,"/",false)
	if (not pathseg) then return cmd end
	local path_part = ""
	for i=1,#pathseg-1 do
		path_part = path_part .. "/" .. pathseg[i]
	end
	if (path_part == "") then path_part = "/" end -- canonical filename special case
	prefix = (pathseg and pathseg[#pathseg]) or "/"
	-- printh("@@@ path part: "..path_part.." pwd:"..pwd())
	local files = ls(path_part)
	if (not files) return cmd
	-- find matches
	local segment = nil
	local matches = 0
	local single_filename = nil

	for i=1,#files do
		--printh(prefix.." :: "..files[i])
		if (sub(files[i], 1, #prefix) == prefix) then
			matches = matches + 1
			local candidate = sub(files[i], #prefix + 1) -- remainder

			-- set segment to starting sequence common to candidate and segment
			segment = segment and find_common_prefix(candidate, segment) or candidate
			single_filename = path_part.."/"..files[i] -- used when single match is found
		end
	end
	
	if (segment) then
		cmd = cmd .. segment
		--cursor_pos = cursor_pos + #segment
	end

	if matches == 1 and single_filename and fstat(single_filename) == "folder" then
		cmd ..= "/"
	end

	
	return cmd
end




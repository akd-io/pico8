--[[pod_format="raw",created="2024-03-13 08:36:45",modified="2024-05-16 21:54:33",revision=1072]]

function draw_mudo_state(x,y)
	rectfill(x,y,x+99,y+60,0)
	
	for i=0,7 do
		local sx = x + 2
		local sy = y + i * 6	
		
		-- chan->playing_track_index
		print("\14"..stat(400+i,12), sx, sy, 7)
		
		-- chan->inst		
		print("\14"..stat(400+i,1 ), sx+30, sy, 7)
		
		-- chan->track_row
		print("\14"..stat(400+i,9 ), sx+60, sy, 13)
		
	end
	print(string.format("cpu:%3.3f", stat(1)),x,y+52,13)
	print(tostr(something_is_playing),x+50,y+52,14)
end

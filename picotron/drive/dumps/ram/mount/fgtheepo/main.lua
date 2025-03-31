--[[pod_format="raw",created="2023-16-06 01:16:20",modified="2023-34-06 22:34:50",revision=235]]

p = {
23130,20767,32125,-18403,-1633,20927,-19009,-20193,-24352,
25793,1,-20033,2561,-20129,6943,-2625,31455,3855,21845
}

function draw_back()
	back = userdata("u8", 480, 270)
	set_draw_target(back)
	cls(theme"desktop0")
	for i=0, 12 do
		local x = -240 + i * 80 + rnd(50)
		local dx = 1+rnd(1.5)
		
		color(theme"desktop0" + theme"desktop1"*256)
		
		fillp(rnd(p))
		for y=0,269 do
			line(x,y,480,y)
			x += dx
		end
		
		local x = -240 + i * 80 + rnd(50)
		local dx = 1+rnd(1.5)
		
		fillp(rnd(p))
		for y=269,0,-1 do
			line(x,y,480,y)
			x += dx
		end
		
	end
	
end
function _init()
	draw_back()

end

function _draw()

	hash_pod = pod{
		theme"desktop0",
		theme"desktop1",
		theme"desktop_pattern",		
		theme"desktop_pattern_spacing"
	}
	
	-- regenerate when settings change
	if (hash_pod ~= last_hash_pod) then
		draw_back()
	end
	
	last_hash_pod = hash_pod
	

	blit(back)
end




























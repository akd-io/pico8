--[[pod_format="raw",created="2023-05-11 02:05:01",modified="2024-08-18 16:06:41",revision=1714,stored="2023-11-28 03:11:19"]]
local pcols = {[0]=
	0,19,3,27,  11,26,10,23,
	1,17,12,28, 18,16,13,29,
	2,30,14,31, 24,8,25,9,
	20,4,21,15, 5,22,6,7,
}

pcols_continuous = {[0] =
	0,20,4,31,15,8,24,2,
	21,5,22,6,7,23,14,30,
	1,16,17,12,28,29,13,18,
	19,3,27,11,26,10,9,25,
}

pcols_identity = {[0] =
	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
}

function switch_col(dindex)
	if (pal_swatch==1) dindex*=2
	local index = -1
	for i=0,63 do
		if (pcols[i] == col) index = i
	end
	if (index>=0) col = pcols[(index+dindex)%64]
end

function create_pal_preview(el)
	el = gui:new(el)
	function el:draw()
		rectfill(0,0,16,8,0)
		rectfill(1,1,15,7,col)
		print(col,20,2,6)
	end
	return el
end

function create_pal_tabs(el)

	el = gui:new(el)

	function el:draw()
		--rect(0,0,self.width-1, self.height-1, 13)
	end
	
	local swatch_name={[0]="^","^"}
	
	for i=0,1 do
		local y_offs = i == pal_swatch and 0 or 1
		local tab = el:attach({
			x=i*12,y=y_offs,width=11,height=el.height - y_offs,
			index=i,
			draw = function(self)
				local sel = pal_swatch == self.index
				rectfill(0,0,self.width-1, self.height-1, sel and 6 or 13)
				pset(0,0,5)
				line(0,1,1,0,5)
				line(0,2,2,0,5)
				
				pset(self.width-1,0,5)
				
				line(0,self.height-1,self.width-1,self.height-1,13)
				print(swatch_name[self.index],5,1,5)
				
			end,
			
			click = function(self)
				pal_swatch = self.index
				refresh_gui = true
			end
			
		})
	end
	

	
	return el
end



--for i=0,63 do pcols[i]=i end

--[[
pcols[22],pcols[21]=pcols[21],pcols[22]
pcols[16],pcols[17],pcols[18] = pcols[18], pcols[16],pcols[17]
]]

pal_swatch = 1

function create_palette(el)

	-- identity
	for i=0,63 do pcols[i] = i end
	
	if pal_swatch == 1 then
		for i=0,63 do 
			pcols[i] = pcols_continuous[i\2] or 0 
		end
	end
	
	-- to do: adaptive
	local epr = 16
	local ww = el.width / epr
	local hh = el.height / 4
	
	function el:draw()
		clip()
		
		rectfill(0,0,self.width, self.height, 0)
		rectfill(-1,-1,self.width, self.height, 0)
		
		for y=0,64\epr-1 do
			for x=epr-1,0,-1 do
				rectfill(x * ww, y * hh, x * ww + ww-1, y * hh + hh-1, 
				pcols[x + y*epr])
				if (pcols[x + y*epr] == col) then
					local xx = x * ww
					local yy = y * hh
					if (pal_swatch == 0 or x%2 == 0) then
						rect(xx+0,yy+0,xx+ww*(1+pal_swatch)-1,yy+hh-1,7)
						rect(xx+1,yy+1,xx+ww*(1+pal_swatch)-2,yy+hh-2,0)
					end
				end
			end
		end
		
		
	end
	
	function el:drag(msg)
		local xx = msg.mx \ ww
		local yy = msg.my \ hh
		col = pcols[xx + yy * epr] or 0
	end
	
	
	return el
end










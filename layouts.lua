local Bagrealis, addon, ns = Bagrealis, ...

local layouts = {}
Bagrealis.Layouts = layouts

function layouts:Grid(objects, columns, spacing)
	columns, spacing = columns or 6, spacing or 5

	local col, row = 0, 0
	for object in pairs(objects) do
		object:ClearAllPoints()
		object:SetScale(1)

		local xPos = col * (37 + spacing)
		local yPos = -1 * row * (37 + spacing)

		object:SetPoint("TOPLEFT", self, "TOPLEFT", 10+xPos, yPos-10)	 
		if(col >= columns-1) then
			col = 0	 
			row = row + 1	 
		else	 
			col = col + 1	 
		end
	end
end

function layouts:Stack(objects)
	for object in pairs(objects) do
		object:ClearAllPoints()
		object:SetScale(1)
		object:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
	end
end
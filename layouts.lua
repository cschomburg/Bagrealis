local Bagrealis, addon, ns = Bagrealis, ...

local layouts = {}
Bagrealis.Layouts = layouts

function layouts:Grid(objects, columns, spacing)
	columns, spacing = columns or 6, spacing or 5

	local col, row = 0, 0
	for object in pairs(objects) do
		object:SetScale(1)

		local xPos = col * (37 + spacing)
		local yPos = -1 * row * (37 + spacing)

		if(Bagrealis.Config.Animations) then
			Bagrealis.Anims.Move(object, self, 10+xPos, yPos-10)
		else
			object:SetPoint("TOPLEFT", self, "TOPLEFT", 10+xPos, yPos-10)
		end

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
		object:SetScale(1)

		if(Bagrealis.Config.Animations) then
			Bagrealis.Anims.Move(object, self, 10, -10)
		else
			object:SetPoint("TOPLEFT", self, "TOPLEFT", 10, -10)
		end
	end
end

function layouts:Circle(objects, numObjects)
	local radius = (numObjects*50)/math.pi/2

	local i=1
	for object in pairs(objects) do
		object:SetScale(1)

		local a = 360/numObjects*i
		local x = radius*cos(a)
		local y = -radius*sin(a)

		if(Bagrealis.Config.Animations) then
			Bagrealis.Anims.Move(object, self, radius+x, y-radius)
		else
			object:SetPoint("TOPLEFT", self, "TOPLEFT", radius+x, y-radius)
		end
		i = i+1
	end
end
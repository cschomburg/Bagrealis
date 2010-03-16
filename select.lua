local Bagrealis, addon, ns = Bagrealis, ...
local DragDrop = Bagrealis.DragDrop

local select = CreateFrame("Frame", nil, Bagrealis)
Bagrealis.Selector = select

select:SetResizable(true)
select:SetFrameLevel(100)
select:SetBackdrop(Bagrealis.Config.Selector.Backdrop)
select:SetBackdropColor(unpack(Bagrealis.Config.Selector.BackdropColor))
select:SetBackdropBorderColor(unpack(Bagrealis.Config.Selector.BorderColor))
select:Hide()

local selectModifier = CreateFrame("Button", nil, Bagrealis)
select.Modifier = selectModifier

selectModifier:SetMovable(true)
selectModifier:EnableMouseWheel(true)
selectModifier:SetBackdrop(Bagrealis.Config.Selector.Backdrop)
selectModifier:SetBackdropColor(unpack(Bagrealis.Config.Selector.BackdropColor))
selectModifier:SetBackdropBorderColor(unpack(Bagrealis.Config.Selector.BorderColor))
selectModifier:Hide()

selectModifier:SetScript("OnMouseDown", function(self, button)
	if(button ~= "RightButton") then
		self:StartMoving()
	end
end)

selectModifier:SetScript("OnMouseUp", function(self, button)
	if(button == "RightButton") then
		Bagrealis.DropDown:Open(self)
	else
		self:StopMovingOrSizing()
	end
end)

selectModifier:SetScript("OnMouseWheel", function(self, delta)
	local speed = delta * (IsShiftKeyDown() and 0.3 or 0.1)
	local a,b,c,d,e = self:GetPoint()
	local old = self:GetScale()
	local new = ns.minmax(old + old * speed, 0.1, 10)
	d, e = d/new, e/new
	self:SetScale(new)
	self:ClearAllPoints()
	self:SetPoint(a,b,c, d*old, e*old)
end)

local selections, selCount = {}
local sX, sY, fX, fY

function select.Start()
	local x, y = GetCursorPosition()
	local eff = select:GetEffectiveScale()

	sX, sY = x/eff, y/eff
	fX, fY = nil
	select:Show()
end

function select.Stop()
	if(not select:IsShown() or select:GetWidth() == 0) then return select.Clear() end

	select:Hide()
	selectModifier:ClearAllPoints()
	selectModifier:SetAllPoints(select)
	selectModifier:SetFrameLevel(100)
	selectModifier:Show()

	selections, selCount = {}, 0

	for object in pairs(DragDrop.objects) do
		if(object._name == "ItemButton" and object:IsVisible() and DragDrop.IntersectsWith(selectModifier, object)) then
			selections[object] = true
			selCount = selCount + 1
			DragDrop.OnMoveStart(object)
			DragDrop.ChangeZone(object, selectModifier)
			object:SetFrameLevel(99)
		end
	end

	if(selCount == 0) then
		select.Clear()
	end
end

function select.Clear()
	for object in pairs(selections) do
		DragDrop.OnMoveStop(object)
		object:SaveState()
	end
	select:Hide()
	selectModifier:Hide()
	selectModifier:SetScale(1)
end

select:SetScript("OnMouseUp", select.Stop)
select:SetScript("OnUpdate", function(self)
	local x,y = GetCursorPosition()
	local eff = self:GetEffectiveScale()

	if(fX ~= x/eff or fY ~= y/eff) then
		fX, fY = x/eff, y/eff
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", min(sX, fX), max(sY, fY))
		self:SetWidth(abs(sX-fX))
		self:SetHeight(abs(sY-fY))
	end
end)

selectModifier.DropDownEntries = {
	{
		text = "Layout in Grid",
		func = function() Bagrealis.Layouts.Grid(selectModifier, selections, selCount^0.5) end,
	},{
		text = "Layout in Stack",
		func = function() Bagrealis.Layouts.Stack(selectModifier, selections) end,
	},
	{
		text = "Clear selection",
		func = select.Clear,
	}
}
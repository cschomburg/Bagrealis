--[[
    Copyright (C) 2009  Constantin Schomburg

    This file is part of Bagrealis.

    Bagrealis is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    Bagrealis is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Bagrealis.  If not, see <http://www.gnu.org/licenses/>.
]]

local Bagrealis = Bagrealis

local select = CreateFrame("Frame", nil, Bagrealis.MainFrame)
Bagrealis.Selector = select
select.class = "Selector"
select:Hide()

local selectModifier = CreateFrame("Button", nil, Bagrealis.MainFrame)
Bagrealis:ImplementDefaultButton(selectModifier)
select.Modifier = selectModifier
selectModifier.class = "Selector"
selectModifier:Hide()

Bagrealis:RegisterInitCallback("Selector", function()
	local config = selectModifier:GetConfig()

	select:SetResizable(true)
	select:SetFrameLevel(100)
	select:SetBackdrop(config.Backdrop)
	select:SetBackdropColor(unpack(config.BackdropColor))
	select:SetBackdropBorderColor(unpack(config.BorderColor))

	selectModifier:SetMovable(true)
	selectModifier:EnableMouseWheel(true)
	selectModifier:SetBackdrop(config.Backdrop)
	selectModifier:SetBackdropColor(unpack(config.BackdropColor))
	selectModifier:SetBackdropBorderColor(unpack(config.BorderColor))
end)

selectModifier:SetScript("OnMouseDown", function(self, button)
	local action = self:GetUserAction(button)
	if(action == "move") then
		self:StartMoving()
	end
end)

selectModifier:SetScript("OnMouseUp", function(self, button)
	local action = self:GetUserAction(button)
	if(action == "dropdown") then
		self:DropDown()
	elseif(action == "move") then
		self:StopMovingOrSizing()
	end
end)

selectModifier:SetScript("OnMouseWheel", function(self, delta)
	local speed = delta * (IsShiftKeyDown() and 0.3 or 0.1)
	local a,b,c,d,e = self:GetPoint()
	local old = self:GetScale()
	local new = Bagrealis.minmax(old + old * speed, 0.1, 10)
	d, e = d/new, e/new
	self:SetScale(new)
	self:ClearAllPoints()
	self:SetPoint(a,b,c, d*old, e*old)
end)

local selections, selCount = {}
local sX, sY, fX, fY

function select.Start()
	select.Clear()

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

	for object in pairs(Bagrealis:GetEnvironment().objects) do
		if(object.class == "ItemButton" and object:IsVisible() and Bagrealis.IntersectsWith(selectModifier, object)) then
			selections[object] = true
			selCount = selCount + 1
			Bagrealis.Object_OnMoveStart(object)
			Bagrealis.ChangeParent(object, selectModifier)
			object:SetFrameLevel(99)
		end
	end

	if(selCount == 0) then
		select.Clear()
	end
end

function select.Clear()
	for object in pairs(selections) do
		Bagrealis.Object_OnMoveStop(object)
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
	},{
		text = "Layout in Circle",
		func = function() Bagrealis.Layouts.Circle(selectModifier, selections, selCount) end,
	},{
	},{
		text = "Clear selection",
		func = select.Clear,
	}
}
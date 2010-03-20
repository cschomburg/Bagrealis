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

local DropDown = CreateFrame("Frame", "BagrealisDropDown", UIParent, "UIDropDownMenuTemplate")
Bagrealis.DropDown = DropDown

local info, init = {}, true

local function addEntry(name, func)
	info.text, info.func = name, func
	UIDropDownMenu_AddButton(info)
end

local function update()
	for i, entry in ipairs(DropDown.Selected.DropDownEntries) do
		UIDropDownMenu_AddButton(entry)
	end

	addEntry()

	if(Bagrealis:IsConfigModeOn()) then
		addEntry("Disable Config Mode", Bagrealis.DisableConfigMode)
	else
		addEntry("Enable Config Mode", Bagrealis.EnableConfigMode)
	end
end

function DropDown:Open(frame)
	self.Selected = frame
	if(init) then
		DropDown:SetID(1)
		UIDropDownMenu_Initialize(DropDown, update, "MENU")
		UIDropDownMenu_SetWidth(DropDown, 90)
	end
	ToggleDropDownMenu(1, nil, self, frame, 0, 0)
end
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

local Bagrealis = cargBags:GetImplementation("Bagrealis")

local DefaultButton = {}

function DefaultButton:GetDB(save)
	local class, ident, db = self.class, self.ident, Bagrealis.db
	db[class] = db[class] or {}
	local dbS = db[class]
	if(save) then
		dbS[ident] = dbS[ident] or {}
	end
	return dbS[ident]
end

function DefaultButton:ClearDB()
	local class, ident, db = self.class, self.ident, Bagrealis.db
	if(db[class] and db[class][ident]) then
		db[class][ident] = nil
	end
end

function DefaultButton:GetConfig()
	return Bagrealis.db.config[self.class]
end

function DefaultButton:GetUserAction(button)
	local actions = Bagrealis.db.config[self.class].Actions
	if(not actions) then return end

	local mod = (IsShiftKeyDown() and "_Shift") or (IsControlKeyDown() and "_Ctrl") or (IsAltKeyDown() and "_Alt")
	return mod and (actions[button..mod] or actions["Any"..mod]) or actions[button] or actions["Any"]
end

function DefaultButton:DropDown()
	Bagrealis.DropDown:Open(self)
end

function Bagrealis:ImplementDefaultButton(target)
	for k,v in pairs(DefaultButton) do
		target[k] = v
	end
end





local MainFrame = CreateFrame("Button", "BagrealisMain", Bagrealis)
Bagrealis:ImplementDefaultButton(MainFrame)
Bagrealis.MainFrame = MainFrame
MainFrame.class = "MainFrame"
Bagrealis:RegisterZone(MainFrame)

MainFrame:SetAllPoints()
MainFrame:EnableMouse(nil)

MainFrame:SetScript("OnMouseDown", function(self, button)
	local action = self:GetUserAction(button)

	if(action == "selector") then
		Bagrealis.Selector:Stop()
		Bagrealis.Selector:Start()
	end
end)

MainFrame:SetScript("OnMouseUp", function(self, button)
	local action = self:GetUserAction(button)

	if(action == "selector") then
		Bagrealis.Selector:Stop()
	elseif(action == "create_container") then
		Bagrealis.CreateContainer()
	end
end)
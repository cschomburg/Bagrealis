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

local Bagrealis = cargBags:NewImplementation("Bagrealis")
LibStub("LibDragDrop-1.0"):Embed(Bagrealis)
Bagrealis:RegisterBlizzard()

Bagrealis.DummyFunction = function() end

local defaults = {__index={}}

local init = true
local initCallbacks = {}
function Bagrealis:OnInit()
	if(not BagrealisDB) then
		self.Tutorial()
	end

	BagrealisDB = BagrealisDB or {}
	self.db = setmetatable(BagrealisDB, {__index = function(self, k) self[k] = {}; return self[k] end})
	setmetatable(self.db.config, {__index = Bagrealis.Config})

	if(self.db.Container) then
		for ident in pairs(self.db.Container) do
			self.contByName[ident] = self:GetContainerPrototype():Get(ident)
		end
	end
	for ident, container in pairs(self.contByName) do
		container:RestoreState()
	end

	for k, func in pairs(initCallbacks) do
		func(k)
	end
end

function Bagrealis:RegisterInitCallback(k, func)
	initCallbacks[k] = func
end

function Bagrealis:UpdateSlot(bagID, slotID)
	local item = self:GetItemInfo(bagID, slotID)
	local button = self:GetButton(bagID, slotID)

	if(item.texture) then
		if(not button) then
			button = self:GetItemButtonPrototype():New(bagID, slotID)
			self:SetButton(bagID, slotID, button)
			button:OnAdd()
		end
		button:Update(item)
	elseif(button) then
		self:SetButton(bagID, slotID, nil)
		button:Remove()
		button:Free()
	end
end

function Bagrealis.CreateContainer()
	local x, y = GetCursorPosition()
	local eff = Bagrealis.MainFrame:GetEffectiveScale()

	local container = Bagrealis:GetContainerPrototype():Get(time())
	container:RestoreState()
	container:ClearAllPoints()
	container:SetPoint("CENTER", Bagrealis.MainFrame, "BOTTOMLEFT", x/eff, y/eff)

	if(Bagrealis.db.config.Animations) then
		Bagrealis.Anims.Show(container)
	end

	return container
end

function Bagrealis.minmax(value, min, max)
	return (value > max and max) or (value < min and min) or value
end


local configMode

function Bagrealis.IsConfigModeOn()
	return configMode
end

function Bagrealis.EnableConfigMode()
	configMode = true
	Bagrealis.MainFrame:EnableMouse(true)
	print("Bagrealis: Config mode enabled!")
end

function Bagrealis.DisableConfigMode()
	configMode = nil
	Bagrealis.MainFrame:EnableMouse(nil)
	print("Bagrealis: Config mode disabled!")
end

SlashCmdList.BAGREALIS = function(msg)
	if(msg == "config") then
		if(configMode) then
			Bagrealis.DisableConfigMode()
		else
			Bagrealis.EnableConfigMode()
		end
	elseif(msg == "new") then
		Bagrealis.CreateContainer()
	elseif(msg == "tutorial") then
		Bagrealis.Tutorial()
	else
		Bagrealis.Toggle()
	end
end
SLASH_BAGREALIS1 = "/bagrealis"
SLASH_BAGREALIS2 = "/bag"

getfenv(0).Bagrealis = Bagrealis
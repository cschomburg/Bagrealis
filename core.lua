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

local Bagrealis = {}
LibStub("LibDragDrop-1.0"):Embed(Bagrealis)

Bagrealis.DummyFunction = function() end

local containers = {}
Bagrealis.Containers = containers

local defaults = {__index={}}
local bags = setmetatable({}, {__index = function(self, id) self[id] = {}; return self[id] end})

local init = true
local initCallbacks = {}
function Bagrealis:Init()
	init = nil

	self.MainFrame:RegisterEvent"BAG_UPDATE"
	self.MainFrame:RegisterEvent"ITEM_LOCK_CHANGED"
	self.MainFrame:RegisterEvent"BAG_UPDATE_COOLDOWN"

	if(not BagrealisDB) then
		self.Tutorial()
	end

	BagrealisDB = BagrealisDB or {}
	self.db = setmetatable(BagrealisDB, {__index = function(self, k) self[k] = {}; return self[k] end})
	setmetatable(self.db.config, {__index = Bagrealis.Config})

	if(self.db.Container) then
		for ident in pairs(self.db.Container) do
			containers[ident] = self.Container.Get(ident)
		end
	end
	for ident, container in pairs(containers) do
		container:RestoreState()
	end

	for k, func in pairs(initCallbacks) do
		func(k)
	end

	Bagrealis:BAG_UPDATE()
end

function Bagrealis:RegisterInitCallback(k, func)
	initCallbacks[k] = func
end

function Bagrealis:UpdateBag(bagID)
	local bag = bags[bagID]

	local num = GetContainerNumSlots(bagID)
	local old = bag.num or 0
	bag.num = num

	for slotID = 1, num do
		Bagrealis:UpdateSlot(bagID, slotID)
	end
	for slotID = num+1, old do
		local button = bags[bagID][slotID]
		bags[bagID][slotID] = nil
		button:Remove()
	end
end

function Bagrealis:BAG_UPDATE(event, bagID, slotID)
	if(bagID == -4) then return end

	if(bagID and slotID) then
		Bagrealis:UpdateSlot(bagID, slotID)
	elseif(bagID) then
		Bagrealis:UpdateBag(bagID)
	else
		for bagID = -2, 11 do
			Bagrealis:UpdateBag(bagID)
		end
	end
end

Bagrealis.ITEM_LOCK_CHANGED = Bagrealis.BAG_UPDATE
Bagrealis.BAG_UPDATE_COOLDOWN = Bagrealis.BAG_UPDATE


function Bagrealis:UpdateSlot(bagID, slotID)
	local button = bags[bagID][slotID]

	local clink = GetContainerItemLink(bagID, slotID)
	if(not clink) then
		if(button) then
			local button = bags[bagID][slotID]
			bags[bagID][slotID] = nil
			button:Remove()
		end
		return
	end

	local texture, count, locked, quality, readable = GetContainerItemInfo(bagID, slotID)
	local cdStart, cdFinish, cdEnable = GetContainerItemCooldown(bagID, slotID)
	local name, link, rarity, level, minLevel, type, subType, stackCount, equipLoc, texture = GetItemInfo(clink)

	if(not button) then
		button = Bagrealis.ItemButton.Get(bagID, slotID)
		bags[bagID][slotID] = button
	end

	button.Icon:SetTexture(texture)

	if(rarity and rarity > 1) then
		button.Glow:SetVertexColor(GetItemQualityColor(rarity))
		button.Glow:Show()
	else
		button.Glow:Hide()
	end

	if(count and count > 1) then
		button.Count:SetText(count and count >= 1e3 and "*" or count)
		button.Count:Show()
	else
		button.Count:Hide()
	end

	button.Icon:SetDesaturated(locked)
	CooldownFrame_SetTimer(button.Cooldown, cdStart, cdFinish, cdEnable)
end





function Bagrealis.Open()
	if(init) then
		Bagrealis:Init()
	end
	Bagrealis.MainFrame:Show()
end

function Bagrealis.Close()
	Bagrealis.MainFrame:Hide()
end

function Bagrealis.Toggle(forceopen)
	if(Bagrealis.MainFrame:IsShown() and not forceopen) then
		Bagrealis.Close()
	else
		Bagrealis.Open()
	end
end

function Bagrealis.CreateContainer()
	local x, y = GetCursorPosition()
	local eff = Bagrealis.MainFrame:GetEffectiveScale()

	local container = Bagrealis.Container.Get(time())
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

ToggleBackpack = Bagrealis.Toggle
ToggleBag = function() Bagrealis.Toggle() end
OpenAllBags = ToggleBag
CloseAllBags = Bagrealis.Close
OpenBackpack = Bagrealis.Open
CloseBackpack = Bagrealis.Close

getfenv(0).Bagrealis = Bagrealis
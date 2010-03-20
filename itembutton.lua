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

local ItemButton = setmetatable({}, Bagrealis.DefaultButton)
Bagrealis.ItemButton = ItemButton
ItemButton.__index = ItemButton
ItemButton.class = "ItemButton"

function ItemButton:OnDragStart()
	self:StartMoving()
	GameTooltip:Hide()
end

function ItemButton:OnDragStop(button)
	self:StopMovingOrSizing()
	self:SaveState()
end

function ItemButton:OnMouseWheel(delta)
	local action = self:GetUserAction("Wheel")

	if(action == "alpha") then
		self:SetAlpha(Bagrealis.minmax(self:GetAlpha() + delta*0.1, 0, 1))
		self:SaveState()
	elseif(action == "scale") then
		local a,b,c,d,e = self:GetPoint()
		local old = self:GetScale()
		local new = Bagrealis.minmax(old + old * delta*0.1, 0.1, 10)
		d, e = d/new, e/new
		self:SetScale(new)
		self:ClearAllPoints()
		self:SetPoint(a,b,c, d*old, e*old)
		self:SaveState()
	end
end

function ItemButton:SaveState()
	local db = self:GetDB(true)
	local pA, pB, pC, pD, pE = self:GetPoint()
	pB = pB and pB.class == "Container" and pB.ident or nil
	local s = self:GetScale()
	local a = self:GetAlpha()
	db[1], db[2], db[3] = pB, pD, pE
	db[4], db[5] = s, a
end

function ItemButton:RestoreState()
	local db = self:GetDB()
	self:ClearAllPoints()

	if(db) then
		local frame = db[1] and Bagrealis.Containers[db[1]] or Bagrealis.MainFrame
		Bagrealis.InsertIntoZone(self, frame)
		self:SetParent(frame)
		self:SetPoint("CENTER", frame, "TOPLEFT", db[2], db[3])
		self:SetScale(db[4] or 1)
		self:SetAlpha(db[5] or 1)
	else
		self:SetParent(Bagrealis.MainFrame)
		self:SetPoint("CENTER", Bagrealis.MainFrame, "CENTER")
		self:SetScale(1)
		self:SetAlpha(1)
	end
end

function ItemButton:SetBagID()
	self:GetParent():SetID(self.bagID)
end

function ItemButton:OnEnter()
	self:SetBagID()
	if(self.bagID == -1) then
		BankFrameItemButton_OnEnter(self)
	else
		ContainerFrameItemButton_OnEnter(self)
	end
end

local slotsNum = 0
function ItemButton.Create(tpl)
	slotsNum = slotsNum+1

	local button = setmetatable(CreateFrame("Button", "BagrealisSlot"..slotsNum, nil, tpl), ItemButton)
	Bagrealis:RegisterObject(button)

	button:SetWidth(37)
	button:SetHeight(37)
	button:SetMovable(true)
	button:EnableMouseWheel(true)

	button.Icon = _G["BagrealisSlot"..slotsNum.."IconTexture"]
	button.Count = _G["BagrealisSlot"..slotsNum.."Count"]
	button.Cooldown = _G["BagrealisSlot"..slotsNum.."Cooldown"]

	local glow = button:CreateTexture(nil, "OVERLAY")
	glow:SetTexture"Interface\\Buttons\\UI-ActionButton-Border"
	glow:SetBlendMode"ADD"
	glow:SetAlpha(.8)
	glow:SetWidth(70)
	glow:SetHeight(70)
	glow:SetPoint("CENTER", button)
	button.Glow = glow

	button:SetScript("PreClick", ItemButton.SetBagID)
	button:SetScript("OnDragStart", ItemButton.OnDragStart)
	button:SetScript("OnDragStop", ItemButton.OnDragStop)
	button:SetScript("OnEnter", ItemButton.OnEnter)
	button:SetScript("OnReceiveDrag", Bagrealis.DummyFunction)
	button:SetScript("OnMouseWheel", ItemButton.OnMouseWheel)

	return button
end

local recycled = {
	ContainerFrameItemButtonTemplate = {},
	BankItemButtonGenericTemplate = {},
}

local function getTemplateName(bagID)
	return bagID == -1 and "BankItemButtonGenericTemplate" or "ContainerFrameItemButtonTemplate"
end

function ItemButton.Get(bagID, slotID)
	local tpl = getTemplateName(bagID)
	local button = tremove(recycled[tpl]) or ItemButton.Create(tpl)

	button.bagID = bagID
	button.ident = bagID*100 + slotID
	button:SetID(slotID)
	button:Show()
	button:RestoreState()

	return button
end

function ItemButton:Remove()
	Bagrealis.RemoveFromZone(self)
	self:ClearDB()
	self.id = nil
	self.ident = nil
	self:Hide()
	local tpl = getTemplateName(bagID)
	tinsert(recycled[tpl], button)
end
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
local ItemButton = Bagrealis:GetItemButtonPrototype()
Bagrealis:ImplementDefaultButton(ItemButton)
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
		local frame = db[1] and Bagrealis.contByName[db[1]] or Bagrealis.MainFrame
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

function ItemButton:OnCreate(tpl)
	Bagrealis:RegisterObject(self)

	self:SetMovable(true)
	self:EnableMouseWheel(true)

	self:SetScript("PreClick", self.SetBagID)
	self:SetScript("OnDragStart", self.OnDragStart)
	self:SetScript("OnDragStop", self.OnDragStop)
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnReceiveDrag", Bagrealis.DummyFunction)
	self:SetScript("OnMouseWheel", self.OnMouseWheel)

	return button
end

function ItemButton:OnAdd()
	self.ident = self.bagID*100 + self.slotID
	self:RestoreState()
end

function ItemButton:OnRemove()
	Bagrealis.RemoveFromZone(self)
	self:ClearDB()
	self.ident = nil
end
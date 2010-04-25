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
local Container = Bagrealis:GetContainerPrototype()
Bagrealis:ImplementDefaultButton(Container)
Container.class = "Container"

local sizer = CreateFrame("Button", nil, Bagrealis.MainFrame)
local sizing

local function Sizer_OnLeave()
	if(not (sizing or sizer:IsMouseOver() or Container.Hovered:IsMouseOver())) then
		sizer:Hide()
		Container.Hovered = nil
	end
end

sizer:SetSize(15, 15)
sizer:SetFrameLevel(100)
local sizerBG = sizer:CreateTexture(nil, "BACKGROUND")
sizerBG:SetAllPoints()
sizerBG:SetTexture(1, 0, 0, 0.7)

sizer:SetScript("OnMouseDown", function(sizer)
	sizing = true
	Container.Hovered:StartSizing("BOTTOMRIGHT")
end)
sizer:SetScript("OnMouseUp", function(sizer)
	sizing = nil
	Container.Hovered:StopMovingOrSizing()
	Container.Hovered:SaveState()
end)
sizer:SetScript("OnLeave", Sizer_OnLeave)





local moving

function Container:OnMouseDown(button)
	local action = self:GetUserAction(button)

	if(action == "selector") then
		Bagrealis.Selector:Start()
	elseif(action == "move" and not self.maximized) then
		moving = true
		self:StartMoving()
	end
end

function Container:OnMouseUp(button)
	local action = self:GetUserAction(button)

	if(action == "selector") then
		Bagrealis.Selector:Stop()
	elseif(action == "dropdown") then
		Bagrealis.DropDown:Open(self)
	elseif(action == "move" and not self.maximized) then
		moving = nil
		self:StopMovingOrSizing()
		self:SaveState()
	end
end

function Container:OnEnter()
	sizer:Show()
	sizer:ClearAllPoints()
	sizer:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	Container.Hovered = self
end

function Container:OnMouseWheel(delta)
	local action = self:GetUserAction("Wheel")

	if(action == "alpha" and not self.maximized) then
		self:SetAlpha(Bagrealis.minmax(self:GetAlpha() + delta*0.1, 0, 1))
		self:SaveState()
	elseif(action == "scale" and not self.maximized) then
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





local tempContainers = {}
function Container:Get(ident)
	local container = tremove(tempContainers) or Container:New(ident)
	container.ident = ident
	container:Show()
	return container
end

function Container:OnCreate(ident)
	local config = self:GetConfig()

	self:SetMovable(true)
	self:SetResizable(true)
	self:SetClampedToScreen(true)
	self:EnableMouseWheel(true)
	self:SetScript("OnMouseDown", self.OnMouseDown)
	self:SetScript("OnMouseUp", self.OnMouseUp)
	self:SetScript("OnEnter", self.OnEnter)
	self:SetScript("OnLeave", Sizer_OnLeave)
	self:SetScript("OnMouseWheel", self.OnMouseWheel)

	self:SetBackdrop(config.Backdrop)
	self:SetBackdropColor(unpack(config.BackdropColor))
	self:SetBackdropBorderColor(unpack(config.BorderColor))

	Bagrealis:RegisterZone(self)
	Bagrealis:RegisterObject(self)
end

function Container:Remove()
	assert(not next(Bagrealis.GetZoneContents(self)), "Container is not empty!")

	Bagrealis.RemoveFromZone(self)
	sizer:Hide()

	self:ClearDB()
	self:Hide()

	self.ident = nil
	tinsert(tempContainers, self)
end

function Container:SaveState()
	local db = self:GetDB(true)
	local pA, pB, pC, pD, pE = self:GetPoint()
	pB = pB and pB.class == "Container" and pB.ident or nil
	local s = self:GetScale()
	local a = self:GetAlpha()
	local w, h = self:GetSize()
	db[1], db[2], db[3] = pB, pD, pE
	db[4], db[5] = s, a
	db[6], db[7] = w, h
end

function Container:RestoreState()
	local db = self:GetDB()
	self:ClearAllPoints()

	if(db) then
		local frame = db[1] and Bagrealis.contByName[db[1]] or Bagrealis.MainFrame
		Bagrealis.InsertIntoZone(self, frame)
		self:SetParent(frame)
		self:SetPoint("CENTER", frame, "TOPLEFT", db[2], db[3])
		self:SetScale(db[4])
		self:SetAlpha(db[5])
		self:SetSize(db[6], db[7])
	else
		self:SetParent(Bagrealis.MainFrame)
		self:SetPoint("CENTER", Bagrealis.MainFrame, "CENTER")
		self:SetScale(1)
		self:SetAlpha(1)
		self:SetSize(100, 100)
	end
end

function Container:MaximizeRestore()
	self.maximized = not self.maximized
	if(self.maximized) then
		self:SetParent(Bagrealis.MainFrame)
		self:SetFrameLevel(98)
		Bagrealis.Anims.Show(self)
		self:SetScale(1)
		self:ClearAllPoints()
		self:SetPoint("CENTER", UIParent, "CENTER")
	else
		self:RestoreState()
	end
end

Container.DropDownEntries = {
	{
		text = "Remove Container",
		func = function() Bagrealis.DropDown.Selected:Remove() end,
	},{
		text = "Maximize / restore",
		func = function() Bagrealis.DropDown.Selected:MaximizeRestore() end,
	}
}
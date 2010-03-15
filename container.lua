local Bagrealis, addon, ns = Bagrealis, ...

local Container = Bagrealis:NewPrototype("Container")

local defaults = {}

local sizing, activeContainer
local function Header_OnLeave(header)
	if(not (sizing or header:IsMouseOver() or activeContainer:IsMouseOver())) then
		header:Hide()
	end
end

local header = CreateFrame("Button", nil, Bagrealis)
header:SetScript("OnLeave", Header_OnLeave)
header:SetFrameLevel(100)

local headerBG = header:CreateTexture(nil, "BACKGROUND")
headerBG:SetAllPoints()
headerBG:SetTexture(0, 0, 0, 0.7)

sizer = CreateFrame("Button", nil, header)
sizer:SetSize(15, 15)
sizer:SetScript("OnMouseDown", function(sizer)
	sizing = true
	activeContainer:StartSizing("BOTTOMRIGHT")
end)
sizer:SetScript("OnMouseUp", function(sizer)
	sizing = nil
	activeContainer:StopMovingOrSizing()
	activeContainer:SaveState()
end)

local sizerBG = sizer:CreateTexture(nil, "BACKGROUND")
sizerBG:SetAllPoints()
sizerBG:SetTexture(1, 0, 0, 0.7)


local tempContainers, moving = {}

local function Container_OnMouseDown(self)
	if(IsShiftKeyDown()) then
		Bagrealis:StartSelecting()
	else
		moving = true
		self:StartMoving()
	end
end

local function Container_OnMouseUp(self)
	if(moving) then
		moving = nil
		self:StopMovingOrSizing()
		self:SaveState()
	else
		Bagrealis:StopSelecting()
	end
end

local function Container_OnEnter(self)
	header:Show()
	header:ClearAllPoints()
	header:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 10)
	header:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT")
	sizer:ClearAllPoints()
	sizer:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	activeContainer = self
end

local function Container_OnLeave(self)
	Header_OnLeave(header)
end

local function Container_OnMouseWheel(self, delta)
	local speed = delta * (IsShiftKeyDown() and 0.3 or 0.1)
	if(IsControlKeyDown()) then
		self:SetAlpha(ns.minmax(self:GetAlpha() + speed, 0, 1))
	else
		local a,b,c,d,e = self:GetPoint()
		local old = self:GetScale()
		local new = ns.minmax(old + old * speed, 0.1, 10)
		d, e = d/new, e/new
		self:SetScale(new)
		self:ClearAllPoints()
		self:SetPoint(a,b,c, d*old, e*old)
	end
	self:SaveState()
end

function Container.Create(ident)
	local button = tremove(tempContainers)
	if(button) then return button end

	button = setmetatable(CreateFrame("Button", nil, Bagrealis), Container)
	button:SetMovable(true)
	button:SetResizable(true)
	button:SetClampedToScreen(true)
	button:EnableMouseWheel(true)
	button:SetScript("OnMouseDown", Container_OnMouseDown)
	button:SetScript("OnMouseUp", Container_OnMouseUp)
	button:SetScript("OnEnter", Container_OnEnter)
	button:SetScript("OnLeave", Container_OnLeave)
	button:SetScript("OnMouseWheel", Container_OnMouseWheel)

	Bagrealis.DragDrop:RegisterZone(button)
	Bagrealis.DragDrop:RegisterObject(button)

	local backdrop = button:CreateTexture(nil, "BACKGROUND")
	backdrop:SetAllPoints()
	backdrop:SetTexture(0, 0, 0, 0.5)

	return button
end

function Container:Remove()
	assert(not next(Bagrealis.DragDrop.GetZoneContents(self)), "Container is not empty!")

	self:ClearDB()
	self:Hide()
	tinsert(tempContainers, self)
end

function Container:SaveState()
	local db = self:GetDB(true)
	local pA, pB, pC, pD, pE = self:GetPoint()
	if(pB and pB._name == "Container") then
		pB = pB.ident
	else
		pB = nil
	end
	local s = self:GetScale()
	local a = self:GetAlpha()
	local w, h = self:GetSize()
	db[1], db[2], db[3] = pB, pD, pE
	db[4], db[5] = s, a
	db[6], db[7] = w, h
end

function Container:RestoreState()
	db = self:GetDB() or defaults
	self:ClearAllPoints()

	local frame = db[1] and Bagrealis.Containers[db[1]] or Bagrealis
	Bagrealis.DragDrop.InsertIntoZone(frame, self)
	self:SetParent(frame)
	self:SetPoint("CENTER", frame, "TOPLEFT", db[2], db[3])
	self:SetScale(db[4])
	self:SetAlpha(db[5])
	self:SetSize(db[6], db[7])
end
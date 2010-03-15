local Bagrealis, addon, ns = Bagrealis, ...

local backdrop = {
	bgFile = [[Interface\AddOns\Bagrealis\textures\background]],
	edgeFile = [[Interface\AddOns\Bagrealis\textures\border]],
	edgeSize = 10,
	insets = {left = 5, right = 5, top = 5, bottom = 5}
}

local Container = Bagrealis:NewPrototype("Container")

local defaults = {}

local sizer = CreateFrame("Button", nil, UIParent)
local sizing

local function Sizer_OnLeave()
	if(not (sizing or sizer:IsMouseOver() or Bagrealis.ActiveContainer:IsMouseOver())) then
		sizer:Hide()
		Bagrealis.ActiveContainer = nil
	end
end

sizer:SetSize(15, 15)
sizer:SetFrameLevel(100)
local sizerBG = sizer:CreateTexture(nil, "BACKGROUND")
sizerBG:SetAllPoints()
sizerBG:SetTexture(1, 0, 0, 0.7)

sizer:SetScript("OnMouseDown", function(sizer)
	sizing = true
	Bagrealis.ActiveContainer:StartSizing("BOTTOMRIGHT")
end)
sizer:SetScript("OnMouseUp", function(sizer)
	sizing = nil
	Bagrealis.ActiveContainer:StopMovingOrSizing()
	Bagrealis.ActiveContainer:SaveState()
end)
sizer:SetScript("OnLeave", Sizer_OnLeave)





local tempContainers, moving = {}

local function Container_OnMouseDown(self, button)
	if(button == "RightButton") then return end

	if(IsShiftKeyDown()) then
		Bagrealis:StartSelecting()
	else
		moving = true
		self:StartMoving()
	end
end

local function Container_OnMouseUp(self, button)
	if(button == "RightButton") then
		return self:DropDown()
	end

	if(moving) then
		moving = nil
		self:StopMovingOrSizing()
		self:SaveState()
	else
		Bagrealis:StopSelecting()
	end
end

local function Container_OnEnter(self)
	sizer:Show()
	sizer:ClearAllPoints()
	sizer:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
	Bagrealis.ActiveContainer = self
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
	local container = tremove(tempContainers)
	if(container) then return button end

	container = setmetatable(CreateFrame("Button", nil, Bagrealis), Container)
	container:SetMovable(true)
	container:SetResizable(true)
	container:SetClampedToScreen(true)
	container:EnableMouseWheel(true)
	container:SetScript("OnMouseDown", Container_OnMouseDown)
	container:SetScript("OnMouseUp", Container_OnMouseUp)
	container:SetScript("OnEnter", Container_OnEnter)
	container:SetScript("OnLeave", Sizer_OnLeave)
	container:SetScript("OnMouseWheel", Container_OnMouseWheel)

	container:SetBackdrop(backdrop)
	container:SetBackdropColor(0, 0, 0, 0.5)
	container:SetBackdropBorderColor(0, 0, 0, 0.5)

	Bagrealis.DragDrop:RegisterZone(container)
	Bagrealis.DragDrop:RegisterObject(container)

	return container
end

function Container:Remove()
	assert(not next(Bagrealis.DragDrop.GetZoneContents(self)), "Container is not empty!")

	self:ClearDB()
	sizer:Hide()
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
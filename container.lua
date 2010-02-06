local Bagrealis, addon, ns = Bagrealis, ...

local Container = Bagrealis:NewPrototype("Container", true)

local defaults = {}

local function onDragStart(header) header.Container:StartMoving() end
local function onDragStop(header) header.Container:OnDragStop() end

function Container:OnDragStop()
	self:StopMovingOrSizing()
	self:ChangePoint("CENTER", nil, "TOPLEFT")
	self:SaveState()
end

function Container.Create()
	local button = setmetatable(CreateFrame("Button", nil, Bagrealis), Container)
	button:SetMovable(true)
	button:SetClampedToScreen(true)

	Bagrealis.DragDrop:RegisterZone(button)
	Bagrealis.DragDrop:RegisterObject(button)

	local header = CreateFrame("Button", nil, button)
	header:RegisterForDrag("LeftButton", "RightButton")
	header:SetScript("OnDragStart", onDragStart)
	header:SetScript("OnDragStop", onDragStop)
	header:SetPoint("TOPLEFT", button, "TOPLEFT")
	header:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 0, -14)
	header.Container = button

	local headerBG = header:CreateTexture(nil, "BACKGROUND")
	headerBG:SetAllPoints()
	headerBG:SetTexture(0, 0, 0, 0.7)

	local backdrop = button:CreateTexture(nil, "BACKGROUND")
	backdrop:SetAllPoints()
	backdrop:SetTexture(0.2, 0.2, 0.2, 0.3)

	return button
end

function Container:DragDrop_Enter(object)
	object:ChangePoint("CENTER", self, "TOPLEFT")
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

	local frame = db[1] and Bagrealis.Containers[db[1]] or UIParent
	self:SetPoint("CENTER", frame, "TOPLEFT", db[2], db[3])
	self:SetScale(db[4])
	self:SetAlpha(db[5])
	self:SetSize(db[6], db[7])
end
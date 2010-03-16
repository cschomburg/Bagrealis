local Bagrealis, addon, ns = Bagrealis, ...

local ItemButton = Bagrealis:NewPrototype("ItemButton")

function ItemButton:OnDragStart()
	self:StartMoving()
	GameTooltip:Hide()
end

function ItemButton:OnDragStop(button)
	self:StopMovingOrSizing()
	self:SaveState()
end

function ItemButton:OnMouseWheel(delta)
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

function ItemButton:SaveState()
	local db = self:GetDB(true)
	local pA, pB, pC, pD, pE = self:GetPoint()
	pB = pB and pB._name == "Container" and pB.ident
	local s = self:GetScale()
	local a = self:GetAlpha()
	db[1], db[2], db[3] = pB, pD, pE
	db[4], db[5] = s, a
end

function ItemButton:RestoreState()
	local db = self:GetDB()
	self:ClearAllPoints()

	if(db) then
		local frame = db[1] and Bagrealis.Containers[db[1]] or Bagrealis
		Bagrealis.DragDrop.InsertIntoZone(self, frame)
		self:SetParent(frame)
		self:SetPoint("CENTER", frame, "TOPLEFT", db[2], db[3])
		self:SetScale(db[4] or 1)
		self:SetAlpha(db[5] or 1)
	else
		self:SetParent(Bagrealis)
		self:SetPoint("CENTER", Bagrealis, "CENTER")
		self:SetScale(1)
		self:SetAlpha(1)
	end
end

local function preClick(self)
	self:GetParent():SetID(self.bagID)
end

local function onEnter(self)
	self:GetParent():SetID(self.bagID)
	if(bagID == -1) then
		BankFrameItemButton_OnEnter(self)
	else
		ContainerFrameItemButton_OnEnter(self)
	end
end

local slotsNum = 0
function ItemButton.Create(tpl)
	slotsNum = slotsNum+1

	local button = setmetatable(CreateFrame("Button", "BagrealisSlot"..slotsNum, Bagrealis, tpl), ItemButton)
	Bagrealis.DragDrop:RegisterObject(button)

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

	button:SetScript("PreClick", preClick)
	button:SetScript("OnDragStart", ItemButton.OnDragStart)
	button:SetScript("OnDragStop", ItemButton.OnDragStop)
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnReceiveDrag", ns.dummy)
	button:SetScript("OnMouseWheel", ItemButton.OnMouseWheel)

	return button
end
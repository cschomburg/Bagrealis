local Bagrealis, addon, ns = Bagrealis, ...
local DragDrop = Bagrealis.DragDrop

local select = CreateFrame("Frame", nil, Bagrealis)
select:SetResizable(true)
select:SetFrameLevel(100)
select:SetBackdrop{
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	}
select:SetBackdropColor(0, 1, 1, 0.1)
select:SetBackdropBorderColor(0, 1, 1, 1)
select:Hide()

local selectModifier = CreateFrame("Button", nil, Bagrealis)
selectModifier:SetMovable(true)
selectModifier:EnableMouseWheel(true)
selectModifier:SetBackdrop{
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	}
selectModifier:SetBackdropColor(0, 1, 1, 0.1)
selectModifier:SetBackdropBorderColor(0, 1, 1, 1)
selectModifier:Hide()

selectModifier:SetScript("OnMouseDown", function(self, button)
	if(button ~= "RightButton") then
		self:StartMoving()
	end
end)

selectModifier:SetScript("OnMouseUp", function(self, button)
	if(button == "RightButton") then
		Bagrealis.ClearSelection()
	else
		self:StopMovingOrSizing()
	end
end)

selectModifier:SetScript("OnMouseWheel", function(self, delta)
	local speed = delta * (IsShiftKeyDown() and 0.3 or 0.1)
	local a,b,c,d,e = self:GetPoint()
	local old = self:GetScale()
	local new = ns.minmax(old + old * speed, 0.1, 10)
	d, e = d/new, e/new
	self:SetScale(new)
	self:ClearAllPoints()
	self:SetPoint(a,b,c, d*old, e*old)
end)

local selections, selCount = {}
local sX, sY, fX, fY

function Bagrealis:StartSelecting()
	local x, y = GetCursorPosition()
	local eff = select:GetEffectiveScale()

	sX, sY = x/eff, y/eff
	fX, fY = nil
	select:Show()
end

function Bagrealis.StopSelecting()
	if(not select:IsShown() or select:GetWidth() == 0) then return Bagrealis.ClearSelection() end

	select:Hide()
	selectModifier:ClearAllPoints()
	selectModifier:SetAllPoints(select)
	selectModifier:SetFrameLevel(100)
	selectModifier:Show()

	selections, selCount = {}, 0

	for object in pairs(DragDrop.objects) do
		if(object._name == "ItemButton" and object:IsVisible() and DragDrop.IntersectsWith(selectModifier, object)) then
			selections[object] = true
			selCount = selCount + 1
			DragDrop.OnMoveStart(object)
			DragDrop.ChangeZone(object, selectModifier)
			object:SetFrameLevel(99)
		end
	end

	if(selCount == 0) then
		Bagrealis.ClearSelection()
	end
end

function Bagrealis.ClearSelection()
	for object in pairs(selections) do
		DragDrop.OnMoveStop(object)
		object:SaveState()
	end
	select:Hide()
	selectModifier:Hide()
	selectModifier:SetScale(1)
end

select:SetScript("OnMouseUp", Bagrealis.StopSelecting)
select:SetScript("OnUpdate", function(self)
	local x,y = GetCursorPosition()
	local eff = self:GetEffectiveScale()

	if(fX ~= x/eff or fY ~= y/eff) then
		fX, fY = x/eff, y/eff
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", min(sX, fX), max(sY, fY))
		self:SetWidth(abs(sX-fX))
		self:SetHeight(abs(sY-fY))
	end
end)

local function doLayout(self)
	if(self:GetText() == "Grid") then
		Bagrealis.Layouts.Grid(selectModifier, selections, columns or selCount^0.5, spacing)
	elseif(self:GetText() == "Stack") then
		Bagrealis.Layouts.Stack(selectModifier, selections)
	end
end

for i, type in ipairs{"Grid", "Stack"} do
	local button = CreateFrame("Button", nil, selectModifier)
	button:SetPoint("TOPLEFT", selectModifier, "TOPRIGHT", 0, -5-(i-1)*30)
	button:SetSize(50, 30)
	button:SetNormalFontObject(GameFontHighlight)
	button:SetHighlightFontObject(GameFontNormal)
	button:SetText(type)
	button:SetBackdrop{
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile = true, tileSize = 16, edgeSize = 16,
			insets = {left = 4, right = 4, top = 4, bottom = 4},
		}
	button:SetBackdropColor(0, 1, 1, 0.3)
	button:SetBackdropBorderColor(0, 1, 1, 1)
	button:SetScript("OnClick", doLayout)
end
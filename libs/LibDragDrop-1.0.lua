local lib = LibStub:NewLibrary("LibDragDrop-1.0", 1)
if(not lib) then return end

local env = {}
local envByObj = {}
local zonePerObj = {}
local Environment = {}
local mt_env = {__index = Environment}

function lib.RegisterEnvironment(id)
	env[id] = setmetatable({zones={}, objects={}}, mt_env)
	return env[id]
end

function lib.GetEnvironment(id)
	return env[id]
end

local anchorDist = {
	TOP = function(self) return self:GetCenter(), self:GetTop() end,
	TOPRIGHT = function(self) return self:GetRight(), self:GetTop() end,
	RIGHT = function(self) return self:GetRight(), select(2, self:GetCenter()) end,
	BOTTOMRIGHT = function(self) return self:GetRight(), self:GetBottom() end,
	BOTTOM = function(self) return self:GetCenter(), self:GetBottom() end,
	BOTTOMLEFT = function(self) return self:GetLeft(), self:GetBottom() end,
	LEFT = function(self) return self:GetLeft(), select(2, self:GetCenter()) end,
	TOPLEFT = function(self) return self:GetLeft(), self:GetTop() end,
	CENTER = function(self) return self:GetCenter() end,
}

local function getAnchorDistance(self, anchor)
	local eff = self:GetEffectiveScale()
	local x, y = anchorDist[anchor](self)
	return x*eff, y*eff
end

function lib.ChangePoint(region, anchor, target, tAnchor)
	local _anchor, _target, _tAnchor = region:GetPoint()
	anchor, target, tAnchor = anchor or _anchor, target or _target or UIParent, tAnchor or _tAnchor
	local x, y = getAnchorDistance(region, anchor)
	local tX, tY = getAnchorDistance(target, tAnchor)
	local scale = region:GetEffectiveScale()
	region:ClearAllPoints()
	region:SetPoint(anchor, target, tAnchor, (x-tX)/scale, (y-tY)/scale)
end

function lib.IsInRegion(region, x, y)
	local eff = region:GetEffectiveScale()
	local left, right = region:GetLeft()*eff, region:GetRight()*eff
	local top, bottom = region:GetTop()*eff, region:GetBottom()*eff
	debug(x, left, right)
	return (x > left) and (x < right) and (y < top) and (y > bottom)
end

function lib.EmbedGeometry(target)
	target.ChangePoint = lib.ChangePoint
	target.IsInRegion = lib.IsInRegion
end

local function safeCall(tbl, func, ...)
	return tbl[func] and tbl[func](tbl, ...)
end

local function onMoveStart(object)
	local env = envByObj[object]
	local active = zonePerObj[object]

	for zone in pairs(env.zones) do
		safeCall(zone, "DragDrop_Start", object)
		if(zone == active) then
			safeCall(zone, "DragDrop_Leave", object)
			zonePerObj[object] = nil
		end
	end
end

local function onMoveStop(object)
	local env = envByObj[object]

	local x,y = object:GetCenter()
	local eff = object:GetEffectiveScale()
	x, y = x*eff, y*eff

	local aLevel, aZone = -1

	for zone in pairs(env.zones) do
		safeCall(zone, "DragDrop_Stop", object)
		if(zone ~= object and zone:IsVisible() and zone:GetFrameLevel() > aLevel and lib.IsInRegion(zone, x, y)) then
			aLevel = zone:GetFrameLevel()
			aZone = zone
		end
	end
	if(aZone) then
		safeCall(aZone, "DragDrop_Enter", object)
		zonePerObj[object] = aZone
	end
end

function Environment:RegisterObject(object)
	self.objects[object] = true
	envByObj[object] = self
	hooksecurefunc(object, "StartMoving", onMoveStart)
	hooksecurefunc(object, "StopMovingOrSizing", onMoveStop)
end

function Environment:RegisterZone(zone)
	self.zones[zone] = true
end
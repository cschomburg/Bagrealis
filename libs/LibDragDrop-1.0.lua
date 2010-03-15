local lib = LibStub:NewLibrary("LibDragDrop-1.0", 1)
if(not lib) then return end

local env = {}
local envByObj = {}
local zonePerObj = {}
local objPerZone = {}
local Environment = {}
local mt_env = {__index = lib}

lib.zones, lib.objects = {}, {}

function lib.RegisterEnvironment(id)
	env[id] = setmetatable({zones={}, objects={}}, mt_env)
	return env[id]
end

function lib.GetEnvironment(id)
	return env[id]
end

function lib.ChangeZone(region, target)
	local eff, tEff = region:GetEffectiveScale(), target:GetEffectiveScale()
	local newScale = tEff*region:GetScale()

	local x, y = region:GetCenter()
	x, y = x*eff, y*eff

	local tX, tY = target:GetLeft(), target:GetTop()
	tX, tY = tX*tEff, tY*tEff

	region:SetParent(target)
	region:SetScale(eff/tEff)
	region:ClearAllPoints()
	region:SetPoint("CENTER", target, "TOPLEFT", (x-tX)/eff, (y-tY)/eff)
end

function lib.IsInRegion(region, x, y)
	if(type(x) == "table") then
		x,y = object:GetCenter()
		local oEff = object:GetEffectiveScale()
		x,y = x*oEff, y*oEff
	end
	local eff = region:GetEffectiveScale()
	local left, right = region:GetLeft()*eff, region:GetRight()*eff
	local top, bottom = region:GetTop()*eff, region:GetBottom()*eff
	return (x > left) and (x < right) and (y < top) and (y > bottom)
end

function lib.IntersectsWith(regionA, regionB)
	local aEff, bEff = regionA:GetEffectiveScale(), regionB:GetEffectiveScale();
	return	((regionA:GetLeft()*aEff) < (regionB:GetRight()*bEff))
		and ((regionB:GetLeft()*bEff) < (regionA:GetRight()*aEff))
		and ((regionA:GetBottom()*aEff) < (regionB:GetTop()*bEff))
		and ((regionB:GetBottom()*bEff) < (regionA:GetTop()*aEff))
end

function lib.GetParentZone(region)
	return zonePerObj[region]
end

function lib.GetZoneContents(zone)
	return objPerZone[zone]
end

function lib.InsertIntoZone(zone, object)
	objPerZone[zone][object] = true
end

local function safeCall(tbl, func, ...)
	return tbl[func] and tbl[func](tbl, ...)
end

function lib.OnMoveStart(object)
	local env = envByObj[object]
	local active = zonePerObj[object]

	for zone in pairs(env.zones) do
		safeCall(zone, "DragDrop_Start", object)
		if(zone == active) then
			safeCall(zone, "DragDrop_Leave", object)
			zonePerObj[object] = nil
			objPerZone[active][object] = nil
		end
	end
end

function lib.OnMoveStop(object)
	local env = envByObj[object]

	local x,y = object:GetCenter()
	local eff = object:GetEffectiveScale()
	x, y = x*eff, y*eff

	local aLevel, active = -1

	for zone in pairs(env.zones) do
		safeCall(zone, "DragDrop_Stop", object)
		if(zone ~= object and zone:IsVisible() and zone:GetFrameLevel() > aLevel and lib.IsInRegion(zone, x, y) and not(objPerZone[object] and objPerZone[object][zone])) then
			aLevel = zone:GetFrameLevel()
			active = zone
		end
	end
	if(active) then
		safeCall(active, "DragDrop_Enter", object)
		zonePerObj[object] = active
		objPerZone[active][object] = true
		lib.ChangeZone(object, active)
	end
end

function lib:RegisterObject(object)
	self.objects[object] = true
	envByObj[object] = self
	hooksecurefunc(object, "StartMoving", lib.OnMoveStart)
	hooksecurefunc(object, "StopMovingOrSizing", lib.OnMoveStop)
end

function lib:RegisterZone(zone)
	self.zones[zone] = true
	objPerZone[zone] = {}
end
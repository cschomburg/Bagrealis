local lib = LibStub:NewLibrary("LibDragDrop-1.0", 1)
if(not lib) then return end

local env = {[lib] = {zones={}, objects={}}}
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

function lib:Embed(target)
	for k,v in pairs(lib) do
		target[k] = v
	end
	env[target] = {zones={}, objects={}}
end

function lib:GetEnvironment()
	return env[self]
end

function lib.ChangeParent(region, target)
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

function lib.GetParentZone(object)
	return zonePerObj[object]
end

function lib.GetZoneContents(zone)
	return objPerZone[zone]
end

function lib.InsertIntoZone(object, zone)
	lib.RemoveFromZone(object)
	objPerZone[zone][object] = true
	zonePerObj[object] = zone
end

function lib.RemoveFromZone(object)
	local zone = zonePerObj[object]
	if(zone) then
		objPerZone[zone][object] = nil
		zonePerObj[object] = nil
	end
end

local function safeCall(tbl, func, ...)
	return tbl[func] and tbl[func](tbl, ...)
end

function lib.Object_OnMoveStart(object)
	local env = envByObj[object]
	local active = zonePerObj[object]

	lib.RemoveFromZone(object)

	for zone in pairs(env.zones) do
		safeCall(zone, "DragDrop_Start", object)
		if(zone == active) then
			safeCall(zone, "DragDrop_Leave", object)
		end
	end
end

function lib.IsParentZone(object, zone)
	local parent = zonePerObj[object]
	return parent and (parent == zone or lib.IsParentZone(parent, zone))
end

function lib.Object_OnMoveStop(object)
	local env = envByObj[object]
	local aLevel, active = -1

	gEnv = env

	for zone in pairs(env.zones) do
		safeCall(zone, "DragDrop_Stop", object)
		if(zone ~= object and zone:IsVisible() and zone:GetFrameLevel() > aLevel and not lib.IsParentZone(zone, object) and lib.IntersectsWith(object, zone)) then
			aLevel = zone:GetFrameLevel()
			active = zone
		end
	end
	if(active) then
		safeCall(active, "DragDrop_Enter", object)
		lib.InsertIntoZone(object, active)
		lib.ChangeParent(object, active)
	end
end

function lib:RegisterObject(object)
	env[self].objects[object] = true
	envByObj[object] = env[self]
	hooksecurefunc(object, "StartMoving", lib.Object_OnMoveStart)
	hooksecurefunc(object, "StopMovingOrSizing", lib.Object_OnMoveStop)
end

function lib:RegisterZone(zone)
	env[self].zones[zone] = true
	objPerZone[zone] = {}
end
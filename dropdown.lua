local Bagrealis, addon, ns = Bagrealis, ...
local Container = Bagrealis:GetPrototype("Container")

local dropdown, selectedContainer

local function removeActive()
	selectedContainer:Remove()
end

local function update()
	local info = {}

	if(Bagrealis:IsConfigModeOn()) then
		info.text = "Disable Config Mode"
		info.func = Bagrealis.DisableConfigMode
	else
		info.text = "Enable Config Mode"
		info.func = Bagrealis.EnableConfigMode
	end
	UIDropDownMenu_AddButton(info)

	
	info.text = "Remove container"
	info.func = removeActive
	UIDropDownMenu_AddButton(info)
end

local function createDropDown()
	dropdown = CreateFrame("Frame", "BagrealisDropDown", UIParent, "UIDropDownMenuTemplate")
	dropdown:SetID(1)
	UIDropDownMenu_Initialize(dropdown, update, "MENU")
	UIDropDownMenu_SetWidth(dropdown, 90)
	return dropdown
end

function Container:DropDown()
	selectedContainer = self
	ToggleDropDownMenu(1, nil, dropdown or createDropDown(), self, 0, 0)
end
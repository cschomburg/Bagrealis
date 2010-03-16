local Bagrealis, addon, ns = Bagrealis, ...

local DropDown = CreateFrame("Frame", "BagrealisDropDown", UIParent, "UIDropDownMenuTemplate")
Bagrealis.DropDown = DropDown

local info, init = {}, true

local function addEntry(name, func)
	info.text, info.func = name, func
	UIDropDownMenu_AddButton(info)
end

local function update()
	for i, entry in ipairs(DropDown.Selected.DropDownEntries) do
		UIDropDownMenu_AddButton(entry)
	end

	addEntry()

	if(Bagrealis:IsConfigModeOn()) then
		addEntry("Disable Config Mode", Bagrealis.DisableConfigMode)
	else
		addEntry("Enable Config Mode", Bagrealis.EnableConfigMode)
	end
end

function DropDown:Open(frame)
	self.Selected = frame
	if(init) then
		DropDown:SetID(1)
		UIDropDownMenu_Initialize(DropDown, update, "MENU")
		UIDropDownMenu_SetWidth(DropDown, 90)
	end
	ToggleDropDownMenu(1, nil, self, frame, 0, 0)
end
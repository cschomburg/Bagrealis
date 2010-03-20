--[[
    Copyright (C) 2009  Constantin Schomburg

    This file is part of Bagrealis.

    Bagrealis is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    Bagrealis is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Bagrealis.  If not, see <http://www.gnu.org/licenses/>.
]]

function Bagrealis.Tutorial()

local str = [[# Bagrealis Tutorial
Hi!
This tutorial guides you through your first steps of configuring Bagrealis.
Click _'Next'_ to get started or _'Close'_ to figure it out yourself :)
You can reopen this every time via */bagrealis tutorial*.

# Item Position
You have probably seen that all your *items are just below*.
This is the default position for all new icons without stored position.
You can already _drag them around_ with the mouse.

# Item options
So, we know that we can drag them - but what else can we do?
- *Scaling* via _mouse wheel_
- Change *opacity* with _mouse wheel_ while holding _[Shift]_

# Config Mode
Let's dive a little deeper into Bagrealis!
You can access the main options via */bagrealis* or just */bag*.
The most important one is _/bag config_ - it toggles the *Config Mode*.
Try to _use it now_!

# Creating Containers
Did you activate the Config Mode?
Now Bagrealis is everywhere over your screen for better handling!
Click on an empty part with your _right mouse button_ to create a *new container*!

# Moving and Resizing
You can *move* a container by using the _middle mouse button_ or holding _[Shift]_.
And if you hover over it, a small _red box_ will appear in the corner.
When you drag this one, you can *resize* the whole container.

# Scale my Opacity!
You've probably figured it out by yourself,
it works the same way the item buttons do:
- *Scaling* via _mouse wheel_
- Change *opacity* with _mouse wheel_ while holding _[Shift]_

# Obvious tip is obvious.
Ummm ... yeah, you can actually _move items into containers_.
It's unbelievable, I know.

# Deep-level nesting
You can also place a container in a container in a container in a ...
... you get the point.

# Selection rectangle
You didn't sort your items already, did you?
It's easier if you just draw a *selection rectangle* with the _left button_.

# More selection magic!
You can even _right-click_ the selection rectangle to open a *context menu*.
Try out what happens when you select the different *layout-options*!

# Only for leet people
Hey, you can _wheel-scale_ the selection, too!
By the way: They say there are even context menus for the containers.

# Maximizing power
If you _right-click_ containers, you can *maximize* them.
This places it full-sized in the center, so you can drop items into it.
It's an useful technique if you have lots of tiny bags.
Profession bags anyone?

# Highscore
You can *bring me joy* by:
1. _Donating_ (Super awesome!)
2. Just saying you _like it_ (Thanks!)
3. Giving _feedback_ (Nice!)
4. Reporting _bugs_ (they reproduce)
5. Asking _questions_ (Well ...)

# The end
There are probably a lot more good features to write about,
but they were not developed yet.
_ - Cargor_ <*xconstruct@gmail.com*>

]]



local tI, tutorials, updateTutorial = 1, {}
str:gsub("(.-)\r?\n\r?\n", function(c) table.insert(tutorials, c) end)


local Bagrealis = Bagrealis
local config = Bagrealis.Config.Container

local frame = CreateFrame("Button", nil, Bagrealis.MainFrame)
frame:SetBackdrop(config.Backdrop)
frame:SetBackdropColor(unpack(config.BackdropColor))
frame:SetBackdropBorderColor(unpack(config.BorderColor))
frame:SetWidth(500)
frame:SetHeight(100)
frame:SetPoint("TOP", 0, -200)
frame:SetMovable(true)
frame:SetScript("OnMouseDown", frame.StartMoving)
frame:SetScript("OnMouseUp", frame.StopMovingOrSizing)

local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
header:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -15)

local pos = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pos:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -15)

local text = frame:CreateFontString(nil, "Overlay", "ChatFontNormal")
text:SetJustifyH("LEFT")
text:SetPoint("TOPLEFT", 20, -40)
text:SetPoint("BOTTOMRIGHT", -20, 40)
text:SetSpacing(3)

local prev = CreateFrame("Button", nil, frame, "UIPanelButtonGrayTemplate")
prev:SetSize(70, 20)
prev:SetNormalFontObject(GameFontHighlightSmall)
prev:SetHighlightFontObject(GameFontHighlightSmall)
prev:SetText("Previous")
prev:SetPoint("BOTTOMLEFT", 10, 10)
prev:SetScript("OnClick", function()
	tI = tI-1
	updateTutorial()
end)

local next = CreateFrame("Button", nil, frame, "UIPanelButtonGrayTemplate")
next:SetSize(50, 20)
next:SetNormalFontObject(GameFontHighlightSmall)
next:SetHighlightFontObject(GameFontHighlightSmall)
next:SetText("Next")
next:SetPoint("BOTTOMRIGHT", -10, 10)
next:SetScript("OnClick", function()
	tI = tI+1
	updateTutorial()
end)

local close = CreateFrame("Button", nil, frame, "UIPanelButtonGrayTemplate")
close:SetSize(50, 20)
close:SetNormalFontObject(GameFontHighlightSmall)
close:SetHighlightFontObject(GameFontHighlightSmall)
close:SetText("Close")
close:SetPoint("BOTTOM", 0, 10)
close:SetScript("OnClick", function() frame:Hide() end)

updateTutorial = function()
	local title, msg = tutorials[tI]:match("^# (.-)\r?\n(.+)$")
	msg = msg:gsub("_(.-)_", "|cff00ff00%1|r"):gsub("%*(.-)%*", "|cff00ffff%1|r")
	frame:SetHeight(1000)
	header:SetText(title)
	pos:SetText(tI.."/"..#tutorials)
	text:SetText(msg)
	frame:SetHeight(text:GetStringHeight() + 100)
	
	if(tI == 1) then
		prev:Disable()
	else
		prev:Enable()
	end
	if(tI == #tutorials) then
		next:Disable()
	else
		next:Enable()
	end
end
updateTutorial()

Bagrealis.Tutorial = function() frame:Show() end

end
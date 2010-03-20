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

local Config = {}
Bagrealis.Config = Config

Config.Animations = true

Config.MainFrame = {
	Actions = {
		LeftButton = "selector",
		RightButton = "create_container",
	},
}

Config.Container = {
	Backdrop = {
		bgFile = [[Interface\AddOns\Bagrealis\textures\background]],
		edgeFile = [[Interface\AddOns\Bagrealis\textures\border]],
		edgeSize = 10,
		insets = {left = 5, right = 5, top = 5, bottom = 5}
	},
	BackdropColor = { 0, 0, 0, 0.5 },
	BorderColor = { 0, 0, 0, 0.5 },

	Actions = {
		LeftButton_Shift = "move",
		MiddleButton = "move",
		Button4 = "move",
		LeftButton = "selector",
		RightButton = "dropdown",
		Wheel_Shift = "alpha",
		Wheel = "scale",
	},
}

Config.ItemButton = {
	Actions = {
		Wheel_Shift = "alpha",
		Wheel = "scale",
	},
}

Config.Selector = {
	Backdrop = {
		bgFile = [[Interface\AddOns\Bagrealis\textures\background]],
		edgeFile = [[Interface\AddOns\Bagrealis\textures\border]],
		edgeSize = 2,
		insets = {left = 2, right = 2, top = 2, bottom = 2}
	},
	BackdropColor = { 0, 1, 1, 0.1 },
	BorderColor = { 0, 1, 1, 0.7 },

	Actions = {
		LeftButton = "move",
		MiddleButton = "move",
		RightButton = "dropdown",
	},
}
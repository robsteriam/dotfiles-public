local colors = require("appearance")
local settings = require("settings")
local sbar = require("sketchybar")

-- Equivalent to the --bar domain
sbar.bar({
	color = colors.bg3,
	height = settings.height,
	padding_right = 6,
	padding_left = 3,
	sticky = "on",
	topmost = "window",
	y_offset = 0,
	blur_radius = 30,
})

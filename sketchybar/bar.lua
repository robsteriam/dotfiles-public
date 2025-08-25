local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
	color = colors.bg2,
	height = settings.height,
	padding_right = 6,
	padding_left = 3,
	sticky = "on",
	topmost = "window",
	y_offset = 0,
	blur_radius = 30,
})

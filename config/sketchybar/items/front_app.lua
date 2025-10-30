local fonts = require("fonts")
local sbar = require("sketchybar")

local front_app = sbar.add("item", "front_app", {
	display = "active",
	icon = { drawing = false },
	label = {
		font = {
			style = fonts.font.style_map["Black"],
			size = 12.0,
		},
	},
	updates = true,
})

front_app:subscribe("front_app_switched", function(env)
	front_app:set({ label = { string = env.INFO } })
end)

front_app:subscribe("mouse.clicked", function()
	sbar.exec("aerospace workspace next")
end)

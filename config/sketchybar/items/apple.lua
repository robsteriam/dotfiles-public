local icons = require("icons")
local settings = require("settings")
local sbar = require("sketchybar")

local apple = sbar.add("item", {
	icon = {
		padding_left = settings.padding.icon_item.icon.padding_left,
		padding_right = settings.padding.icon_item.icon.padding_right,
		string = icons.apple,
	},
	label = { drawing = false },
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

apple:subscribe("mouse.clicked", function()
  sbar.animate("tanh", 8, function()
    apple:set {
      background = {
        shadow = {
          distance = 0,
        },
      },
      y_offset = -4,
      padding_left = 8,
      padding_right = 8,
    }
    apple:set {
      background = {
        shadow = {
          distance = 4,
        },
      },
      y_offset = 0,
      padding_left = 4,
      padding_right = 4,
    }
  end)
end)

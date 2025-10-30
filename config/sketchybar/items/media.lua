local icons = require("icons")
local colors = require("appearance").colors
local sbar = require("sketchybar")

local whitelist = {
	["Spotify"] = true,
	["Music"] = true,
	["Google Chrome"] = true,
	["Safari"] = true,
	["Microsoft Edge"] = true,
	["Firefox"] = true,
}

-- Function to get background color
local function get_media_app_color(app_name)
	if app_name == "Music" then
		return colors.red_bright
	elseif app_name == "Spotify" then
		return colors.spotify_green
	elseif
		app_name == "Safari"
		or app_name == "Firefox"
		or app_name == "Google Chrome"
		or app_name == "Microsoft Edge"
	then
		return colors.blue_bright
	else
		return colors.default
	end
end

-- Media Cover Settings
local media_cover = sbar.add("item", {
	position = "center",
	background = {
		image = {
			string = "media.artwork",
			scale = 1,
		},
		color = colors.transparent,
	},
	label = { drawing = false },
	icon = { drawing = false },
	drawing = false,
	updates = true,
	popup = {
		align = "center",
		horizontal = true,
	},
})

-- Media Artist Name Settings
local media_artist = sbar.add("item", {
	position = "center",
	drawing = false,
	associated_with = media_cover.name,
	padding_left = -200,
	padding_right = 10,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = { size = 14 },
		color = colors.with_alpha(colors.white, 0.6),
		max_chars = 18,
		y_offset = 0,
		align = "right",
	},
})

-- Media Title Settings
local media_title = sbar.add("item", {
	position = "center",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 14 },
		width = 0,
		max_chars = 18,
		y_offset = 0,
	},
})

-- Add Media Controls to popup
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.back },
	label = { drawing = false },
	click_script = "nowplaying-cli previous",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "nowplaying-cli togglePlayPause",
})
sbar.add("item", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "nowplaying-cli next",
})

-- Animate detail
local interrupt = 0
local was_playing = false
local function animate_detail(detail)
	if not detail then
		interrupt = interrupt - 1
	end
	if interrupt > 0 and not detail then
		return
	end

	sbar.animate("tanh", 60, function()
		media_artist:set({ label = { width = detail and "dynamic" or 0 } })
		media_title:set({ label = { width = detail and "dynamic" or 0 } })
	end)
end

media_cover:subscribe("media_change", function(env)
	if whitelist[env.INFO.app] then
		local is_playing = (env.INFO.state == "playing")
		local app_color = get_media_app_color(env.INFO.app)
		local started_playing = (not was_playing and is_playing)

		media_artist:set({ drawing = is_playing, label = env.INFO.artist })
		media_title:set({ drawing = is_playing, label = env.INFO.title })
		media_cover:set({ drawing = is_playing, background = { color = app_color } })

		if is_playing then
			animate_detail(true)
			interrupt = interrupt + 1
			sbar.delay(10, animate_detail)

			if started_playing then
				media_cover:animate("sin", 10, function()
					media_cover:set({
						background = { color = app_color .. "aa" },
					})
				end, function()
					media_cover:set({
						background = { color = app_color .. "aa" },
					})
				end)
			end
		else
			media_cover:set({ popup = { drawing = false } })
		end

		was_playing = is_playing
	end
end)

-- Mouse
media_cover:subscribe("mouse.entered", function(_)
	interrupt = interrupt + 1
	animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function(_) end)

media_cover:subscribe("mouse.clicked", function(_)
	media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function(_)
	media_cover:set({ popup = { drawing = false } })
end)

media_cover:subscribe("system_woke", function(_)
	sbar.trigger("media_change")
end)

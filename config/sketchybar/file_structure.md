# Config

## sketchybarrc

#!/usr/bin/env lua

-- Load the sketchybar-package and prepare the helper binaries
require("helpers")
require("init")

## init.lua
```lua
-- Require the sketchybar module
sbar = require("sketchybar")

-- Set the bar name, if you are using another bar instance than sketchybar
-- sbar.set_bar_name("bottom_bar")

-- Bundle the entire initial configuration into a single message to sketchybar
sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

-- Run the event loop of the sketchybar module (without this there will be no
-- callback functions executed in the lua module)
sbar.event_loop()

## bar.lua

local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
	color = colors.bar.bg,
	height = settings.height,
	padding_right = 6,
	padding_left = 3,
	sticky = "on",
	topmost = "window",
	y_offset = 0,
})
```

## default.lua
```lua
local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
    background = {
        border_color = colors.accent_bright,
        border_width = 0,
        color = colors.bg1,
        corner_radius = 6,
        height = settings.height,
        image = {
            corner_radius = 9,
            border_color = colors.grey,
            border_width = 1
        }
    },
    icon = {
        font = {
            family = settings.font_icon.text,
            style = settings.font_icon.style_map["Bold"],
            size = settings.font_icon.size
        },
        color = colors.white,
        highlight_color = colors.bg1,
        padding_left = 0,
        padding_right = 0,
    },
    label = {
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Semibold"],
            size = settings.font.size
        },
        color = colors.white,
        padding_left = settings.paddings,
        padding_right = settings.paddings,
    },
    popup = {
        align = "center",
        background = {
            border_width = 0,
            corner_radius = 6,
            color = colors.popup.bg,
            shadow = { drawing = true },
        },
        blur_radius = 50,
        y_offset = 5
    },
    padding_left = 3,
    padding_right = 3,
    scroll_texts = true,
    updates = "on",
})
```

## colors.lua
```lua
return {
	default = 0x80ffffff,
	black = 0xff181819,
	white = 0xffffffff,
	red = 0xfffc5d7c,
	red_bright = 0xe0f38ba8,
	green = 0xff9ed072,
	blue = 0xff76cce0,
	blue_bright = 0xe089b4fa,
	yellow = 0xffe7c664,
	orange = 0xfff39660,
	magenta = 0xffb39df3,
	grey = 0xff7f8490,
	transparent = 0x00000000,

	bar = {
		bg = 0xe040a02b,
		border = 0xff2c2e34,
	},

	popup = {
		bg = 0xFF1d1b2d,
		border = 0xff7f8490,
	},

	bg1 = 0xFF1d1b2d,
	bg2 = 0xe0313436,

	accent = 0xFFb482c2,
	accent_bright = 0x33efc2fc,

	spotify_green = 0xe040a02b,

	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
```

###
Helpers and items are folders.
There is a icons.lua with a list of icons

## items/workspaces.lua
```lua
local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local query_workspaces =
"aerospace list-workspaces --all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"

-- Root is used to handle event subscriptions
local root = sbar.add("item", { drawing = false, })
local workspaces = {}

local function withWindows(f)
    local open_windows = {}
    -- Include the window ID in the query so we can track unique windows
    local get_windows = "aerospace list-windows --monitor all --format '%{workspace}%{app-name}%{window-id}' --json"
    local query_visible_workspaces =
    "aerospace list-workspaces --visible --monitor all --format '%{workspace}%{monitor-appkit-nsscreen-screens-id}' --json"
    local get_focus_workspaces = "aerospace list-workspaces --focused"
    sbar.exec(get_windows, function(workspace_and_windows)
        -- Use a set to track unique window IDs
        local processed_windows = {}

        for _, entry in ipairs(workspace_and_windows) do
            local workspace_index = entry.workspace
            local app = entry["app-name"]
            local window_id = entry["window-id"]

            -- Only process each window ID once
            if not processed_windows[window_id] then
                processed_windows[window_id] = true

                if open_windows[workspace_index] == nil then
                    open_windows[workspace_index] = {}
                end

                -- Check if this app is already in the list for this workspace
                local app_exists = false
                for _, existing_app in ipairs(open_windows[workspace_index]) do
                    if existing_app == app then
                        app_exists = true
                        break
                    end
                end

                -- Only add the app if it's not already in the list
                if not app_exists then
                    table.insert(open_windows[workspace_index], app)
                end
            end
        end

        sbar.exec(get_focus_workspaces, function(focused_workspaces)
            sbar.exec(query_visible_workspaces, function(visible_workspaces)
                local args = {
                    open_windows = open_windows,
                    focused_workspaces = focused_workspaces,
                    visible_workspaces = visible_workspaces
                }
                f(args)
            end)
        end)
    end)
end

local function updateWindow(workspace_index, args)
    local open_windows = args.open_windows[workspace_index]
    local focused_workspaces = args.focused_workspaces
    local visible_workspaces = args.visible_workspaces

    if open_windows == nil then
        open_windows = {}
    end

    local icon_line = ""
    local no_app = true
    for i, open_window in ipairs(open_windows) do
        no_app = false
        local app = open_window
        local lookup = app_icons[app]
        local icon = ((lookup == nil) and app_icons["Default"] or lookup)
        icon_line = icon_line .. " " .. icon
    end

    sbar.animate("tanh", 10, function()
        for i, visible_workspace in ipairs(visible_workspaces) do
            if no_app and workspace_index == visible_workspace["workspace"] then
                local monitor_id = visible_workspace["monitor-appkit-nsscreen-screens-id"]
                icon_line = " —"
                workspaces[workspace_index]:set({
                    drawing = true,
                    label = { string = icon_line },
                    display = monitor_id,
                })
                return
            end
        end
        if no_app and workspace_index ~= focused_workspaces then
            workspaces[workspace_index]:set({
                drawing = false,
            })
            return
        end
        if no_app and workspace_index == focused_workspaces then
            icon_line = " —"
            workspaces[workspace_index]:set({
                drawing = true,
                label = { string = icon_line },
            })
        end

        workspaces[workspace_index]:set({
            drawing = true,
            label = { string = icon_line },
        })
    end)
end

local function updateWindows()
    withWindows(function(args)
        for workspace_index, _ in pairs(workspaces) do
            updateWindow(workspace_index, args)
        end
    end)
end

local function updateWorkspaceMonitor()
    local workspace_monitor = {}
    sbar.exec(query_workspaces, function(workspaces_and_monitors)
        for _, entry in ipairs(workspaces_and_monitors) do
            local space_index = entry.workspace
            local monitor_id = math.floor(entry["monitor-appkit-nsscreen-screens-id"])
            workspace_monitor[space_index] = monitor_id
        end
        for workspace_index, _ in pairs(workspaces) do
            workspaces[workspace_index]:set({
                display = workspace_monitor[workspace_index],
            })
        end
    end)
end

sbar.exec(query_workspaces, function(workspaces_and_monitors)
    for _, entry in ipairs(workspaces_and_monitors) do
        local workspace_index = entry.workspace

        local workspace = sbar.add("item", {
            background = {
                color = colors.bg1,
                drawing = true,
            },
            click_script = "aerospace workspace " .. workspace_index,
            drawing = false, -- Hide all items at first
            icon = {
                color = colors.with_alpha(colors.white, 0.3),
                drawing = true,
                font = { family = settings.font.numbers },
                highlight_color = colors.white,
                padding_left = 5,
                padding_right = 4,
                string = workspace_index
            },
            label = {
                color = colors.with_alpha(colors.white, 0.3),
                drawing = true,
                font = "sketchybar-app-font:Regular:16.0",
                highlight_color = colors.white,
                padding_left = 2,
                padding_right = 12,
                y_offset = -1,
            },
        })

        workspaces[workspace_index] = workspace

        workspace:subscribe("aerospace_workspace_change", function(env)
            local focused_workspace = env.FOCUSED_WORKSPACE
            local is_focused = focused_workspace == workspace_index

            sbar.animate("tanh", 10, function()
                workspace:set({
                    icon = { highlight = is_focused },
                    label = { highlight = is_focused },
                    blur_radius = 30,
                })
            end)
        end)
    end

    -- Initial setup
    updateWindows()
    updateWorkspaceMonitor()

    -- Subscribe to window creation/destruction events
    root:subscribe("aerospace_workspace_change", function()
        updateWindows()
    end)

    -- Subscribe to front app changes too
    root:subscribe("front_app_switched", function()
        updateWindows()
    end)

    root:subscribe("display_change", function()
        updateWorkspaceMonitor()
        updateWindows()
    end)

    sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
        local focused_workspace = focused_workspace:match("^%s*(.-)%s*$")
        workspaces[focused_workspace]:set({
            icon = { highlight = true },
            label = { highlight = true },
        })
    end)
end)
```
## items/menus.lua
```lua
local settings = require("settings")

-- Create a menu trigger item
local menu_item = sbar.add("item", "menu_trigger", {
    drawing = true,
    updates = true,
    icon = {
        font = {
            size = 14.0
        },
        padding_left = settings.padding.icon_item.icon.padding_left,
        padding_right = settings.padding.icon_item.icon.padding_right,
        string = "≡",
    },
    label = { drawing = false },
})

menu_item:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
end)

-- Maximum number of menu items to display
local max_items = 15
local menu_items = {}

-- Create the menu items that will appear inline
for i = 1, max_items, 1 do
    local menu = sbar.add("item", "menu." .. i, {
        position = "left", -- Position them on the left of the bar
        drawing = false,   -- Hidden by default
        icon = { drawing = false },
        label = {
            font = {
                style = settings.font.style_map["Semibold"]
            },
            padding_left = settings.paddings,
            padding_right = settings.paddings,
        },
        click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
    })
    menu_items[i] = menu
end

-- Menu watcher to monitor app changes
local menu_watcher = sbar.add("item", {
    drawing = false,
    updates = false,
})

-- Menu state variable
local menu_visible = false

-- Function to update menu contents
local function update_menus()
    sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
        -- Reset all menu items
        for i = 1, max_items do
            menu_items[i]:set({ drawing = false, width = 0 })
        end

        -- Update with new menu items
        local id = 1
        for menu in string.gmatch(menus, '[^\r\n]+') do
            if id <= max_items then
                menu_items[id]:set({
                    label = {
                        string = menu,
                    },
                    drawing = menu_visible,
                    width = menu_visible and "dynamic" or 0
                })
            else
                break
            end
            id = id + 1
        end
    end)
end

-- Function to toggle the menu
local function toggle_menu()
    -- Toggle the menu state
    menu_visible = not menu_visible

    if menu_visible then
        -- Show menu items with animation
        menu_watcher:set({ updates = true })

        -- Prepare menu items but keep them hidden until animation starts
        update_menus()

        -- Initialize items with drawing=false and width=0
        for i = 1, max_items do
            local query = menu_items[i]:query()
            local has_content = query.label.string ~= ""

            if has_content then
                -- Make sure items aren't visible at 0 width
                menu_items[i]:set({
                    drawing = false,
                    width = 0,
                    label = {
                        drawing = false
                    }
                })
            end
        end

        -- First make them drawing=true but with label still hidden
        for i = 1, max_items do
            local query = menu_items[i]:query()
            local has_content = query.label.string ~= ""

            if has_content then
                menu_items[i]:set({ drawing = true })
            end
        end

        -- Animate the expansion
        sbar.animate("tanh", 30, function()
            for i = 1, max_items do
                local query = menu_items[i]:query()
                local is_drawing = query.geometry.drawing == "on"

                if is_drawing then
                    -- First set the width
                    menu_items[i]:set({ width = "dynamic" })
                    -- Then make label visible
                    menu_items[i]:set({
                        label = {
                            drawing = true
                        }
                    })
                end
            end
        end)
    else
        update_menus()
        -- Hide menu items with animation
        sbar.animate("tanh", 30, function()
            for i = 1, max_items do
                menu_items[i]:set({ width = 0 })
            end
        end, function()
            for i = 1, max_items do
                menu_items[i]:set({ drawing = false })
            end
            menu_watcher:set({ updates = false })
        end)
    end
end

-- Click to toggle menu
menu_item:subscribe("mouse.clicked", function(env)
    toggle_menu()
end)

-- Subscribe to front app changes
menu_watcher:subscribe("front_app_switched", function(env)
    update_menus()
end)

-- Initial update
update_menus()

return menu_watcher
```
## items/media.lua
```lua
local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local whitelist = {
    ["Google Chrome"] = true,
    ["Firefox"] = true,
    ["Music"] = true,
    ["Plexamp"] = true,
    ["Safari"] = true,
    ["Spotify"] = true,
}

-- Function to get the appropriate background color based on media app
local function get_media_app_color(app_name)
    if app_name == "Music" then
        return colors.red_bright
    elseif app_name == "Plexamp" then
        return colors.yellow
    elseif app_name == "Spotify" then
        return colors.spotify_green
    elseif app_name == "Safari" or app_name == "Firefox" or app_name == "Google Chrome" then
        return colors.blue_bright
    else
        return colors.default
    end
end

local now_playing = sbar.add("item", {
    position = "right",
    drawing = false,
    background = {
        color = colors.spotify_green,
    },
    icon = {
        padding_left = settings.padding.icon_label_item.icon.padding_left,
        padding_right = settings.padding.icon_label_item.icon.padding_right,
        string = '󰐌',
    },
    label = {
        highlight = false,
        padding_left = settings.padding.icon_label_item.label.padding_left,
        padding_right = settings.padding.icon_label_item.label.padding_right,
    },
    popup = { align = "center" }
})

-- Previous state tracking to detect when media starts playing
local was_playing = false

now_playing:subscribe("media_change", function(env)
    if whitelist[env.INFO.app] then
        local is_playing = (env.INFO.state == "playing")
        local app_color = get_media_app_color(env.INFO.app)

        -- Check if we're transitioning from not playing to playing
        local started_playing = (not was_playing and is_playing)

        now_playing:set({
            background = { color = app_color },
            drawing = is_playing,
            label = { string = env.INFO.title .. " - " .. env.INFO.artist },
        })

        -- Add animation when media starts playing
        if started_playing then
            -- Animate the item with a subtle fade-in
            now_playing:animate("sin", 10, function()
                now_playing:set({
                    background = { color = app_color .. "aa" }, -- Add transparency
                })
            end, function()
                now_playing:set({
                    background = { color = app_color }, -- Back to normal
                })
            end)
        end

        -- Update the state tracker
        was_playing = is_playing
    end
end)

-- Make sure the item is updated when sketchybar starts
now_playing:subscribe("system_woke", function(env)
    sbar.trigger("media_change")
end)
```

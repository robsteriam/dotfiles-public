# Sketchybar Configuration

This is a highly modular and customizable Sketchybar configuration written primarily in Lua. It leverages Sketchybar's Lua plugin to create a dynamic and event-driven bar.

## How It Works

The configuration is loaded in the following sequence:

1.  **Entry Point (`sketchybarrc`)**: When Sketchybar starts, it executes the `sketchybarrc` file. This script is the main entry point for the entire configuration.

2.  **Lua Initialization (`init.lua`)**: `sketchybarrc` immediately hands over control to the main `init.lua` script. This script is the orchestrator for the entire setup. It loads all other configuration files in a specific order.

3.  **Core Configuration**: `init.lua` first loads the core bar settings (`bar.lua`) and then a set of default properties (`settings.lua`, `appearance.lua`, etc.) that apply to all items.

4.  **Items and Widgets**: After the core setup, it loads all the individual bar items from the `items/` directory. Each file in this directory (e.g., `cpu.lua`, `wifi.lua`, `media.lua`) corresponds to a specific element on the bar.

5.  **Event Loop**: Once the entire configuration is loaded, an event loop (`sbar.event_loop()`) is started. This loop listens for system events (like Wi-Fi changes, media playback, or front application switches) and updates the corresponding bar items in real-time.

6.  **Helpers**: The `helpers/` directory contains custom C programs that act as event providers for things not natively supported by Sketchybar, such as CPU load. These are compiled automatically.

## File Structure & Customization

To customize the bar, you should edit the following files:

### Main Settings

These files control the overall look and feel of the bar.

*   `settings.lua`: The primary file for customization. Here you can change the bar's height, corner radius, and default item/text padding.
*   `appearance.lua`: Defines the color palette for the entire bar. Change the colors here to theme your bar.
*   `fonts.lua`: All font definitions are located here. You can change font families, sizes, and styles.
*   `icons.lua`: A central repository for all icons used across the bar.

### Bar Layout and Items

*   `bar.lua`: Configures the main properties of the bar itself, such as its position, blur, and background color.
*   `items/`: This directory contains the configuration for every item and widget on the bar.
    *   To **remove an item**, comment out its `require` statement in `items/init.lua`.
    *   To **add a new item**, create a new `.lua` file in this directory and `require` it in `items/init.lua`.
    *   To **change the position of items**, you can reorder the `require` statements in `items/init.lua` or change the `position` property within the item's file itself.

### Advanced

*   `helpers/`: This directory contains the source code for custom event providers. You generally won't need to touch these files unless you are adding a new, complex feature that requires an external helper.
*   `sketchybarrc`: The main entry point. You should not need to edit this file.
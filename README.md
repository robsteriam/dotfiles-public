# **robsteriam Dotfiles**

These are the personal configuration files for my macOS setup, designed for a keyboard driven workflow. This is a work in progress and will constantly change over time. I'm having fun, enjoying the process and learning.

Explore the documentation on the **[Wiki](https://github.com/robsteriam/dotfiles-public/wiki)** or see it in action in the video demo below.

> [!NOTE]
> This setup is opinionated and optimized for keyboard-driven workflows.  
> It’s a living project—expect it to evolve frequently.

<figure align="center">
  <a href="https://youtu.be/Nozqf0ZCiPw?si=z1MuF0Y4N9s8L3jU">
    <img
      src="https://img.youtube.com/vi/Nozqf0ZCiPw/maxresdefault.jpg"
      alt="macOS Setup: Aerospace, Sketchybar, JankyBorders, Raycast, Kitty, etc."
      width="80%"
      style="border-radius:12px; position:relative;"
    />
  </a>
  <figcaption>
    <p><strong>▶️ Watch the macOS Setup Demo:</strong> Aerospace · Sketchybar · Kitty · Raycast</p>
    <p><em>Click to open the video on YouTube.</em></p>
  </figcaption>
</figure>


---

## **Key Features**

- **Keyboard-Centric Workflow:** Navigate applications, windows, and the browser using familiar Vim motions.
- **Aesthetic & Cohesive:** A simple setup unified by the **Catppuccin** color theme across the terminal, editor, and window manager.
- **Seamless Multi-Monitor Support:** A custom **Aerospace** configuration to manage workspaces.
- **Simple & Effective Tools:** Aliases and a clean terminal setup.

---

### **Dotfile Structure & Management**

This repository is organized into distinct packages, each representing a logical group of configuration files. This modular approach, managed by GNU Stow, ensures a clean and flexible setup.

The top-level directories correspond to the final locations of the symlinked files:

- `config/`: Contains all files that will be symlinked to the `~/config/` directory.
- `zsh/`: Contains files that will be symlinked to the `~/` (home) directory.
- `config/brew/`: Contains the `Brewfile` used by `brew bundle` to manage application dependencies.

This structure allows for granular control over which dotfiles are active on your system.

> [!TIP]
> You can apply specific configurations selectively. For example, run `stow zsh` to only link your shell setup, or `stow config` to apply everything under `~/.config/`.

---

### **Prerequisites**

- macOS (Apple Silicon)
- [**Homebrew**](https://brew.sh/) (installed automatically by `setup.sh` if missing)
- [**GNU Stow**](https://www.gnu.org/software/stow/) (handled by Brewfile)
- [**Git**](https://git-scm.com/) (handled by Brewfile)

---

### **Packages**

Clicking on the package name will open their GitHub page.


| Tool                                                                                                                  | Description                                                                  | Configuration           |
| :-------------------------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------- | :---------------------- |
| [**Aerospace**](https://github.com/nikitabobko/AeroSpace)                                                                     | A tiling window manager                                                      | `aerospace.toml`        |
| [**dircolors**](https://github.com/gibbling/dircolors)                                                                | Colorizes `ls` output                                                        | `dircolors`             |
| [**Ghostty**](https://ghostty.org/docs)                                                                               | A modern terminal emulator                                                   | `ghostty.conf`          |
| [**Kitty**](https://sw.kovidgoyal.net/kitty/)                                                                         | A fast, feature-rich terminal emulator                                       | `kitty.conf`            |
| [**neofetch**](https://github.com/dylanaraps/neofetch) or [**fastfetch**](https://github.com/fastfetch-cli/fastfetch) | Displays system information                                                  | `config.conf`           |
| [**neovim**](https://neovim.io/)                                                                                      | The powerful editor, configured with [**LazyVim**](https://www.lazyvim.org/) | `init.lua`, `lua`       |
| [**Raycast**](https://www.raycast.com/)                                                                               | A fast launcher with powerful integrations                                   | `script_commands`       |
| [**sketchybar Lua**](https://github.com/FelixKratz/SbarLua)                                                           | A highly customizable macOS status bar                                       | `sketchybarrc`          |
| [**starship**](https://starship.rs/)                                                                                  | The prompt for any shell                                                     | `starship.toml`         |
| [**tmux**](https://github.com/tmux/tmux)                                                                              | A terminal multiplexer                                                       | `tmux.conf`             |
| [**zsh**](https://ohmyz.sh/)                                                                                          | The default shell                                                            | `.zshrc`, `aliases.zsh` |
| [**Vimium**](https://vimium.github.io/)                                                                               | A Chrome/Firefox extension for Vim-like browsing                             | `vimium-c-config`       |

---

### **Pre-Installation**

- Before running the script, `open config/brew/Brewfile` to choose which packages you want to install. You can comment or uncomment lines to include or exclude specific packages. If you know the package names, you can also add new ones here to have them installed automatically.

> [!NOTE]
> The Brewfile acts as a manifest. Each uncommented line represents a tool that will be installed automatically by `brew bundle`. Comment out anything you don’t want.

Snippet of Brewfile
```bash
# The "Brewfile" will automatically install everything listed below that is uncommented.
# Items marked as "tap" are repositories for formulas and casks.
# "brew" items are command-line tools.
# "cask" items are GUI applications.
# "vscode" items are VS Code extensions.

# ==========================
#   Taps (keep only needed)
# ==========================
# Essential taps for core system utilities and theming
tap "felixkratz/formulae"      # Tap for sketchybar and borders (macOS utilities)
tap "koekeishiya/formulae"     # Tap for macOS window managers like skhd and yabai
tap "nikitabobko/tap"          # Tap for the yazi terminal file manager

# ==========================
#   CLI Tools
# ==========================
brew "coreutils"               # GNU core utilities (e.g., `ls`, `grep`)
brew "git"                     # Version control system
# brew "neovim"                  # A highly extensible Vim-based text editor
...
```
---
### **Recommended Installation**

To make it your own, fork this repo and clone your fork instead:

> [!IMPORTANT]
> Run the setup commands from Terminal on macOS. The script assumes Apple Silicon and automatically handles `/opt/homebrew` paths. It should *not* be run as `root`.

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles
cd ~/dotfiles/scripts
./setup.sh
```
---

### **Setup Details & Script Breakdown**

This repository is designed for a single-command setup on a clean macOS installation. The included `setup.sh` script automates the entire process, making it easy to replicate the environment on a new machine.

Here's a breakdown of what the script does:

- **Initial Checks**: It first verifies that it is not being run as the `root` user to prevent permission issues.
- **Homebrew Installation**: It checks for the presence of **Homebrew**. If it is not found, the script automatically installs it and loads the environment into the current shell session.
- **Dependency Installation**: It uses `brew bundle` to install all applications, casks, and fonts listed in the `Brewfile`. This ensures all dependencies are met before continuing.
- **Dotfile Symlinking**: It uses **GNU Stow** to create symbolic links for the dotfiles in the `config` and `zsh` directories, linking them to their correct locations in the home directory.
- **Configuration Sourcing**: It sources the `zsh` configuration files (`.zshenv`, `.zprofile`, and `zshrc`) to apply shell and prompt customizations immediately.
- **Service Management**: It starts key macOS services like `borders` using `brew services`, ensuring they launch automatically on login.
- **Aerospace Setup**: Configures **Aerospace** and adds it to macOS login items.
- **Tmux Setup**: Installs the tmux plugin manager (TPM) along with three default plugins.

This approach streamlines the setup, so you only need to run one command to get your full environment up and running.

---

### **Script Breakdown**

- `setup.sh` -> full automated setup.
- `uninstall.sh` -> full teardown & cleanup.
- `aerospace-setup.sh` -> helper script for Aerospace installation, login items, and startup.

These scripts are modular, you can run them independently if needed.

---

### **Uninstallation Steps**

To restore a clean system:

```bash
cd ~/dotfiles/scripts
./uninstall.sh
```

**What the script does**:
- **Uninstalls Homebrew**: It runs Homebrew's official uninstall script to remove Homebrew and all packages, casks, and dependencies installed via the `Brewfile`.
- **Removes Directories**: It removes the Homebrew installation directory (`/opt/homebrew/`) to ensure a complete removal
- **Deletes Dotfiles**: It deletes the symlinked configuration files from your home directory (`~/.zprofile`, `~/.zshenv`) and removes the `~/.config` directory to clean up all configuration files.

Please note that this script requires `sudo` access to remove certain directories, so you will be prompted for your password during the process.

> [!WARNING]
> This script removes all Homebrew packages—including any you installed outside this dotfiles setup.  
> Back up your existing Brewfile first with `brew bundle dump`.

---

### **Post-Install Checks**

After running `setup.sh`, you can verify everything is working correctly:

- Run `brew doctor` to confirm Homebrew is healthy.
- Open a new terminal and ensure your prompt and aliases load properly.
- Check that **Aerospace** starts automatically and manages workspaces as expected.
- Verify **Sketchybar** is running by checking `brew services list`.
- Try `tmux` or `nvim` to confirm their configurations loaded successfully.

> [!TIP]
> Once everything’s running, explore `~/.config` and tweak each tool’s configuration to your liking. The real magic of dotfiles is customization.

---

### Resources

- <https://github.com/FelixKratz/SketchyBar/discussions/47?sort=top>
- <https://github.com/FelixKratz/SketchyBar/discussions/12>
- [sketchybar-app-font](https://github.com/kvndrsslr/sketchybar-app-font)
- <https://github.com/Nikolaidp24/SketchyBar>

---

### **Screenshots**

![Primary Monitor](./primary-horizontal-monitor.png)
![Secondary Monitor](./second-vertical-monitor.png)

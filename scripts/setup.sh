#!/bin/bash
# Bootstrap a fresh Mac (Apple Silicon): install Homebrew + packages, stow dotfiles,
# run Aerospace setup, start services, and reload the shell cleanly.

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# -------- Logging helpers --------
info() { printf "\n[INFO] %s\n" "$*"; }
ok() { printf "✅ %s\n" "$*"; }
warn() { printf "⚠️  %s\n" "$*"; }
err() { printf "❌ %s\n" "$*" >&2; }

# Find the absolute path of the directory where this script is located
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# Define the repository root as the parent directory of this script
REPO_ROOT=$(dirname "$SCRIPT_DIR")

# -------- Timing --------
START_TIME=$(date +%s)

# -------- Env (Homebrew non-interactive & quiet) --------
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export NONINTERACTIVE=1

echo
echo "=== 🚀 INITIALIZING SETUP SCRIPT ==="
echo "------------------------------------"

# -------- Safety: not root --------
if [ "$EUID" -eq 0 ]; then
  err "This script should not be run as root. Please run as a normal user."
  exit 1
fi

# -------- Optional: warm up sudo (you'll be prompted once) --------
info "Requesting sudo access (one prompt)..."
sudo -v || true

# -------- Homebrew install / init --------
info "--- CHECKING IF HOMEBREW IS INSTALLED ---"
if ! command -v brew &>/dev/null; then
  warn "Homebrew not found. Installing Homebrew..."
  if ! NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
    >"$HOME/setup.brew-install.log" 2>&1; then
    err "Homebrew install failed. See ~/setup.brew-install.log"
    exit 1
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
  ok "Homebrew installed and environment loaded"
else
  ok "Homebrew already installed."
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# -------- Brew Bundle --------
info "--- INSTALLING BREW BUNDLE PACKAGES ---"
echo "==============================================================================================================="
warn "Some casks (e.g. Password Manager, VPNs, fonts, browsers) may trigger macOS password prompts."
warn "This happens because certain apps install into /Applications or /Library/Fonts and require elevated privileges."
warn "You may also see prompts for helper tools or Keychain access — this is normal."
echo "==============================================================================================================="
BREWFILE="$REPO_ROOT/config/brew/Brewfile"
[ -r "$BREWFILE" ] || {
  err "Brewfile not found at '$BREWFILE'."
  exit 1
}

set +e
brew bundle install --file="$BREWFILE" 2>&1 | tee -a "$HOME/setup.brew.log"
BUNDLE_RC=${PIPESTATUS[0]}
set -e

if [ "$BUNDLE_RC" -ne 0 ]; then
  warn "brew bundle reported failures (exit $BUNDLE_RC). Check ~/setup.brew.log. Continuing..."
else
  ok "Brewfile installed. (Details: ~/setup.brew.log)"
fi

# -------- Install SbarLua --------
info "Installing Sbarlua"
# Install readline if it's missing, as it's a common dependency for SbarLua
if ! brew list --formula | grep -q 'readline'; then
  warn "readline not found. Installing..."
  if ! brew install readline &>/dev/null; then
    err "Failed to install readline. Skipping SbarLua."
    exit 1
  fi
fi

# Install Lua if it's missing, as it's required for SbarLua
if ! brew list --formula lua &>/dev/null; then
  warn "Lua not found. Installing..."
  if ! brew install lua >/dev/null 2>&1; then
    err "Failed to install Lua. Skipping SbarLua."
    exit 1
  fi
else
  ok "Lua already installed."
fi

# Clone, build, and install SbarLua
if (git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/) >"$HOME/setup.sbarlua.log" 2>&1; then
  ok "SbarLua installed successfully. (Details: ~/setup.sbarlua.log)"
else
  err "SbarLua installation failed. Check ~/setup.sbarlua.log for details."
  exit 1
fi

# -------- Stow dotfiles --------
info "Stowing dotfiles..."
mkdir -p "$HOME/.config"
# Use $SCRIPT_DIR as the source directory for stow
stow --dir="$REPO_ROOT" --target="$HOME/.config" config
stow --dir="$REPO_ROOT" --target="$HOME" zsh
ok "Dotfiles stowed."

# -------- Aerospace setup --------
info "Running Aerospace setup..."
AERO_SCRIPT="$SCRIPT_DIR/aerospace-setup.sh"
if [ -r "$AERO_SCRIPT" ]; then
  # shellcheck source=./aerospace-setup.sh
  source "$AERO_SCRIPT"
  ok "Aerospace setup script executed."
else
  warn "Aerospace setup script not found or not readable: $AERO_SCRIPT."
fi

# Ensure AeroSpace is in macOS Login Items (adds it to "Open at Login")
if command -v osascript >/dev/null 2>&1; then
  # remove existing, then add cleanly
  osascript -e 'tell application "System Events" to if exists login item "AeroSpace" then delete login item "AeroSpace"' 2>/dev/null || true
  osascript -e 'tell application "System Events" to make login item at end with properties {name:"AeroSpace", path:"/Applications/AeroSpace.app", hidden:true}' >/dev/null 2>&1
fi

# -------- Services --------
info "Starting borders service..."
if brew services start borders >/dev/null 2>&1; then
  ok "borders started successfully."
else
  err "borders failed to start."
  exit 1
fi

info "Reloading Sketchybar..."
if sketchybar --reload >/dev/null 2>&1; then
  ok "Sketchybar reloaded."
else
  warn "Sketchybar reload failed or not running."
fi
sleep 2

# -------- Done + Shell reload --------
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MIN=$((ELAPSED / 60))
SEC=$((ELAPSED % 60))

info "Setup complete. Shell will reload in 5 seconds..."
printf "Reloading in"
for i in 5 4 3 2 1; do
  printf " %s" "$i"
  sleep 1
done
printf "…\n"

ok "$(printf "Total elapsed: %dm %02ds\n" "${MIN}" "${SEC}")"
exec "$SHELL" -l

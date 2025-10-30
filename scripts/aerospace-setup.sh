#!/usr/bin/env bash
# Install AeroSpace (if needed), start it now, and enable auto-start at login.

set -euo pipefail

# Make sure brew/aerospace resolve in non-interactive shells
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

log() { printf "[aerospace-setup] %s\n" "$*"; }

# --- Ensure AeroSpace is installed ---
if ! command -v brew >/dev/null 2>&1; then
  log "Error: Homebrew not found on PATH. Run this after Homebrew is installed."
  exit 1
fi

if ! brew list --cask aerospace >/dev/null 2>&1; then
  log "Installing AeroSpace via Homebrew cask…"
  brew install --cask aerospace
else
  log "AeroSpace already installed."
fi

# --- Start AeroSpace now ---
if [ -d "/Applications/AeroSpace.app" ]; then
  log "Starting AeroSpace via open -a"
  open -a "AeroSpace" || true
else
  log "Warning: /Applications/AeroSpace.app not found; skipping start."
fi

# Ensure exactly one Login Item; no LaunchAgent
log "Setting Login Item (no LaunchAgent)…"
launchctl bootout "gui/$UID/com.aerospace.start" >/dev/null 2>&1 || true
rm -f "$HOME/Library/LaunchAgents/com.aerospace.start.plist" || true

osascript <<'OSA' >/dev/null 2>&1 || true
tell application "System Events"
  repeat while (exists login item "AeroSpace")
    delete login item "AeroSpace"
  end repeat
  make login item at end with properties {name:"AeroSpace", path:"/Applications/AeroSpace.app", hidden:true}
end tell
OSA

log "Auto-start configured. Done."

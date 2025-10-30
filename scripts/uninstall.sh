#!/bin/bash
# Uninstall stack on Apple Silicon: remove AeroSpace autostart, stop services,
# uninstall all Homebrew packages/casks, remove Homebrew, and clean leftovers.

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# -------- Logging helpers --------
info() { printf "\n[INFO] %s\n" "$*"; }
ok() { printf "✅ %s\n" "$*"; }
warn() { printf "⚠️  %s\n" "$*"; }
err() { printf "❌ %s\n" "$*" >&2; }

# Pinpoint failures
trap 'err "Failed at line $LINENO: $BASH_COMMAND"; exit 1' ERR

# Sudo helper (non-interactive aware)
SUDO=""
if command -v sudo >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then
    SUDO="sudo"
  else
    info "Prompting once for your password to enable elevated commands..."
    sudo -v
    SUDO="sudo"
  fi
fi

# Keep sudo alive until script finishes
if [ -n "$SUDO" ]; then
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

# -------- Timing --------
START_TIME=$(date +%s)

# -------- Env (quiet/non-interactive brew) --------
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ANALYTICS=1
export NONINTERACTIVE=1

echo
echo "=== 🧹 UNINSTALLATION STARTED ==="

# -------- Remove AeroSpace autostart & traces --------
info "Removing Aerospace autostart..."

LABEL="com.aerospace.start"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

# unload LaunchAgent if loaded; then remove the plist
launchctl bootout "gui/$UID/$LABEL" >/dev/null 2>&1 || true
[ -f "$PLIST" ] && rm -f "$PLIST" || true

# remove Login Item if present
if command -v osascript >/dev/null 2>&1; then
  osascript -e 'tell application "System Events" to if exists login item "AeroSpace" then delete login item "AeroSpace"' 2>/dev/null || true
fi

# stop the app/process if running
pkill -x aerospace 2>/dev/null || true
osascript >/dev/null 2>&1 <<'OSA' || true
tell application "System Events"
  if (exists process "AeroSpace") then tell application "AeroSpace" to quit
end tell
OSA

# optional: remove logs
rm -f "$HOME/Library/Logs/aerospace.out.log" "$HOME/Library/Logs/aerospace.err.log" 2>/dev/null || true
ok "AeroSpace autostart removed."

# -------- Stop Homebrew services --------
info "Stopping Homebrew Services"
if command -v brew >/dev/null 2>&1; then
  brew services stop --all >/dev/null 2>&1 || true
  ok "Homebrew services stopped."
else
  warn "Homebrew not found. Skipping service shutdown."
fi

# -------- Remove dotfile symlinks & config dir --------
info "Removing dotfiles (symlinks/configs)..."
# Remove zsh files (they're at $HOME level, not in ~/.config)
rm -f "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.zshenv" >/dev/null 2>&1 || true

# Remove ONLY symlinks in ~/.config (leave real folders like configstore/)
if [ -d "$HOME/.config" ]; then
  find "$HOME/.config" -maxdepth 1 -type l -exec rm -f {} + 2>/dev/null || true
fi

# Remove ~/.config if it's now empty
rmdir "$HOME/.config" >/dev/null 2>&1 || true

ok "Dotfile cleanup completed."

# Verify Cleanup Status
info "Verifying symlink cleanup..."
if find "$HOME/.config" -maxdepth 1 -type l | grep -q .; then
  warn "Some symlinks still remain in ~/.config" \
    else
  ok "No symlinks remaining in ~/.config"
fi

ok "Symlink cleanup verified."

# -------- Uninstall all Homebrew packages & casks --------
info "Uninstalling Homebrew packages & casks..."
echo "==============================================================================================================="
warn "Some casks (e.g. Password Manager, VPNs, fonts, browsers) may trigger macOS password prompts."
warn "This happens because certain apps install into /Applications or /Library/Fonts and require elevated privileges."
warn "You may also see prompts for helper tools or Keychain access — this is normal."
echo "==============================================================================================================="
if command -v brew >/dev/null 2>&1; then
  LOG="$HOME/uninstall.brew.log"
  : >"$LOG"

  FORMULAE="$(brew list --formula 2>/dev/null || true)"
  if [ -n "${FORMULAE:-}" ]; then
    set +e
    brew uninstall --force --ignore-dependencies --quiet "$FORMULAE" >>"$LOG" 2>&1
    set -e
  fi

  CASKS="$(brew list --cask 2>/dev/null || true)"
  if [ -n "${CASKS:-}" ]; then
    set +e
    for c in $CASKS; do
      brew uninstall --cask --force "$c" >>"$LOG" 2>&1
      rc=$?
      if [ $rc -ne 0 ]; then
        warn "brew uninstall --cask $c failed ($rc). Trying direct removal..."
        guess="/Applications/$(/bin/echo "$c" | sed -E 's/[-_]/ /g; s/\b(.)/\U\1/g').app"
        if [ -n "$SUDO" ] && [ -d "$guess" ]; then
          $SUDO chflags -R nouchg "$guess" 2>/dev/null || true
          $SUDO rm -rf "$guess" 2>>"$LOG" || warn "Failed to remove $guess"
        else
          warn "Could not remove $c automatically (no sudo or unknown path)."
        fi
      fi
    done
    set -e
  fi
  ok "Homebrew packages and casks processed. (Details: ~/uninstall.brew.log)"
else
  warn "Homebrew is not installed. Skipping package uninstallation."
fi

# -------- Uninstall Homebrew itself --------
info "Uninstalling Homebrew..."
if [ -n "$SUDO" ]; then
  $SUDO rm -f /etc/paths.d/homebrew 2>/dev/null || true
else
  warn "Skipping /etc/paths.d/homebrew (no sudo)."
fi
rm -rf "$HOME/Library/Caches/Homebrew" "$HOME/Library/Logs/Homebrew" 2>/dev/null || true
ok "Homebrew core uninstalled."

# -------- Remove Homebrew directories (Apple Silicon) --------
info "Removing /opt/homebrew (cleanup)..."
if [ -n "$SUDO" ]; then
  $SUDO rm -rf /opt/homebrew/ || true
else
  warn "Skipping /opt/homebrew (no sudo)."
fi

if [ -e /opt/homebrew/ ]; then
  warn "/opt/homebrew still exists"
else
  ok "/opt/homebrew removed"
fi

if [ -e /etc/paths.d/homebrew ]; then
  warn "/etc/paths.d/homebrew still exists"
else
  ok "/etc/paths.d/homebrew removed"
fi

# -------- Verify Homebrew Removal ---------
info "Verifying Homebrew removal..."
if command -v brew >/dev/null 2>&1; then
  warn "brew still on PATH ($(command -v brew)). You may need to restart your shell."
else
  ok "brew not found on PATH."
fi

# -------- Uninstall SbarLua --------
info "Removing SbarLua..."
pkill -x sbarlua 2>/dev/null || true
rm -rf "$HOME/.local/share/sketchybar_lua/" 2>/dev/null || true
ok "SbarLua removed."

# -------- Uninstall SketchyBar --------
info "Uninstalling SketchyBar..."
pkill -x sketchybar 2>/dev/null || true
launchctl bootout "gui/$UID/com.felixkratz.sketchybar" >/dev/null 2>&1 || true
rm -f "$HOME/Library/LaunchAgents/com.felixkratz.sketchybar.plist" 2>/dev/null || true
brew uninstall --force --cask sketchybar >/dev/null 2>&1 || true
brew uninstall --force sketchybar >/dev/null 2>&1 || true
rm -rf "$HOME/.config/sketchybar" "$HOME/.local/share/sketchybar_lua" 2>/dev/null || true
ok "SketchyBar fully removed."

# -------- Final Cleanup --------
info "Cleaning up logs..."
rm -f "$HOME/setup.brew-install.log" \
  "$HOME/setup.brew.log" \
  "$HOME/setup.sbarlua.log" \
  "$HOME/uninstall.brew.log" \
  "$HOME/.config/sketchybar/aero-launch.log" \
  "$HOME/Library/Logs/aerospace.out.log" \
  "$HOME/Library/Logs/aerospace.err.log" 2>/dev/null || true

# Optional: catch any other setup/uninstall logs in $HOME
find "$HOME" -maxdepth 1 -type f \( -name 'setup.*.log' -o -name 'uninstall.*.log' \) \
  -exec rm -f {} + 2>/dev/null || true

# Remove empty log directories (optional safety cleanup)
rmdir "$HOME/Library/Logs" "$HOME/.config/sketchybar" 2>/dev/null || true

ok "Logs cleaned."

# -------- Done --------
END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MIN=$((ELAPSED / 60))
SEC=$((ELAPSED % 60))

echo
ok "UNINSTALLATION COMPLETE"
info "System restored to a clean slate."
ok "$(printf "Total elapsed: %dm %02ds" "${MIN}" "${SEC}")"
ok "Uninstallation complete. Please open a new terminal session."
echo

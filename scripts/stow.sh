#!/bin/bash

set -euo pipefail

echo "[INFO] Restowing dotfiles..."

cd "$(dirname "$0")/.."

stow --restow --target="$HOME/.config" config
stow --restow --target="$HOME" zsh

echo "✅ Dotfiles symlinked"

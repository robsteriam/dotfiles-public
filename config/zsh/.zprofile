# macOS Homebrew environment setup
if [[ "$(uname)" == "Darwin" ]]; then
    if [[ -x "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"
    fi
fi

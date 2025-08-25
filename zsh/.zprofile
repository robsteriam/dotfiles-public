# Platform-specific environment setup
case "$(uname)" in
    "Darwin")  # macOS
        if [[ -x "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"
        fi
        ;;
    "Linux")  # Ubuntu or other Linux
        # Linux-specific paths
        export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
        ;;
esac

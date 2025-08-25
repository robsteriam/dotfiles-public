# Set runtime file location
HISTFILE="$ZDOTDIR/.zsh_history"
ZSH_COMPDUMP="$ZDOTDIR/.zcompdump"

# Editor
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

# Reload Kitty
alias kitty-reload="sudo kill -SIGUSR1 $KITTY_PID"

# Initialize ZSH completion system
autoload -Uz compinit && compinit

# Azure CLI completion (adjust for Ubuntu if needed)
if command -v brew >/dev/null 2>&1; then
    BREW_PREFIX=$(brew --prefix 2>/dev/null)
    if [[ -n "$BREW_PREFIX" && -f "$BREW_PREFIX/etc/bash_completion.d/az" ]]; then
        source "$BREW_PREFIX/etc/bash_completion.d/az"
    fi
elif command -v az >/dev/null 2>&1; then
    if [[ ! -f "/etc/bash_completion.d/az" ]]; then
        mkdir -p /etc/bash_completion.d
        az completion > /etc/bash_completion.d/az 2>/dev/null
    fi
    [[ -f "/etc/bash_completion.d/az" ]] && source "/etc/bash_completion.d/az"
fi

# Example aliases (platform-specific)
case "$(uname)" in
    "Darwin")  # macOS
        alias mrdp="open /Applications/Microsoft\ Remote\ Desktop.app"
        alias notion="open /Applications/Notion.app"
        alias burp="open /Applications/Burp\ Suite\ Community\ Edition.app"
        alias postman="open /Applications/Postman.app"
        alias fusion="open /Applications/VMware\ Fusion.app"
        alias vnc="open /Applications/VNC\ Viewer.app"
        alias zoom="open /Applications/zoom.us.app"
        alias py="python3"
        ;;
    "Linux")  # Ubuntu or other Linux
        # Add Linux equivalents if desired
        alias py="python3"
        ;;
esac

# Platform-specific paths
case "$(uname)" in
    "Darwin")
        # macOS paths
        export PATH="/opt/homebrew/Cellar/openvpn/2.6.6/sbin/:$PATH"
        ;;
    "Linux")
        # Ubuntu paths (adjust as needed)
        export PATH="/usr/local/sbin:$PATH"
        ;;
esac

# Mason in path for LazyVIM
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Enable colored ls output
if [[ -x "$(command -v dircolors)" ]]; then
    eval "$(dircolors ~/.config/dircolors/.dircolors)"
    alias ls="ls --color=auto"
else
    export CLICOLOR=1
    export LSCOLORS="Exfxcxdxbxegedabagacad"
fi

# ZSH Custom Options (platform-specific plugin paths)
case "$(uname)" in
    "Darwin")
        source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ;;
    "Linux")
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ;;
esac

# Aliases
alias c='clear'
alias h='history'
alias hg='history | grep $1'
alias brewup='brew update && brew upgrade'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='colordiff'
alias path='echo -e ${PATH//:/\\n}'
alias wget='wget -c'
alias rm='rm -I'

# Information
alias ll='ls -la --color=auto'
alias la='ls -A --color=auto'
alias ls='ls -CF --color=auto'
alias lu='du -sh * | sort -h'
alias lt='ls -t -1 -long --color=auto'
alias lc='find . -type f | wc -l'
alias ld='ls -d */ --color=auto'

# Folders
alias 1d='cd ..'
alias 2d='cd ..;cd ..'
alias 3d='cd ..;cd ..;cd ..'
alias 4d='cd ..;cd ..;cd ..;cd ..'
alias 5d='cd ..;cd ..;cd ..;cd ..;cd ..'
alias untar='tar -zxvf $1'
alias tar='tar -czvf $1'
alias mkdir='mkdir -pv'

# Git Related
alias gs='get status'
alias gb='get branch'
alias gl='git log --oneline'
alias gpom='git push origin main'

# Fzf
source <(fzf --zsh)

# Starship
eval "$(starship init zsh)"

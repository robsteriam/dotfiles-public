# Set runtime file location
export HISTFILE="$HOME/.zsh_history"
export ZSH_COMPDUMP="$HOME/.zcompdump"
export ZSH_SESSION_DIR="$HOME/.zsh_sessions"

# Editor
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"

# Disable zsh session saving
DISABLE_AUTO_TITLE="true"
ZSH_DISABLE_SESSIONS="true"

# Reload Kitty
alias kitty-reload='[[ -n "$KITTY_PID" ]] && sudo kill -SIGUSR1 "$KITTY_PID"'

# --- Homebrew env (Apple Silicon) ---
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- zsh completion (init once) ---
autoload -Uz compinit
if [[ -z "${__COMPINIT_DONE:-}" ]]; then
  compinit -d "${ZSH_COMPDUMP:-$HOME/.zcompdump}"
  __COMPINIT_DONE=1
fi

# --- Azure CLI completion (Homebrew completion via zsh) ---
if command -v az >/dev/null 2>&1; then
  autoload -U +X bashcompinit && bashcompinit  # allow zsh to read bash completions
  AZ_COMPLETION="$(brew --prefix)/etc/bash_completion.d/az"
  [[ -r "$AZ_COMPLETION" ]] && source "$AZ_COMPLETION"
fi

# PATH tweaks (avoid hard-coding Cellar versions)
export PATH="/opt/homebrew/sbin:$PATH"

# Mason in path for LazyVIM
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

# Enable colored ls output
if [[ -x "$(command -v dircolors)" ]]; then
  eval "$(dircolors ~/.config/dircolors/.dircolors)"
else
  export CLICOLOR=1
  export LSCOLORS="Exfxcxdxbxegedabagacad"
fi

# App Aliases
alias mrdp="open /Applications/Microsoft\ Remote\ Desktop.app"
alias notion="open /Applications/Notion.app"
alias burp="open /Applications/Burp\ Suite\ Community\ Edition.app"
alias postman="open /Applications/Postman.app"
alias fusion="open /Applications/VMware\ Fusion.app"
alias vnc="open /Applications/VNC\ Viewer.app"
alias zoom="open /Applications/zoom.us.app"
alias py="python3"

# Aliases
alias c='clear'
alias h='history'
hg() { history | grep -i -- "$*"; }
alias brewup='brew update && brew upgrade'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='colordiff'
alias path='tr ":" "\n" <<< "$PATH"'
alias wget='wget -c'
alias rm='rm -I'
alias nvim-kickstart='NVIM_APPNAME="nvim-kickstart" nvim'
alias lazy='NVIM_APPNAME="nvim-lazy" nvim'

# Information
alias ll='ls -laG'
alias la='ls -AG'
alias ls='ls -GFh'
alias lu='du -sh * | sort -h'
alias lt='ls -ltG'
alias lc='find . -type f | wc -l'
alias ld='ls -d -G -- */(N)'

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
alias gs='git status'
alias gb='git branch'
alias gl='git log --oneline'
alias gpom='git push origin main'

# Navigation
alias onedrive="cd /Users/robsteriam/Library/CloudStorage/OneDrive-Personal"
alias dotfiles="cd /Users/robsteriam/dotfiles"
alias github="cd /Users/robsteriam/Library/CloudStorage/OneDrive-Personal/GitHub/"

# Fzf
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)

# Starship
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# ZSH Custom Options (platform-specific plugin paths)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

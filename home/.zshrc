# ==============================================================================
# 1. INITIALIZATION & SECRETS
# ==============================================================================
source ~/.zshenv
[ -f ~/.secrets ] && source ~/.secrets
[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"
[ -f ~/.dotnet.ef.commands ] && source ~/.dotnet.ef.commands # Sveriges Radio
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"       # Rust & Cargo

# ==============================================================================
# 2. ENVIRONMENT VARIABLES
# ==============================================================================
export VISUAL=nvim
export EDITOR=nvim
export KUBE_EDITOR=nvim
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export VAULT_ADDR="https://vault.tools.k8s.sr.se"
export CLR_OPENSSL_VERSION_OVERRIDE=3
export DOTNET_ROOT="/usr/local/share/dotnet"
export KUBECONFIG="$HOME/.kube/stodev03-ext.yaml:$HOME/.kube/stoprod03-ext.yaml"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="/Users/ivo/Library/pnpm"

# ==============================================================================
# 3. PATH CONSTRUCTION
# ==============================================================================
# Lägger till alla sökvägar systematiskt för att undvika rörig kod
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.moon/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/Users/ivolej01/.docker/bin:$PATH"
export PATH="$PATH:/Users/ivolej01/.dotnet/tools"
export PATH="$PATH:/usr/local/share/dotnet"
export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"
export PATH="/opt/homebrew/share/google-cloud-sdk/bin:$PATH"
export PATH="$HOME/.aspire/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$PATH:$HOME/.rvm/bin" # RVM rekommenderar att ligga sist i PATH

# PNPM
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ==============================================================================
# 4. HISTORY SETTINGS
# ==============================================================================
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# ==============================================================================
# 5. AUTOCOMPLETION
# ==============================================================================
# Lägg till completion-mappar INNAN compinit körs
fpath=(/Users/ivolej01/.docker/completions $fpath)

autoload -Uz compinit && compinit
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# ==============================================================================
# 6. KEYBINDINGS (Arrow keys)
# ==============================================================================
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A'  up-line-or-beginning-search    # Arrow up
bindkey '^[OA'  up-line-or-beginning-search
bindkey '^[[B'  down-line-or-beginning-search  # Arrow down
bindkey '^[OB'  down-line-or-beginning-search

# ==============================================================================
# 7. PROMPT
# ==============================================================================
setopt prompt_subst
prompt='%F{green}%*%f %F{blue}%~%f %F{red}$(git_branch_name)%F{default}> '

# ==============================================================================
# 8. PLUGINS & TOOLS (Antigen, NVM, Bun, Kube)
# ==============================================================================
source ~/antigen.zsh
antigen bundle "MichaelAquilina/zsh-autoswitch-virtualenv"
antigen bundle djui/alias-tips
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zpm-zsh/autoenv
antigen bundle joshskidmore/zsh-fzf-history-search
antigen apply

# Manuella Plugins
[ -f ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# NVM
[ -s "$HOME/.nvm/nvm.sh" ] && source "$HOME/.nvm/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# Bun Completions
[ -s "/Users/ivolejon/.bun/_bun" ] && source "/Users/ivolejon/.bun/_bun"

# Kubernetes
if [ -f ~/.kube-config ]; then
  source ~/.kube-config
else
  echo "Skipping sourcing ~/.kube-config: File not found."
fi

# ==============================================================================
# 9. FUNCTIONS
# ==============================================================================
killport() {
  lsof -i tcp:$1 | awk 'NR>1 {print $2}' | xargs kill -9
}
toggle-theme() {
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
}
reload-zsh-config(){
    echo "Reloading zsh configuration..."
    source ~/.zshrc
    echo "Zsh configuration reloaded."
}
list-visited-branches(){
    git --no-pager reflog | grep "checkout: moving from" | awk '{print $NF}' | awk '!x[$0]++' | head -n 20 | tail -r
}
diff-parent() {
    # 1. Om argument skickades med, använd det, annars använd @{u}
    local target="$1"
    if [ -z "$target" ]; then
        target="@{u}"
    fi

    # 2. Validera att grenen faktiskt existerar
    if ! git rev-parse --verify "$target" >/dev/null 2>&1; then
        echo "Fel: Grenen '$target' hittades inte."
        return 1
    fi

    echo "Diffar mot: $target"
    git diff "$target"... --name-only
}

# ==============================================================================
# 10. ALIASES
# ==============================================================================
# Generella
alias c='clear'
alias ls='ls -G -1 -a --color'
alias r='reload-zsh-config'
alias config='zed ~/'
alias t='toggle-theme'
alias z='zed'
alias vim='nvim'
alias python='python3'
alias chown_to_me='sudo chown -R $(whoami) .'

# Verktyg & CLI
alias lg='lazygit'
alias bat='bat --style=plain'
alias fzf="fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}'"
alias rg="rg --no-ignore --hidden --colors 'match:fg:yellow' --colors 'path:fg:green'"
alias dozzle="docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 8090:8080 amir20/dozzle:latest"
alias oc="opencode"
alias k="kubecolor"

# PNPM & Projekt
alias p='pnpm'
alias pphost="pnpm -F host dev"
alias ppremote="pnpm -F nyheter remote"

# Git
alias gi="git init"
alias gs='git status'
alias status="git status -sbu"
alias glg='git log --graph --oneline --decorate --all'
alias hist="git log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short"
alias gco="git checkout"
alias gcob="git checkout -b"
alias ga="git add ."
alias gcm="git commit -m"
alias gc="git commit"
alias gpl="git pull"
alias gp="git push"
alias gm="git merge"
alias gst="git stash -u"
alias gstl="git stash list"
alias gsu='git stash -u'
alias gsp='git stash pop'
alias gsl="git stash list --pretty=format:'%gd: %Cred%h%Creset %Cgreen[%ar]%Creset %s'"
alias gdf='diff-parent'
alias cb='git rev-parse --abbrev-ref HEAD | pbcopy'
alias rr='git_browse'
alias reset='git reset --hard'
# Nedan för att lista branchen jag har besökt i stigande ordning
alias gb="list-visited-branches"

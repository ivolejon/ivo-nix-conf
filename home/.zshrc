# ==============================================================================
# 1. INITIALIZATION & SECRETS
# ==============================================================================
# NOTE: Functions and aliases are defined in home.nix initContent and shellAliases
# so they are always available. Only environment variables and sourcing stay here.

[ -f ~/.secrets ] && source ~/.secrets
[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"
[ -f ~/.dotnet.ef.commands ] && source ~/.dotnet.ef.commands # Sveriges Radio
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"       # Rust & Cargo

# ==============================================================================
# 2. ENVIRONMENT VARIABLES
# ==============================================================================
export VISUAL=hx
export EDITOR=hx
export KUBE_EDITOR=hx
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
# 7. PLUGINS & TOOLS (Antigen, NVM, Bun, Kube)
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

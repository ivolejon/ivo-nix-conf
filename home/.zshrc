# ==============================================================================
# 1. INITIALIZATION & SECRETS
# ==============================================================================
# NOTE: Functions and aliases are defined in home.nix initContent and shellAliases
# so they are always available. Only environment variables and sourcing stay here.

# Secrets live in home/.secrets.zsh, which is gitignored - copy
# home/.secrets.zsh.example on a new machine. Never put them in this file.
[[ -f "$HOME/.dotfiles/home/.secrets.zsh" ]] && source "$HOME/.dotfiles/home/.secrets.zsh"

# Source all .sh files from ~/.config/__misc
for misc_sh in ~/.config/__misc/*.sh(N); do
  source "$misc_sh"
done

[ -f "$HOME/.local/bin/env" ] && source "$HOME/.local/bin/env"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"       # Rust & Cargo

# ==============================================================================
# 2. ENVIRONMENT VARIABLES
# ==============================================================================
export VISUAL=hx
export EDITOR=hx
export KUBE_EDITOR=hx
export BUN_INSTALL="$HOME/.bun"
# No DOTNET_ROOT here: the dotnet SDKs come from Nix (see home.nix) and their
# wrappers already point at the store paths. Setting it by hand only shadows them.

# ==============================================================================
# 3. PATH CONSTRUCTION
# ==============================================================================
# Lägger till alla sökvägar systematiskt för att undvika rörig kod
# No /opt/homebrew entries here: Linux Homebrew lives in /home/linuxbrew and
# shell.nix puts it on PATH with `brew shellenv`.
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.aspire/bin:$PATH"
export PATH="$HOME/.pi/agent/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$PATH:$HOME/.rvm/bin" # RVM rekommenderar att ligga sist i PATH


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
# 7. RUNTIMES (Bun, Kubernetes)
# ==============================================================================
# No plugin manager here on purpose: starship owns the prompt and shell.nix
# keeps autosuggestion/syntaxHighlighting off, so there is nothing to load.
# ~/.config/__misc/*.sh is the hook for anything else you want sourced.
# nvm/NVM_DIR is loaded from ~/.zprofile instead of here: login shells read that
# one too, so background services see the same node as this terminal.
# ==============================================================================

# Bun Completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Kubernetes - optional, only loaded if you have created it
[ -f ~/.kube-config ] && source ~/.kube-config

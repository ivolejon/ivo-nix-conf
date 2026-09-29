# Sourced by every zsh - including non-interactive login shells (`zsh -lc`).
#
# nvm is loaded here and not in .zshrc on purpose: tools that launch outside a
# terminal (PI WEB's LaunchAgents, for example) run through a login shell and
# would otherwise get a different node/npm than your terminal does.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null

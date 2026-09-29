# Read by login shells - interactive terminals and non-interactive ones alike.
#
# nvm is loaded here and not in .zshrc on purpose: tools that start outside a
# terminal (a systemd user unit, or anything run through `zsh -lc`) would
# otherwise get a different node/npm than your terminal does.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" >/dev/null

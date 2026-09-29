#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# Run home-manager straight from its flake so this works even when the
# home-manager binary isn't installed in the profile yet.
# -b backup avoids clobbering existing dotfiles that home-manager refuses to
# overwrite (nvm's directory, a hand-made ~/.zprofile, ...).
# "linux" is the flake host label - if you renamed it, change it in flake.nix too.
nix run home-manager/release-26.05 -- switch -b backup --flake "$DIR"#linux
exec zsh

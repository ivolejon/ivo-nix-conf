#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# Run home-manager straight from its flake so this works even when the
# home-manager binary isn't installed in the profile yet.
nix run home-manager/release-26.05 -- switch -b backup --flake "$DIR"#linux
exec zsh

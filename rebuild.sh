#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# sudo resets PATH to a secure default that excludes /nix/.../bin, so
# darwin-rebuild (which lives under /run/current-system/sw/bin/ or similar)
# would not be found. Resolve the absolute path first and invoke that instead.
DARWIN_REBUILD="$(command -v darwin-rebuild)"
exec sudo "$DARWIN_REBUILD" switch --flake ~/.dotfiles#mac

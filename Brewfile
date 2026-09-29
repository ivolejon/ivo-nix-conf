# Homebrew packages on Linux.
#
# This file is the source of truth on this branch: home.nix runs
# `brew bundle --file=Brewfile` on every switch. It mirrors the `brews` list in
# brew.nix on main - casks are macOS-only and have no entry here.
#
# `brew bundle` installs and upgrades; it does NOT uninstall. To drop a
# package, delete the line here, run `brew uninstall <name>`, and re-run
# ./rebuild.sh. (main has cleanup = "zap" for that, through nix-darwin's
# homebrew module - no such module exists on Linux.)

# open-wispr comes from human37/open-wispr. Homebrew 4.x refuses to load
# formulae from an untrusted tap, so home.nix runs `brew trust` on this tap
# after every bundle install.
tap "human37/open-wispr"
tap "modem-dev/tap"

brew "awscli"
brew "bat"
brew "fd"
brew "gh"
brew "git-filter-repo"
brew "git-lfs"
brew "git-standup"
brew "helix"
brew "herdr"
brew "hunk"
brew "jq"
brew "lazygit"
brew "libaacs"
brew "libpq"
brew "libtool"
brew "open-wispr"
brew "opencode"
brew "ossp-uuid"
brew "python-setuptools"
brew "uv"
brew "zls"

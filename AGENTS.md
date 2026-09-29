# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- This is the `linux` branch: a standalone home-manager config that mirrors `main` (nix-darwin, macOS). There is no `configuration.nix` and no `brew.nix` here. When `main` changes a shared file (`home/`, `home.nix`, `shell.nix`, `alias.nix`, `AGENTS.md`, `README.md`), port the change instead of letting the branches drift. README.md ends with a list of which parts are Linux-specific.
- Homebrew is not managed by Nix on this branch: nix-homebrew has no Linux support. `Brewfile` is the source of truth, and `home.nix` runs `brew bundle` plus `brew trust --tap human37/open-wispr` on every activation. `brew bundle` does not uninstall anything, so dropping a package is a manual `brew uninstall`. Do not port main's `homebrew.onActivation.cleanup = "zap"` over from `brew.nix` - there is no such module here. On `main` that setting is intentional and documented in README.md.
- Do not put Node, npm, or npm-published CLIs into this Nix config. A global `npm i -g` under a Nix-managed Node.js mutates a read-only store path, and wrapping npm packages in `buildNpmPackage` drags in an ~800-package tree that must be re-resolved on every nixpkgs bump. Node comes from nvm, loaded in `home/.zprofile` (login shells included, so services see the same `node`); npm packages are installed with plain `npm i -g`. README has the commands.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.

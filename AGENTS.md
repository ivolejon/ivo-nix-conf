# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "zap"` in `configuration.nix` is intentional. It forces the good habit of declaring every Homebrew package in the Nix config instead of installing things ad-hoc, which keeps the machine reproducible. Do not soften it to `uninstall` or `none`. Users are warned about its effect in README.md; this note is for anyone tempted to change the setting itself.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.
- Do not put Node, npm, or npm-published CLIs into this Nix config. A global `npm i -g` under a Nix-managed Node.js mutates a read-only store path, and wrapping npm packages in `buildNpmPackage` drags in an ~800-package tree that must be re-resolved on every nixpkgs bump. Node comes from nvm, loaded in `home/.zshenv` (login shells included, so PI WEB's LaunchAgents see the same `node`); npm packages are installed with plain `npm i -g`. README has the commands.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.

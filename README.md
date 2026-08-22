# ivo-nix-conf

My personal Linux setup, managed with home-manager.
One repo, one command, and a fresh Linux machine ends up configured the same way every time.

## What you get

Running the switch builds:

- Nix user packages: ripgrep, fd, fzf, jq, lazygit, Helix (default editor), Node.js, Hack Nerd Font
- Shell (zsh with custom .zshrc and prompt)
- Editor configs (Helix, Zed, Neovim)
- Terminal (Ghostty tied to a theme)
- Agent configs (Codex and opencode share one AGENTS.md)

## Prerequisites

- **Linux** (x86_64 by default — change `system` in `flake.nix` to `aarch64-linux` for ARM).
- **Nix** must be installed using [Determinate Nix](https://docs.determinate.systems/).
  Do not use the official Nix installer, it will not work with this config.

## Fresh-machine setup

On a brand new Linux machine, from a bare clone of this repo:

```sh
git clone https://github.com/ivolejon/ivo-nix-conf.git
cd ivo-nix-conf
git checkout linux
```

Before you run it: review "Make it yours" below.
Change the username or CPU architecture if needed.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. **Installs [Determinate Nix](https://docs.determinate.systems/)**, if it isn't already installed.
   This is the recommended Nix installer for Linux and is required for this config.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual Linux username, and offers to fix it for you if they differ.
4. Runs the first `home-manager switch`.
   It fetches the `home-manager` tool from the release-26.05 branch, then applies this repo's locked flake config.

After that, `home-manager` exists and you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#homeConfigurations.linux.activationPackage --dry-run
```

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

## Adding a Nix package

Packages are declared in `home.nix`. To add a new package:

1. **Find the package name**: Search on [search.nixos.org](https://search.nixos.org/packages) for the exact attribute name.
2. **Add it to the `home.packages` list** in `home.nix`.
3. **Run `./rebuild.sh`** to apply.

**Example** - adding `bat`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  bat  # <-- added here
];
```

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your Linux username and offers to set it) OR change the single `user = "ivo"` line in `flake.nix`.
  Everything else (`home.nix`, home directory paths) is threaded from that one variable.
- **CPU architecture**, `system` in `flake.nix` (see Prerequisites above).

**Git identity:** this config deliberately does not set your git name or email.
Git will stop your first commit and tell you to set them (`git config --global user.name "Your Name"` and `git config --global user.email you@example.com`).
If you'd rather manage that declaratively, add this back to `home.nix` with your own identity:

```nix
programs.git = {
  enable = true;
  settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
};
```

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Codex and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `co` shell alias in `alias.nix` is a high-agency shortcut: `codex --full-auto`.
  It's convenient for me, but know what it does before you use it.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs and home-manager, and declares the `linux` user configuration.
- `home.nix` - user-level config: packages, fonts, and symlinks for editor/terminal configs.
- `shell.nix` - zsh, Starship prompt, editor env var, shell functions (imports `alias.nix`).
- `alias.nix` - all shell aliases, kept separate for readability.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place (Ghostty, Helix, Zed, Neovim, herdr, the shared `AGENTS.md`).

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/helix` straight at `home/.config/helix` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list.

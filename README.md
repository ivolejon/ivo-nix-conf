# ivo-nix-conf

My personal Linux setup, managed with home-manager.
One repo, one command, and a fresh Linux machine ends up configured the same way every time.

`main` is the same config for macOS (nix-darwin).
This branch, `linux`, is the standalone home-manager equivalent - same shell, same editor
configs, same agent policies, no nix-darwin and no system-level settings.

## What you get

Running the switch builds:

- Nix user packages: ripgrep, fd, fzf, jq, lazygit, Helix (default editor), Hack Nerd Font
- Homebrew packages from `Brewfile`: Ghostty CLI tools, herdr, OpenWispr, and more
- Node.js via [nvm](https://github.com/nvm-sh/nvm), not from Nix - see below
- Shell (zsh with custom .zshrc and prompt)
- Editor configs (Helix, Zed)
- Terminal (Ghostty tied to a theme)
- Agent configs (Codex and opencode share one AGENTS.md)

Homebrew itself is not a Nix package here: `home.nix` installs it if it is missing and then
runs `brew bundle --file=Brewfile` on every switch.

## Prerequisites

- Linux, x86_64 by default.
  ARM: change `system` in `flake.nix` to `aarch64-linux`.
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
4. Runs the first `home-manager switch` with `-b backup`.
   It fetches the `home-manager` tool from the release-26.05 branch, then applies this repo's locked flake config.
   `backup` keeps the files home-manager finds already there instead of failing on them.

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

Packages are declared in `home.packages` in `home.nix`. To add a new package:

1. **Find the package name**: Search on [search.nixos.org](https://search.nixos.org/packages) for the exact attribute name.
2. **Add to `home.packages`** in `home.nix`.
3. **Run `./rebuild.sh`** to apply.

**Example** - adding `bat`:

```nix
home.packages = with pkgs; [
  # ... existing packages ...
  bat  # <-- added here
];
```

## Adding a Homebrew package

Homebrew packages are declared in `Brewfile` on this branch (`brew.nix` is macOS-only, on `main`).
To add a new package:

1. **Find the package name**: Run `brew search <name>` to find the exact formula name.
   Casks are macOS-only and have no entry here.
2. **Add `brew "<name>"`** to `Brewfile`.
3. **Run `./rebuild.sh`** to apply - the bundle install is part of every switch.

**If it's from a custom tap**, add the tap first and trust it, because Homebrew 4.x refuses to
load formulae from an untrusted tap:

```
tap "owner/tap"
brew "some-formula"
```

Then add the same tap to the `brew-trust` activation step in `home.nix`, otherwise the bundle
install fails on the formula.

**Important**: unlike `main`, `brew bundle` here does **not** clean up.
It installs and upgrades what is listed, and leaves everything else alone.
To remove a package, delete its line from `Brewfile`, run `brew uninstall <name>`, and re-run `./rebuild.sh`.

## Node, npm and npm packages (deliberately not in Nix)

Node.js is **not** in `home.packages` here. It comes from nvm, installed per machine, and loaded in `home/.zprofile`:

```sh
# once, on a new machine
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
nvm install 24
node -v   # v24.21.0
npm -v    # 11.19.0
```

nvm owns the Node versions from there - nothing about Node is in this config, so switching versions is just nvm:

```sh
nvm install 22                # install another version
nvm use 22                    # use it in this shell
nvm alias default 24          # what new shells and services get
nvm ls                        # what is installed
```

The reason is reproducibility versus mutability: `npm i -g` under a Nix-managed Node.js writes straight into a read-only store path (it needs `sudo`, and `nix store verify` flags the result), and wrapping npm packages in `buildNpmPackage` turns a two-line install into a 800-package dependency tree that has to be re-resolved on every nixpkgs update. npm packages therefore stay npm packages:

```sh
npm install -g @jmfederico/pi-web --allow-scripts=node-pty
pi-web install
```

`~/.zprofile` (not `~/.zshrc`) is where nvm is loaded, because non-interactive login shells
(`zsh -lc`, which is what a systemd user unit or a `command -l` script gets) would otherwise
end up with a different `node` than your terminal. `~/.zprofile` is symlinked from
`home/.zprofile` by `home.nix`.

Do not move that into `~/.zshenv` either: home-manager's session variables are sourced from
there, and mixing the two makes the activation order depend on which file a given shell
happens to read first. Keeping nvm in its own file makes the order explicit.

## Docker

Docker is **not** in this config, and there is no `docker-desktop` in nixpkgs for Linux either - the app is proprietary and ships as a `.deb`, so it cannot come from Nix. Docker Desktop for Linux also cannot be managed by this config, only installed by hand.

The `docker` CLI and its zsh completion, on the other hand, are handled here, because Docker is easy to end up with a half-working shell setup:

- `home/.zprofile` puts `~/.docker/bin` on `PATH` (guarded by `[ -d ... ]`). Docker Desktop does not add its CLI there; that directory only exists in environments that happen to inherit it, so a terminal started by the desktop session has no `docker` at all without this.
- `home.nix` has a `docker-completions` activation step that writes `~/.docker/completions/_docker` from `docker completion zsh`, regenerated whenever the `docker` binary is newer than the completion. It looks for Docker Desktop's binary, the distro's, docker.com's repo, snap and Homebrew, in that order, and does nothing when there is no docker installed.
- `home/.zprofile` also puts `~/.docker/completions` on `fpath`, exported so tmux panes and `zsh -c` inherit it.

Both `.zprofile` lines are there rather than in `.zshrc` because a non-interactive login shell (`zsh -lc`, which is what Docker Desktop's own completion check uses) reads `.zshenv` and `.zprofile` but not `.zshrc`.

If you would rather have Docker from Nix: add `docker` and `docker-compose` to `home.packages`. Its `_docker` lands in the profile's `site-functions`, which home-manager already puts on `fpath`, so the completion works with no activation step - but the activation step above still applies to the binaries it finds in the distro and Docker Desktop, and `home.nix` cannot create the systemd unit for `dockerd`. That is NixOS territory, not home-manager.

To check what a shell sees:

```sh
zsh -lc 'command -v docker; print -rl -- $^fpath/_docker(.N)'
```

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your Linux username and offers to set it) OR change the single `user = "ivo"` line in `flake.nix`.
  Everything else (`home.nix`, home directory paths) is threaded from that one variable.
- **CPU architecture**, `system` in `flake.nix` (see Prerequisites above).
- **Host label** `"linux"`, in two places: `flake.nix` (the `homeConfigurations."linux"` name) and `rebuild.sh` / `bootstrap.sh` (the `#linux` at the end of the flake reference).
  All of them have to match.

**Secrets:** none of this repo is secret, so per-machine values live in `home/.secrets.zsh`, which is gitignored.
Copy the template on a new machine - `home/.zshrc` sources it for you:

```sh
cp home/.secrets.zsh.example home/.secrets.zsh
```

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

**About `herdr`:** it's in the `Brewfile`.
It's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine.
If you don't use it, just remove it from `Brewfile` in your copy.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Codex and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `co` shell alias in `alias.nix` is a high-agency shortcut: `codex --full-auto`.
  It's convenient for me, but know what it does before you use it.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs and home-manager, and declares the `linux` user configuration.
- `Brewfile` - the Homebrew package list, applied by `home.nix` on every switch.
- `home.nix` - user-level config: packages, fonts, Homebrew activation, and symlinks for editor/terminal configs.
- `shell.nix` - zsh, Starship prompt, editor env var, shell functions (imports `alias.nix`).
- `alias.nix` - all shell aliases, kept separate for readability.
- `bootstrap.sh` - one-time setup from a bare clone.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place (Ghostty, Helix, Zed, herdr, the shared `AGENTS.md`).

Files that only exist on `main`: `configuration.nix` (macOS system settings) and `brew.nix`
(the nix-darwin Homebrew module, replaced by `Brewfile` here).

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/helix` straight at `home/.config/helix` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list.

## Staying in sync with `main`

`main` and `linux` share `home/`, `shell.nix`, `alias.nix`, `home.nix`, `AGENTS.md` and most of `README.md`.
When `main` changes one of those, port the change here - or rebase this branch onto `main` and re-apply the Linux-specific bits.
The Linux-specific parts are: `flake.nix` (no nix-darwin, `system` instead of a host config), `Brewfile`
(Homebrew without the Nix module), `bootstrap.sh` / `rebuild.sh` (home-manager instead of darwin-rebuild),
and the platform calls in `shell.nix` / `alias.nix` / `home/.zshrc` (`xdg-open`, `tac`, GNU `ls`, `wl-copy`).

# ivo-nix-conf

My personal Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

## What you get

Running the switch builds:

- System settings (dark mode, key repeat, dock, Finder, trackpad)
- Homebrew apps: Ghostty terminal, herdr CLI tool, OpenWispr, and more
- Nix user packages: ripgrep, fd, fzf, jq, lazygit, Helix (default editor), Hack Nerd Font
- Node.js via [nvm](https://github.com/nvm-sh/nvm), not from Nix - see below
- Shell (zsh with custom .zshrc and prompt)
- Editor configs (Helix, Zed, Neovim)
- Terminal (Ghostty tied to a theme)
- Agent configs (Codex and opencode share one AGENTS.md)

## Prerequisites

- Apple Silicon Mac, by default.
- Intel Mac: change one line.
  In `configuration.nix`, set `nixpkgs.hostPlatform = "x86_64-darwin";` (the comment right there tells you the same thing).
- **Nix** must be installed using [Determinate Nix](https://docs.determinate.systems/).
  Do not use the official Nix installer, it will not work with this config.

## Fresh-machine setup

On a brand new Mac, from a bare clone of this repo:

```sh
git clone https://github.com/ivolejon/ivo-nix-conf.git
cd ivo-nix-conf
```

Before you run it: review "Make it yours" below.
Change the host label or CPU architecture if needed, and read the Homebrew cleanup warning.
`bootstrap.sh` applies the config to your machine, so do this first.

```sh
./bootstrap.sh
```

`bootstrap.sh` does four things, in order:

1. **Installs [Determinate Nix](https://docs.determinate.systems/)**, if it isn't already installed.
   This is the recommended Nix installer for macOS and is required for this config.
2. Symlinks this repo to `~/.dotfiles`.
   This has to happen before the first build, because `home.nix` points at config files through `~/.dotfiles`.
3. Checks the `user` configured in `flake.nix` against your actual macOS username, and offers to fix it for you if they differ.
4. Runs the first `darwin-rebuild switch`.
   It fetches the `darwin-rebuild` tool from the nix-darwin 26.05 release branch, then applies this repo's locked flake config.

After that, `darwin-rebuild` exists and you're on the normal workflow below.

### Validate without applying

Once Nix is installed (`bootstrap.sh` step 1 handles that), you can check that the config builds without touching your system - handy when you have edited something:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

If you renamed the host label in "Make it yours", substitute your label for `mac` in these commands.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

That's it.
No separate build-and-copy step.

## Adding a Homebrew package

Homebrew packages are declared in `brew.nix`. To add a new package:

1. **Find the package name**: Run `brew search <name>` to find the exact formula or cask name.
2. **Add to the right list** in `brew.nix`:
   - CLI tools go in `homebrew.brews`
   - GUI apps go in `homebrew.casks`
3. **Run `./rebuild.sh`** to apply.

**Example** - adding `bat` (a CLI tool) and `zed` (an editor app):

```nix
homebrew = {
  # ... existing config ...
  brews = [
    # ... existing brews ...
    "bat"  # <-- added here
  ];
  casks = [
    # ... existing casks ...
    "zed"  # <-- added here
  ];
};
```

**If it's from a custom tap**, add the tap first in `homebrew.taps`:

```nix
homebrew = {
  taps = [
    "owner/tap"  # example tap
  ];
  brews = [
    "some-formula"  # from owner/tap
  ];
};
```

**Important**: `cleanup = "zap"` is enabled, so anything not in these lists gets uninstalled on rebuild.

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

Because the default version is what login shells get, a `nvm install` of a new default is also a PI WEB upgrade target: run `pi-web install` again afterwards so its services point at the new `node`.

The reason is reproducibility versus mutability: `npm i -g` under a Nix-managed Node.js writes straight into a read-only store path (it needs `sudo`, and `nix store verify` flags the result), and wrapping npm packages in `buildNpmPackage` turns a two-line install into a 800-package dependency tree that has to be re-resolved on every nixpkgs update. npm packages therefore stay npm packages:

```sh
npm install -g @jmfederico/pi-web --allow-scripts=node-pty
pi-web install
```

`~/.zprofile` (not `~/.zshrc`) is where nvm is loaded, because PI WEB's LaunchAgents run through a non-interactive login shell - `zsh -lc` - and would otherwise get a different `node` than your terminal. `~/.zprofile` is symlinked from `home/.zprofile` by `home.nix`.

Do not move that into `~/.zshenv`: nix-darwin writes `~/.zshenv` itself (it sources the Home Manager session variables from there), and declaring it in `home.file` makes the activation fail with `Error installing file './.zshenv' outside $HOME`.

**PI WEB** ([pi-web.dev](https://pi-web.dev)) is the browser UI and session daemon for `pi`, listening on <http://127.0.0.1:8504>. Two things to know:

- After installing, run the upstream fix for node-pty's macOS spawn-helper (it ships without the executable bit):
  ```sh
  chmod +x "$(npm prefix -g)"/lib/node_modules/@jmfederico/pi-web/node_modules/node-pty/prebuilds/*/spawn-helper
  ```
  `pi-web doctor` tells you the same thing.
- Its services are per-user LaunchAgents installed by `pi-web install`, not by Nix. After a `nvm install` of a different Node version, run `pi-web install` again so the services point at the new `node`.

## Docker Desktop

Docker Desktop is **not** in this config, and it can't be: there is no `docker-desktop` in nixpkgs for `aarch64-darwin` (or `x86_64-darwin`) because the app is proprietary and ships as a `.app`, not as a derivation.
Install it from [docker.com](https://docs.docker.com/desktop/setup/install/mac-install/) or, if you want it managed declaratively, add the `docker-desktop` cask to `brew.nix` - Homebrew has it (4.93.0, `auto_updates`).
It's deliberately not in `brew.nix` here, because two updaters fighting over the same app is worse than one manual install.

The zsh completion **is** in the config, because Docker Desktop complains without it:

- `home/.zprofile` puts `~/.docker/bin` on `PATH` and `~/.docker/completions` on `fpath`. Docker Desktop does neither for us: `~/.docker/bin` is only on `PATH` in environments that happen to inherit it, so a terminal started from the Dock has no `docker` at all. The `PATH` line is guarded by `[ -d ... ]`, so a machine without Docker Desktop keeps a clean PATH.
  Both lines are in `.zprofile` rather than `.zshrc` for the same reason - a `zsh -lc` check (Docker Desktop's own completion check is one) reads `.zshenv` and `.zprofile` but not `.zshrc`, and `.zshenv` is written by nix-darwin, not by us.
- `home.nix` has a `docker-completions` activation step that writes `~/.docker/completions/_docker` from `docker completion zsh`, regenerated whenever the Docker Desktop binary is newer than the completion (so it self-heals after a Docker update). It does nothing when Docker Desktop is not installed.

To check what Docker sees, run the same thing it runs:

```sh
zsh -lc 'print -rl -- $^fpath/_docker(.N)'
```

## Make it yours

This repo is mine.
If you clone it, review these before you run `bootstrap.sh`:

- **Username**: run `./bootstrap.sh` (it detects your macOS username and offers to set it) OR change the single `user = "ivo"` line in `flake.nix`.
  Everything else (`configuration.nix`, `home.nix`, home directory paths) is threaded from that one variable.
- **Host label** `"mac"`, in three places: `flake.nix` (the `darwinConfigurations."mac"` name), `rebuild.sh:5` (the `#mac` at the end of the flake reference), and `bootstrap.sh`'s first-switch command (also `#mac`).
  All three have to match.
- **CPU architecture**, `hostPlatform` in `configuration.nix` (see Prerequisites above).

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

**Homebrew cleanup warning:** `brew.nix` sets `homebrew.onActivation.cleanup = "zap"`.
That means every time you switch, Homebrew removes any package or cask on your machine that isn't listed in the `brews` and `casks` arrays in `brew.nix`.
If you already have Homebrew stuff installed that isn't in that list, the first switch will uninstall it.
Read through `brews` and `casks` before you run `bootstrap.sh` or `rebuild.sh` for the first time, and add anything you want to keep.

**About `herdr`:** it's in the `brews` list.
It's a real public Homebrew formula (`brew info herdr` finds it in homebrew-core, no tap needed), so it will install fine.
If you don't use it, just remove it from `brews` in your copy.

**Heads-up:**

- `home/AGENTS.md` is my personal agent policy, and `home.nix` installs it for Codex and opencode.
  If you clone this repo, you'd silently inherit my agent instructions - edit or delete `home/AGENTS.md` if you don't want that.
- The `co` shell alias in `alias.nix` is a high-agency shortcut: `codex --full-auto`.
  It's convenient for me, but know what it does before you use it.

## Repo tour

- `flake.nix` - the entry point.
  Wires up nixpkgs, nix-darwin, home-manager, and nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system-level config: macOS defaults, Nix settings.
- `brew.nix` - Homebrew config: taps, brews, casks, cleanup policy.
- `home.nix` - user-level config: packages, fonts, and symlinks for editor/terminal configs.
- `shell.nix` - zsh, Starship prompt, editor env var, shell functions (imports `alias.nix`).
- `alias.nix` - all shell aliases, kept separate for readability.
- `rebuild.sh` - re-applies the config after the first switch.
  Run this every time you make a change.
- `home/` - the actual config files that get symlinked into place (Ghostty, Helix, Zed, Neovim, herdr, the shared `AGENTS.md`).

## How the symlinks work

The files under `home/` are the real files - editing them here is editing your live config, no rebuild needed to see the change in your editor.
`home.nix` uses `mkOutOfStoreSymlink` to point paths like `~/.config/helix` straight at `home/.config/helix` in this repo, so the two never drift out of sync.
You only run `./rebuild.sh` when you change something that isn't just a symlinked file, like a package list or a system default.


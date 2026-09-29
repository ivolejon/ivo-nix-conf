{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  imports = [ ./shell.nix ];

  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    helix
    # nodejs is NOT in this list on purpose: node/npm come from nvm (see
    # ~/.zprofile), so `npm i -g` never mutates a read-only store path.
    # dotnet (both SDKs combined into one package)
    (dotnetCorePackages.combinePackages [
      dotnetCorePackages.sdk_9_0
      dotnetCorePackages.sdk_10_0
    ])
    # screenshot tool
    flameshot
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;

  # Docker Desktop's zsh completion. Its own check (Settings -> "Configure shell
  # completions") runs `zsh -lc` and looks for _docker in fpath, which is why
  # home/.zprofile puts ~/.docker/completions on fpath - ~/.zshrc is not read
  # by that check, and ~/.zshenv belongs to nix-darwin.
  # The completion is `docker completion zsh`, so it has to come from the
  # Docker Desktop that is actually installed; it cannot be a tracked file.
  # Regenerated whenever the binary is newer than the completion, which is what
  # makes it survive Docker Desktop updating itself. Skipped when Docker Desktop
  # is not installed at all.
  home.activation.docker-completions = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    completion_dir="$HOME/.docker/completions"
    # The activation PATH is nix store bins only (coreutils, findutils, ...), so
    # the ~/.docker/bin that Docker Desktop adds to the GUI session's PATH is not
    # visible here. Check the places the binary actually lives.
    for docker_bin in \
      "$HOME/.docker/bin/docker" \
      /Applications/Docker.app/Contents/Resources/bin/docker \
      /opt/homebrew/bin/docker
    do
      [ -x "$docker_bin" ] || continue
      mkdir -p "$completion_dir"
      if [ ! -f "$completion_dir/_docker" ] || [ "$docker_bin" -nt "$completion_dir/_docker" ]; then
        echo "Generating Docker zsh completion in $completion_dir"
        if "$docker_bin" completion zsh > "$completion_dir/_docker.tmp"; then
          mv "$completion_dir/_docker.tmp" "$completion_dir/_docker"
        else
          rm -f "$completion_dir/_docker.tmp"
        fi
      fi
      break
    done
  '';

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/zed".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/zed";
  # Ghostty on macOS checks ~/Library/Application Support/com.mitchellh.ghostty/
  # before ~/.config/ghostty/, so we symlink there instead.
  home.file."Library/Application Support/com.mitchellh.ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  # Read by every login shell, including the non-interactive ones PI WEB's
  # LaunchAgents use. Home for the nvm setup, which is why it is not in .zshrc.
  # ~/.zshenv is not an option: nix-darwin writes that one itself.
  home.file.".zprofile".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zprofile";
  home.file.".config/helix".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/helix";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  # Git diff/pager setup, kept out of ~/.gitconfig so it is reproducible.
  # Git reads this file too; ~/.gitconfig still wins for anything it sets,
  # which is where the git identity deliberately stays (see README).
  # Written as a plain file rather than programs.git on purpose: enabling that
  # module would also install nixpkgs git and shadow the system/brew one.
  home.file.".config/git/config".text = ''
    [core]
    	pager = hunk pager
    [diff]
    	tool = hunk
    [difftool]
    	prompt = false
    [difftool "hunk"]
    	cmd = hunk difftool \"$LOCAL\" \"$REMOTE\" \"$MERGED\"
  '';
}

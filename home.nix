{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  imports = [ ./shell.nix ];

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.11";

  # Install Homebrew on Linux if missing, and keep brew packages in sync.
  home.activation = {
    install-homebrew = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        $DRY_RUN_CMD echo "Installing Homebrew for Linux..."
        # HM activation runs with a PATH of only nix store bins, so the
        # installer can't find system tools like ldd. Prepend /usr/bin:/bin.
        $DRY_RUN_CMD env NONINTERACTIVE=1 PATH=/usr/bin:/bin:"$PATH" ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';
    brew-bundle = config.lib.dag.entryAfter [ "install-homebrew" ] ''
      if [ -f /home/linuxbrew/.linuxbrew/bin/brew ] && [ -f ${dotfiles}/Brewfile ]; then
        $DRY_RUN_CMD /home/linuxbrew/.linuxbrew/bin/brew bundle --file=${dotfiles}/Brewfile
      fi
    '';
  };

  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    helix
    # nodejs and npm
    nodejs
    # dotnet (both SDKs combined into one package)
    (dotnetCorePackages.combinePackages [
      dotnetCorePackages.sdk_9_0
      dotnetCorePackages.sdk_10_0
    ])
    # screenshot tool
    flameshot
    # wayland clipboard (used by the cb alias)
    wl-clipboard
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/zed".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/zed";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
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
  # module would also install nixpkgs git and shadow the system one.
  # hunk itself comes from the Brewfile.
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

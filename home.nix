{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  brew = "/home/linuxbrew/.linuxbrew/bin/brew";
in

{
  imports = [ ./shell.nix ];

  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.stateVersion = "24.11";

  # Homebrew on Linux is not a Nix package here, and nix-homebrew has no Linux
  # support. So install it if it is missing, then apply the Brewfile. Order
  # matters and is expressed with dag entries:
  #   install-homebrew -> brew-bundle (adds the taps) -> brew-trust.
  home.activation = {
    install-homebrew = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f ${brew} ]; then
        $DRY_RUN_CMD echo "Installing Homebrew for Linux..."
        # HM activation runs with a PATH of only nix store bins, so the
        # installer can't find system tools like ldd. Prepend /usr/bin:/bin.
        $DRY_RUN_CMD env NONINTERACTIVE=1 PATH=/usr/bin:/bin:"$PATH" ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';
    brew-bundle = config.lib.dag.entryAfter [ "install-homebrew" ] ''
      if [ -x ${brew} ] && [ -f ${dotfiles}/Brewfile ]; then
        $DRY_RUN_CMD ${brew} bundle --file=${dotfiles}/Brewfile
      fi
    '';
    # Homebrew 4.x refuses to load formulae from untrusted third-party taps,
    # and open-wispr comes from human37/open-wispr. The trust entry has to be
    # written after the bundle install, which is what adds the tap.
    # Trusting the whole tap (rather than one formula) is the upstream
    # recommendation only if you accept everything it ships, present and future.
    # Entries are added on every activation and never removed - use
    # `brew untrust` for that.
    brew-trust = config.lib.dag.entryAfter [ "brew-bundle" ] ''
      if [ -x ${brew} ]; then
        $DRY_RUN_CMD ${brew} trust --tap human37/open-wispr
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
    # wayland clipboard (used by the cb alias)
    wl-clipboard
    # xdg-open, used by the rr alias
    xdg-utils
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/zed".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/zed";
  # Unlike on macOS, Ghostty reads ~/.config/ghostty/ on Linux, so the plain
  # path is right here - no Library/Application Support detour.
  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  # Read by every login shell, including the non-interactive ones a systemd
  # user unit gets. Home for the nvm setup, which is why it is not in .zshrc.
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
  # module would also install nixpkgs git and shadow the distro one.
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

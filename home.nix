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

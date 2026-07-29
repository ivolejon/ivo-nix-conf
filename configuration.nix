{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = false;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = false;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = false;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "derailed/k9s"
      "hashicorp/tap"
      "modem-dev/tap"
    ];
    brews = [
      "awscli"
      "bat"
      "difftastic"
      "fd"
      "gh"
      "git-filter-repo"
      "git-lfs"
      "git-standup"
      "helix"
      "herdr"
      "jq"
      "k9s"
      "kubecolor"
      "kubectx"
      "lazygit"
      "libaacs"
      "libpq"
      "libtool"
      "neovim"
      "opencode"
      "ossp-uuid"
      "postgresql@18"
      "powershell"
      "python-setuptools"
      "uv"
      "vault"
      "zls"
    ];
    casks = [
      "copilot-cli"
      "gcloud-cli"
      "ghostty"
      "wine-stable"
    ];
  };
}

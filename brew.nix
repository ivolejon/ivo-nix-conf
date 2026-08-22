{ user, ... }:

{
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
    brews = [
      "awscli"
      "bat"
      "fd"
      "gh"
      "git-filter-repo"
      "git-lfs"
      "git-standup"
      "helix"
      "herdr"
      "jq"
      "kubecolor"
      "kubectx"
      "lazygit"
      "libaacs"
      "libpq"
      "libtool"
      "neovim"
      "opencode"
      "python-setuptools"
      "uv"
      "zls"
    ];
    casks = [
      "copilot-cli"
      "gcloud-cli"
      "ghostty"
      "wine-stable"
      "zed"
    ];
  };
}

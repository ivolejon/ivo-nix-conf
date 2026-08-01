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
    taps = [
      "derailed/k9s"
      "hashicorp/tap"
      "human37/open-wispr"
      "modem-dev/tap"
    ];
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
      "python-setuptools"
      "uv"
      "vault"
      "zls"
      "hunk"
      "open-wispr"
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

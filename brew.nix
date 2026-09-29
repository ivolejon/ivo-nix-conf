{ user, ... }:

{
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
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
      "lazygit"
      "libaacs"
      "libpq"
      "libtool"
      "opencode"
      "ossp-uuid"
      "python-setuptools"
      "uv"
      "zls"
      "hunk"
      "open-wispr"
    ];
    casks = [
      "copilot-cli"
      "gcloud-cli"
      "ghostty"
      "zed"
    ];
  };
}

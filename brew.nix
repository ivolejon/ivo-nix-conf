{ user, ... }:

{
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
    # Homebrew 4.x refuses to load formulae from untrusted third-party taps.
    # Trusting the whole tap (rather than one formula) is the upstream
    # recommendation only if you accept everything it ships, present and future.
    # Entries are added on every activation and never removed - use
    # `brew untrust` for that.
    trust.taps = [ "human37/open-wispr" ];
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

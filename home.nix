{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
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
    neovim
    helix
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;

  programs.zsh = {
    enable = true;
    # All configuration lives in ~/.zshrc (sourced below) so these stay off
    # to avoid double-loading plugins, duplicate aliases, or competing prompts.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;
    initContent = ''
      function git_branch_name() {
        local branch=$(git symbolic-ref HEAD 2> /dev/null | sed 's/refs\/heads\///')
        if [[ -n "$branch" ]]; then
          echo "- ($branch)"
        fi
      }

      function git_since() {
        git log --merges --since=$1 --pretty=format:"%h - %s (%cd)" --date=short
      }

      function commit() {
        local green='\033[0;32m'
        local reset='\033[0m'
        git add .
        echo -n "Enter a commit message: "
        echo -e "$green"
        read commit_message
        echo -e "$reset"
        if [ -n "$commit_message" ]; then
          git commit -m "$commit_message"
          git push
        fi
      }

      function git_browse() {
        local gbrowsevar=$(git config --get remote.origin.url)
        printf "%s" "$gbrowsevar"
        open "$gbrowsevar"
      }

      function killport() {
        lsof -i tcp:$1 | awk 'NR>1 {print $2}' | xargs kill -9
      }

      function toggle-theme() {
        osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
      }

      function reload-zsh-config() {
        echo "Reloading zsh configuration..."
        source ~/.zshrc
        echo "Zsh configuration reloaded."
      }

      function list-visited-branches() {
        git --no-pager reflog | grep "checkout: moving from" | awk '{print $NF}' | awk '!x[$0]++' | head -n 20 | tail -r
      }

      function diff-parent() {
        local target="$1"
        if [ -z "$target" ]; then
          target="@{u}"
        fi
        if ! git rev-parse --verify "$target" >/dev/null 2>&1; then
          echo "Fel: Grenen '$target' hittades inte."
          return 1
        fi
        echo "Diffar mot: $target"
        git diff "$target"... --name-only
      }

      source "${dotfiles}/home/.zshrc"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      co = "codex --full-auto";
      c = "clear";
      ls = "ls -G -1 -a --color";
      r = "reload-zsh-config";
      config = "zed ~/";
      t = "toggle-theme";
      z = "zed";
      vim = "nvim";
      python = "python3";
      chown_to_me = "sudo chown -R $(whoami) .";
      lg = "lazygit";
      bat = "bat --style=plain";
      fzf = "fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}'";
      rg = "rg --no-ignore --hidden --colors 'match:fg:yellow' --colors 'path:fg:green'";
      dozzle = "docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p 8090:8080 amir20/dozzle:latest";
      oc = "opencode";
      k = "kubecolor";
      p = "pnpm";
      pphost = "pnpm -F host dev";
      ppremote = "pnpm -F nyheter remote";
      gi = "git init";
      gs = "git status";
      status = "git status -sbu";
      glg = "git log --graph --oneline --decorate --all";
      hist = "git log --pretty=format:'%C(yellow)[%ad]%C(reset) %C(green)[%h]%C(reset) | %C(red)%s %C(bold red){{%an}}%C(reset) %C(blue)%d%C(reset)' --graph --date=short";
      gco = "git checkout";
      gcob = "git checkout -b";
      ga = "git add .";
      gcm = "git commit -m";
      gc = "git commit";
      gpl = "git pull";
      gp = "git push";
      gm = "git merge";
      gst = "git stash -u";
      gstl = "git stash list";
      gsu = "git stash -u";
      gsp = "git stash pop";
      gsl = "git stash list --pretty=format:'%gd: %Cred%h%Creset %Cgreen[%ar]%Creset %s'";
      gdf = "diff-parent";
      cb = "git rev-parse --abbrev-ref HEAD | pbcopy";
      rr = "git_browse";
      reset = "git reset --hard";
      gb = "list-visited-branches";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory[ on ](white)$git_branch $character";
      directory = {
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
      };
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  # Ghostty on macOS checks ~/Library/Application Support/com.mitchellh.ghostty/
  # before ~/.config/ghostty/, so we symlink there instead.
  home.file."Library/Application Support/com.mitchellh.ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
  home.file.".config/helix".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/helix";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}

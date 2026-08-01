{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  imports = [ ./alias.nix ];

  home.sessionVariables.EDITOR = "hx";

  # Silence "Last login" message in new terminal tabs
  home.file.".hushlogin".text = "";

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
}

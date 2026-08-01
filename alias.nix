{ config, pkgs, user, ... }:

{
  programs.zsh.shellAliases = {
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
    vim = "hx";
    python = "python3";
    chown_to_me = "sudo chown -R $(whoami) .";
    lg = "lazygit";
    bat = "bat --style=plain";
    fzf = "fzf --preview 'bat --style=numbers --color=always --line-range=:500 {}'";
    rg = "rg --no-ignore --hidden --colors 'match:fg:yellow' --colors 'path:fg:green'";
    oc = "opencode";
    p = "pnpm";
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
    cb = ''branch=$(git rev-parse --abbrev-ref HEAD); echo "Copied $branch to clipboard"; echo "$branch" | pbcopy'';
    rr = "git_browse";
    reset = "git reset --hard";
    gb = "list-visited-branches";
  };
}

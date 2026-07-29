function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | sed -e 's/refs\/heads\///')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '- ('$branch')'
  fi
}
# . "$HOME/.cargo/env"


function git_since() {
    git log --merges --since=$1 --pretty=format:"%h - %s (%cd)" --date=short
}

function commit {
    green='\033[0;32m'
    reset='\033[0m'
    git add .

    echo -n "Enter a commit message: "
    echo -e $green
    read commit_message
    echo -e $reset

    if [ -n "$commit_message" ]; then
        git commit -m "$commit_message"
        git push
    fi
}

function git_browse {
    gbrowsevar=$(git config --get remote.origin.url)
    printf "${gbrowsevar}"
    open $gbrowsevar
}
# uv
export PATH="/Users/ivolejon/.local/bin:$PATH"

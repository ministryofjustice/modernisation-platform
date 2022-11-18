#/bin/bash
set -Eeo pipefail

main_directory="modernisation-platform-repos"

add () {
  git -C "$1" add .
}

commit () {
  git -C "$1" commit -m "$2"
}

get_mp_repos () {
	gh search repos --owner=ministryofjustice --match=name modernisation-platform --json=name | jq '.[].name' --raw-output
}

git_clone () {
	git clone git@github.com:ministryofjustice/$1.git $main_directory/$1
}

clone_mp_repos () {
  mkdir $main_directory
  mp_repos=$(get_mp_repos)
  
  for repo in $mp_repos; do
	  echo "Cloning for $repo"
	  git_clone $repo
  done
}

status () {
  git -C "$1" status
}

diff () {
  git -C "$1" diff
}

update_main () {
  git -C "$1" checkout main && git -C "$1" pull
}

stash () {
  git -C "$1" stash
}

create_branch () {
  git -C "$1" checkout -b "$2"
}

push () {
  git -C "$1" push
}

create_pr () {
  (cd "$1"; gh pr create --fill)
  sleep 1 # Needed otherwise submitted too quickly error when itterating 
}

iterate_mp_repos () {
  command=$1
  argument="$2"
  for dir in ./$main_directory/*; do
      if [ -d "$dir" ]; then
          echo "Running for $dir"
          echo "$command $dir $argument"
          $command $dir "$argument"
      fi
  done
}

case "$1" in
  "clone")
    clone_mp_repos
    ;;
  "update")
    iterate_mp_repos update_main
    ;;
  "branch")
    iterate_mp_repos create_branch "$2"
    ;;
  "add")
    iterate_mp_repos add 
    ;;
  "stash")
    iterate_mp_repos stash 
    ;;
  "status")
    iterate_mp_repos status 
    ;;
  "diff")
    iterate_mp_repos diff 
    ;;
  "commit")
    iterate_mp_repos commit "$2"
    ;;
  "push")
    iterate_mp_repos push
    ;;
  "pr")
    iterate_mp_repos create_pr
    ;;
  *)
    echo ""
    echo "********************************** Usage **********************************"
    echo "Install git and the GitHub CLI - https://cli.github.com/, configure/authenticate to GitHub"
    echo "Copy this script to the location where you want the $main_directory folder to be created and run from there"
    echo "First run the clone command to download all of the MP repos in to the new $main_directory folder"
    echo "Then open your IDE on that folder and make find/replace changes across all the files"
    echo "Example of how to copy a file into a certain subfolder:"
    echo "find . -name 'workflows' -type d -exec cp scorecards.yml {} \;"
    echo "Once you have made your changes use the commands below to iterate through each repo in the $main_directory folder"
    echo "If you wish to exclude a repo, move it outside the $main_directory folder or delete it"
    echo "NOTE: Always run the script from the location you originally saved it"
    echo "______________________________________________________________________________________________"
    echo "multi-repo-git.sh clone | Clones the Modernisation Platforms repos into a newly created folder"
    echo "multi-repo-git.sh update | switch back to main and pull"
    echo "multi-repo-git.sh branch <branch name> | Creates a new local branch in each repo folder"
    echo "multi-repo-git.sh add | runs add . in each repo folder to stage changes"
    echo "multi-repo-git.sh status | runs status in each repo folder."
    echo "multi-repo-git.sh stash | runs stash in each repo folder."
    echo "multi-repo-git.sh diff | runs diff in each repo folder."
    echo "multi-repo-git.sh commit <\"Commit message\"> | Commits staged changes in each repo folder"
    echo "multi-repo-git.sh push | pushes the current branch to the remote"
    echo "multi-repo-git.sh pr | Creates a PR on github, autofills from branch name and commit message"
    exit 1
    ;;
esac

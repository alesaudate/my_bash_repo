#!/bin/bash

#!/usr/bin/env bash

# VARIABLES SETUP
export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

export WORKSPACE=~/workspace
export PATH=$PATH:$WORKSPACE/docker-recipes

# GIT FUNCTIONS
git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# TERMINAL PROMPT
PS1="\[\e[0;93m\]\u\[\e[m\]"    # username
PS1+=" "    # space
PS1+="\[\e[0;95m\]\W\[\e[m\]"    # current directory
PS1+="\[\e[0;92m\]\$(git_branch)\[\e[m\]"    # current branch
PS1+=" "    # space
PS1+=">> "    # end prompt
export PS1;
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# MY CUSTOM ALIASES

##################
### NAVIGATION ###
##################

alias ll="ls -la"
alias ..="cd .."
alias dc="cd .."
alias workspace="cd $WORKSPACE"

root() {
        local FILE_TO_LOOK_FOR=build.gradle
        local FILE_TO_LOOK_FOR_KTS=$FILE_TO_LOOK_FOR.kts
        local FILE_TO_LOOK_FOR_POM=pom.xml
        local WORKING_DIR=$(pwd)
        local INITIAL_FOLDER=$(pwd)


        while [ ! -f $FILE_TO_LOOK_FOR ] && [ ! -f $FILE_TO_LOOK_FOR_KTS ] && [ ! -f $FILE_TO_LOOK_FOR_POM ]; do
           cd ..
           WORKING_DIR=$(pwd)
           if [ $WORKING_DIR="/" ]; then
                   echo "No $FILE_TO_LOOK_FOR found"
                   cd $INITIAL_FOLDER
                   return 1
           fi

        done

}

#############
### TYPOS ###
#############

alias kk="ll"
alias car="cat"

#############
### UTILS ###
#############

alias copy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"
alias xmlf="paste | xmllint --format - | copy"
alias jsonf="paste | jq '.' | copy"

browser() {
  nohup open -a "Google Chrome" $@ >/dev/null 2>&1 &
}

ff() {
   grep -RiIl "$1" . | grep -Ev "target/|.git|.settings|.project|.mvn|.idea|build/" | xargs -I % sh -c "printf '\e[1;34m%\e[0m\n'; grep -C 2 -m1 --color -i '$1' '%'; printf '\n'"
}

################
### COMMANDS ###
################

dup() {

	local FILE=$(find . -type f -name "docker-compose.yml")
	docker-compose -f "$FILE" up -d
	docker-compose -f "$FILE" --tail logs
}

rup() {
	local FILE=$(find . -type f -name "docker-compose.yml")
        docker network prune -f
	docker-compose -f "$FILE" rm -f
}

dstop() {
	docker stop $(docker ps -aq)
}

docker-clean() {
	dstop
	docker rm $(docker ps -aq)
	docker network prune -f
}

###########
### GIT ###
###########

alias status="git status"
alias current-branch="git branch | grep \* | cut -d ' ' -f2"
alias pull="current-branch | xargs git pull origin"
alias push="current-branch | xargs git push origin"
alias fpush="current-branch | xargs git push origin -f"
alias add="git add -A . ; status"
alias amend="git commit --amend --no-edit"
alias checkout="git checkout ."
alias patch="add && amend"


files-affected() {
	local currentBranch=$(current-branch)
	local containsDevBranch=$(git branch -a | grep dev)
	if [[ -n $containsDevBranch ]]; then
		git diff --name-only dev..$currentBranch
	else
		git diff --name-only master..$currentBranch
	fi
}

cm(){
  PREFIX=$(current-branch | cut -d '/' -f 2)
  git commit -m "$PREFIX $@"
}



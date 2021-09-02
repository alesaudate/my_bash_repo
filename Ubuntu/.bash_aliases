#!/bin/bash

###############
### GENERAL ###
###############

alias fix="fuck"  # Polite version of https://github.com/nvbn/thefuck
export WORKSPACE=~/workspace

#############
### TYPOS ###
#############

alias kk="ll"
alias car="cat"

################
### COMMANDS ###
################

jenkins() {
	local URL=$1
	local URL=${URL%/console}
	local URL=$URL/api/json
	
	__jenkins $JENKINS_AUTH  $URL
	if [ -z $VAR_JENKINS_RESULT ]; then
		URL=$(curl --user $JENKINS_AUTH -s $URL | jq -r '.lastBuild.url')
		URL="$URL/api/json"
		__jenkins $JENKINS_AUTH $URL
	fi

	while [ $VAR_JENKINS_RESULT = 'true' ];
	do
		sleep 15
		__jenkins $JENKINS_AUTH  $URL
		if [ $VAR_JENKINS_RESULT = "" ]; then
			__jenkins $JENKINS_AUTH  $URL
		fi
	done
	notify-send "Build do Jenkins finalizou"
}

__jenkins() {
	VAR_JENKINS_RESULT=$(curl --user $1 -s $2 | jq -r '.building')
}


#######################
### SYSTEM OVERRIDE ###
#######################

chown() {

	whoami=$(whoami)
	sudo chown -R $whoami: $@


}





source ~/.git_aliases
source ~/.maven_aliases
source ~/.command_not_found_handler
export PATH=$PATH:$WORKSPACE/docker-recipes
source ~/.docker_aliases
source ~/.java_aliases
source ~/.navigation_aliases
export PATH=$PATH:$HOME/Software/adr-tools-3.0.0/src
source ~/.gradle_aliases
source ~/.utils_aliases



###########
# INUTILS #
###########

alias ll="fortune brasil | cowsay && ls -la --color=auto"
alias please="sudo"

dev-life() {
  browser "https://stackoverflow.com"
}

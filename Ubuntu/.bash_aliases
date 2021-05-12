#!/bin/bash

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
alias dc="cd .."
alias shortcuts="google-chrome https://www.google.com/search?q=terminator+shortcuts&oq=terminator+shortcuts&aqs=chrome..69i57j0l5.3969j0j7&sourceid=chrome&ie=UTF-8"
alias fix="fuck"  # Polite version of https://github.com/nvbn/thefuck

cf() {
  cat $1 | copy && xmlf
}

browser() {
  nohup google-chrome $@ >/dev/null 2>&1 &
}

ff() {
   grep -RiIl "$1" | grep -Ev "target/|.git|.settings|.project|.mvn|.idea|build/" | xargs -I % sh -c "printf '\e[1;34m%\e[0m\n'; grep -C 2 -m1 --color -i '$1' '%'; printf '\n'"
}


replace(){

   if [ $# != 3 ]
   then
      echo "usage: replace <file pattern> <string to find> <string to replace with>"
      return 1
   fi

   FILE_PATTERN=$1
   TO_FIND=$2
   TO_REPLACE=$3

   find . -name "$FILE_PATTERN" | xargs sed -i "s/$TO_FIND/$TO_REPLACE/g"
}

root() {
	local FILE_TO_LOOK_FOR=build.gradle
	local FILE_TO_LOOK_FOR_KTS=$FILE_TO_LOOK_FOR.kts
	local WORKING_DIR=$(pwd)
	local INITIAL_FOLDER=$(pwd)


	while [ ! -f $FILE_TO_LOOK_FOR ] && [ ! -f $FILE_TO_LOOK_FOR_KTS ]; do
	   cd ..
	   WORKING_DIR=$(pwd)
	   if [ $WORKING_DIR="/" ]; then
		   echo "No $FILE_TO_LOOK_FOR found"
		   cd $INITIAL_FOLDER
		   return 1
	   fi

	done

}



function uriencode() { 
	jq -nr --arg v "$1" '$v|@uri'; 
}

postman(){
	nohup postman >/dev/null 2>&1 &
}

#ssh(){
#	local workdir=$(pwd)
#	cd ~/chaves
#	command ssh $@
#	cd $workdir
#}


##############
### GRADLE ###
##############

gradle() {

   local INITIAL_DIR=$(pwd)
   root
   if [ $? -ne 0 ]; then
	   return $?
   fi
   local WORKING_DIR=$(pwd)
   
   local COMMAND="$(pwd)/gradlew"
   local start_time="$(date -u +%s)"
   { BUILD_RESULT=$(command $COMMAND -p $WORKING_DIR "$@" | tee >(grep 'BUILD SUCCESSFUL') >&3); } 3>&1
   local end_time="$(date -u +%s)"
   local elapsed="$(($end_time-$start_time))"
   if [[ -n "$BUILD_RESULT" ]]
   then
	   notify-send -i face-smile-big "BUILD SUCCESFUL: Gradle finalizou em $elapsed segundos"
	   cd $INITIAL_DIR
	   return 0;
   else
	   notify-send -i face-worried "BUILD FAILURE: Gradle finalizou em $elapsed segundos"
           cd $INITIAL_DIR
	   return 1;
   fi
}

testp() {


	{ GRADLE_OUT=$(gradle test 2>&1 | tee /dev/fd/3 |  grep 'See the report at'); } 3>&1
	if [[ -n "$GRADLE_OUT" ]]
	then
		GRADLE_OUT=$(echo $GRADLE_OUT | sed 's/.*\ //')
		browser $GRADLE_OUT
	fi
	

}

sonar() {
  PROJECT_NAME=$(bash -c "source ~/.bash_aliases; root; pwd | xargs basename;")
  BRANCH=$(current-branch)
  BRANCH=$(uriencode $BRANCH)
  URL="$SONAR_URL/dashboard?branch=$BRANCH&id=$PROJECT_NAME"
   
  gradle sonarqube && browser "$URL"
}

prep-release() {
   it && sonar
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



###########
# INUTILS #
###########

alias ll="fortune brasil | cowsay && ls -la --color=auto"
alias please="sudo"

export WORKSPACE=~/workspace
export PATH=$PATH:$WORKSPACE/docker-recipes

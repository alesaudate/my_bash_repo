#!/bin/bash


#############
### UTILS ###
#############

alias please="sudo"
alias copy="xclip -selection clipboard"
alias paste="xclip -selection clipboard -o"
alias xmlf="paste | xmllint --format - | copy"
alias jsonf="paste | jq '.' | copy"
alias dc="cd .."
alias kk="ll"
alias shortcuts="google-chrome https://www.google.com/search?q=terminator+shortcuts&oq=terminator+shortcuts&aqs=chrome..69i57j0l5.3969j0j7&sourceid=chrome&ie=UTF-8"
alias fix="fuck"

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

gradle() {

   WORKING_DIR=$(pwd)
   COMMAND="$(pwd)/gradlew"
   if [[ ! -f $COMMAND ]]
   then

      WORKING_DIR="$WORK_DIR"
      COMMAND="$WORK_DIR/gradlew"
   fi
      	
   start_time="$(date -u +%s)"
   { BUILD_RESULT=$(command $COMMAND -p $WORKING_DIR "$@" | tee >(grep 'BUILD SUCCESSFUL') >&3); } 3>&1
   end_time="$(date -u +%s)"
   elapsed="$(($end_time-$start_time))"
   notify-send "Gradle finalizou execução em $elapsed segundos"
   if [[ -n "$BUILD_RESULT" ]]
   then
	   return 0;
   else
	   return 1;
   fi
}

dup() {
	FILE=$(pwd)/docker/docker-compose.yml
	docker-compose -f "$FILE" up
}

function uriencode() { 
	jq -nr --arg v "$1" '$v|@uri'; 
}

###########
# INUTILS #
###########

alias ll="fortune brasil | cowsay -f vader && ls -la --color=auto"

###########
### GIT ###
###########

alias status="git status"
alias current-branch="git branch | grep \* | cut -d ' ' -f2"
alias pull="current-branch | xargs git pull origin"
alias push="current-branch | xargs git push origin"
alias fpush="current-branch | xargs git push origin -f"
alias files-affected="git diff-tree --no-commit-id --name-only -r HEAD"
alias dev="git checkout dev; pull"
alias sandbox="git checkout sandbox; pull"
alias master="git checkout master; pull"
alias add="git add -A . ; status"
alias checkout="git checkout ."


store() {
        git config credential.helper store
}


git(){
  case "$1" in clone) git-clone "${@:2}";; *) command git "$@";; esac
}


git-clone(){
   local tgt
   tgt=$(command git clone "$@" 2> >(tee /dev/stderr |head -n1 | cut -d \' -f2)) ||
      return $?
   cd "$tgt" || exit
}

cm(){
  PREFIX=$(current-branch | cut -d '/' -f 2)
  git commit -m "$PREFIX $@"
}

nb() {
  git checkout -b feature/MOS-"$1"
}

rb() {
  git checkout -b release/MOS-"$1"
}

nbp() {
  git checkout -b feature/PAAC-"$1"
}

rbp() {
  git checkout -b release/PAAC-"$1"
}


jenkins() {
	URL=$1
	URL=${URL%/console}
	URL=$URL/api/json
	
	RESULT=$(curl --user $JENKINS_AUTH -s $URL | jq '.building')
	while [ $RESULT = 'true' ];
	do
		sleep 15
		RESULT=$(curl --user $JENKINS_AUTH -s $URL | jq '.building')
		if [ $RESULT = "" ]; then
			RESULT=$(curl --user $JENKINS_AUTH -s $URL | jq '.building')
		fi
	done
	notify-send "Build do Jenkins finalizou"
}


################
### ATALHOS ####
################


alias qr="cd ~/workspace/qrcode-service"
alias qrtest="cd ~/workspace/qrcode-service-test"
alias it="gradle clean format integrationTest || browser $WORK_DIR/build/reports/tests/integrationTest/index.html"
alias itnotest="gradle -x test integrationTest || browser $WORK_DIR/reports/tests/integrationTest/index.html"

sonar() {
  BRANCH=$(current-branch)
  BRANCH=$(uriencode $BRANCH)
  echo $BRANCH
  URL="$SONAR_URL/dashboard?branch=$BRANCH&id=qrcode-service"
   
  gradle format sonarqube && browser "$URL"
}

prep-release() {
   it && sonar
}


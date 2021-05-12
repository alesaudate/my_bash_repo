#!/bin/bash

CURRENT_FOLDER=$(pwd)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cp ~/.bash_aliases $SCRIPT_DIR
cd $SCRIPT_DIR
git add -A .
git commit -m "auto-loaded"
git push origin master
cd $CURRENT_FOLDER

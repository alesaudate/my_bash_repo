#!/bin/bash

cp ~/.bash_aliases $WORK_DIR/my_bash_repo/
git add -A .
git commit -m "auto-loaded"
git push origin master

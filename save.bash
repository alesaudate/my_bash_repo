#!/bin/bash

cp ~/.bash_aliases ~/workspace/my_bash_repo
git add -A .
git commit -m "auto-loaded"
git push origin master

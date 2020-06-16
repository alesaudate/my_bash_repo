#!/bin/bash

cp /home/asaudate/.bash_aliases /home/asaudate/workspace/my_bash_repo
git add -A .
git commit -m "auto-loaded"
git push origin master

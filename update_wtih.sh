#!/bin/bash

branch=$(git rev-parse --abbrev-ref HEAD)

echo $1
echo $branch

git stash
git checkout $1 -q
git pull
git checkout $branch
git pull
git merge $1 --commit --no-ff --no-edit --no-squash
git stash pop

echo "DONE"
#!/bin/bash

branch=$(git rev-parse --abbrev-ref HEAD)
diff=$(git diff)

echo $1
echo $branch

if [ ! -z "$diff" ]; then
	git stash
fi
git checkout $1 -q
git pull
git checkout $branch
git pull
git merge $1 --commit --no-ff --no-edit --no-squash
if [ ! -z "$diff" ]; then
	git stash pop
fi
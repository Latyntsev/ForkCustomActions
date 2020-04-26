#!/bin/bash

branch=$(git rev-parse --abbrev-ref HEAD)
diff=$(git diff)
base_branch=$1

if [ -z "$base_branch" ]; then
	base_branch=$(git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed 's/.*\[\(.*\)\].*/\1/' | sed 's/[\^~].*//')
fi

echo $base_branch
echo $branch

if [ ! -z "$diff" ]; then
	git stash
fi
git checkout $base_branch -q
git pull
git checkout $branch
git pull
git merge $base_branch --commit --no-ff --no-edit --no-squash
if [ ! -z "$diff" ]; then
	git stash pop
fi
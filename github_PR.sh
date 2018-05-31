#!/bin/bash

branch=$(git rev-parse --abbrev-ref HEAD)
repo_name=$(git config --get remote.origin.url | cut -d ":" -f 2 | cut -d "." -f 1)

echo $1
echo $branch
echo $repo_name

if [ ! -z "$1" ]; then
	open https://github.com/$repo_name/compare/$1...$branch?expand=1
else
	open https://github.com/$repo_name/compare/$branch?expand=1
fi
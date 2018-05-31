#!/bin/bash

branch=$(git rev-parse --abbrev-ref HEAD)

echo $1
echo $branch


git checkout $1 -q && \
sleep 1 && \
git pull && \
sleep 1 && \
git checkout $branch && \
sleep 1 && \
git pull && \
sleep 1 && \
git merge $1 --commit --no-ff --no-edit --no-squash

echo "DONE"
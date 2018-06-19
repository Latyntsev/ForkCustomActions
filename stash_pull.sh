#!/bin/bash

diff=$(git diff)

if [ ! -z "$diff" ]; then
	git stash
fi

git pull

if [ ! -z "$diff" ]; then
	git stash pop
fi
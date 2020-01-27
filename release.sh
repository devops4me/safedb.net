#!/bin/bash

# to release we bump the version and push to master
gem bump patch --tag --push --file=$PWD/lib/version.rb

# bring in any changes made to the master branch
git pull origin master

# pull in release and bring it up to date with master
git fetch origin
git checkout -b release origin/release
git pull origin release
git merge master

# push updated release branch with new version number
git push origin release

# return the local repository to the master line
git checkout master
git pull origin master

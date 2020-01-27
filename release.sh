#!/bin/bash

# bring in any changes made to the master branch
git pull origin master

# to release we bump the version and push to master
gem bump patch --tag --push --file=$PWD/lib/version.rb

# pull in release and bring it up to date with master
git fetch origin

# checkoug fails if branch not available locally
# git checkout -b release origin/release
git checkout release

# pull in latest changes to the release branch
git pull origin release
git merge master

# push updated release branch with new version number
git push origin release

# return the local repository to the master line
git checkout master
git pull origin master

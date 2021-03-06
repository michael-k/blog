#!/bin/bash
set -e

TARGET_BRANCH=gh-pages

if [ ! -f "$SOURCE_DIR/index.html" ]; then
  echo "SOURCE_DIR ($SOURCE_DIR) does not exist, build the source directory before deploying."
  exit 1
fi

REPO=$(git config remote.origin.url)

if [ -n "$TRAVIS_BUILD_ID" ]; then
  # When running on Travis we need to use SSH to deploy to GitHub
  #
  # The following converts the repo URL to an SSH location,
  # decrypts the SSH key and sets up the Git config with
  # the correct user name and email (globally as this is a
  # temporary travis environment).
  if [ "$TRAVIS_BRANCH" != "$DEPLOY_BRANCH" ]; then
    echo "Travis should only deploy from the DEPLOY_BRANCH ($DEPLOY_BRANCH) branch"
    exit 0
  elif [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "Travis should not deploy from pull requests"
    exit 0
  else
    echo DEPLOY_BRANCH: $DEPLOY_BRANCH
    echo GIT_NAME: $GIT_NAME
    echo GIT_EMAIL: $GIT_EMAIL
    # switch both git and https protocols as we don't know which travis
    # is using today (it changed!)
    REPO=${REPO/git:\/\/github.com\//git@github.com:}
    REPO=${REPO/https:\/\/github.com\//git@github.com:}

    chmod 600 $SSH_KEY
    eval `ssh-agent -s`
    ssh-add $SSH_KEY
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
  fi
fi

REV=$(git rev-parse --short HEAD)

cd $SOURCE_DIR
git init .
git checkout -b $TARGET_BRANCH

git add -A .
git commit --allow-empty -m "Built from commit $REV"
git push -f $REPO $TARGET_BRANCH

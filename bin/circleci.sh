#!/bin/bash
if [ -z "$CIRCLE_JOB" ]; then
  export DOCKER_VERSION=${1:-1.9.1} # only used by Circle 1.0
fi

export BUILD_HARNESS_PROJECT=${2:-build-harness}
export BUILD_HARNESS_BRANCH=${3:-master}
export GITHUB_REPO="git@github.com:sagansystems/${BUILD_HARNESS_PROJECT}.git"

# If Circle 1.0 build, install to home directory
if [ -z "$CIRCLE_JOB" ]; then
    cd ~
fi

if [ "$BUILD_HARNESS_PROJECT" ] && [ -d "$BUILD_HARNESS_PROJECT" ]; then
	echo "Removing existing $BUILD_HARNESS_PROJECT"
  rm -rf "$BUILD_HARNESS_PROJECT"
fi

git clone -b $BUILD_HARNESS_BRANCH $GITHUB_REPO
make -C $BUILD_HARNESS_PROJECT deps circle:deps

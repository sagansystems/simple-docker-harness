#!/bin/bash
export DOCKER_VERSION=${1:-1.9.1}
export BUILD_HARNESS_PROJECT=${2:-build-harness}
export BUILD_HARNESS_BRANCH=${3:-master}
export GITHUB_REPO="git@github.com:sagansystems/${BUILD_HARNESS_PROJECT}.git"

cd ~
git clone -b $BUILD_HARNESS_BRANCH $GITHUB_REPO
make -C $BUILD_HARNESS_PROJECT deps circle:deps


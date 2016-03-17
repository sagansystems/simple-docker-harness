# Build Harness

Facilitate building and releasing docker containers

## General

Run `make help` to get a list of available build targets

```
# Available targets

  deps                      Configure all dependencies
  help                      This help screen
  machine:deps              Setup dependencies for docker-machine
  machine:info              Docker Machine Info
  machine:recreate          Recreate the docker machine
  machine:create            Create docker machine for environment
  machine:destroy           Destroy docker machine for environment
  machine:start             Start docker machine for environment
  machine:stop              Stop docker machine for environment
  machine:restart           Restart docker machine for environment
  docker:build              Build a docker image
  docker:push               Push image to Docker Hub
  docker:pull               Pull docker image from Docker Hub
  docker:tag                Tag the last built image with `DOCKER_TAG`
  docker:clean              Remove existing docker images
  docker:run                Test drive the image
  docker:shell              Run the container and start a shell
  docker:attach             Attach to the running container
  docker:login              Login to docker registry
  docker:export             Export docker images to file
  docker:import             Import docker images from file

# Targets Available on CircleCI

  circle:deps               Install CircleCI deps
  circle:tag                Tag and push to registry (CircleCI)
  circle:release            Tag and push official release to registry (CircleCI)
```

## Using Build Harness in other repositories

1. Create a `Makefile` in in the project (if one does not already exist).
1. Add the following snippet near the top of the project's `Makefile`

*Snippet*:
```
SHELL = /bin/bash
export BUILD_HARNESS_PATH ?= $(shell until [ -d "build-harness" ] || [ "`pwd`" == '/' ]; do cd ..; done; pwd)/build-harness/
include $(BUILD_HARNESS_PATH)/Makefile.shim
```

The default `BUILD_HARNESS_PATH` resolves to the first directory we can find by traversing up the tree until we find one named `build-harness`. e.g. We can override this behavior by setting `BUILD_HARNESS_PATH=/opt/build-harness`

Because we use a conditional assignment on the `BUILD_HARNESS_PATH`, it can always be overriden in a user's `~/.profile|~/.bashrc|~/.bash_profile` to the exact location.

**IMPORTANT** it's highly advised not to change the logic above because it needs to work both locally for development and on CircleCI

## Building images

Before building images, you must create your docker machine and initialize dependencies.

    make machine:create deps

Then build the image

    make docker:build

You can chain targets together as well or even override environment settings, like this:

    make docker:build docker:tag docker:push DOCKER_TAG=foobar

## CircleCI Integration

Here's a minimal example of what is needed for CircleCI. Add/merge the following to your projects `circle.yml` file.
```yaml
machine:
  pre:
    - "curl --retry 5 --retry-delay 1 https://raw.githubusercontent.com/sagansystems/build-harness/master/bin/circleci.sh | bash -x -s 1.9.1"
  services:
    - "docker"
test:
  override:
    - "make docker:build"
  post:
    - "make circle:tag"
deployment:
  master:
    branch: "master"
    commands:
     - make docker:tag:
         environment:
           DOCKER_TAG: latest
```

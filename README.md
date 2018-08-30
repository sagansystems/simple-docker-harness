<!-- MarkdownTOC -->

- [Build Harness](#build-harness)
  - [General](#general)
  - [Setting up your development environment](#setting-up-your-development-environment)
  - [Using Build Harness in other repositories](#using-build-harness-in-other-repositories)
  - [Building images](#building-images)
  - [CircleCI Integration](#circleci-integration)
  - [Codefresh Integration](#codefresh-integration)

<!-- /MarkdownTOC -->

# Build Harness

Facilitate building and releasing docker containers

## General

Run `make help` to get a list of available build targets

```
# Available targets

  deps                      Configure all dependencies
  help                      This help screen
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
  circle:cleanup-docker     Cleanup Docker images from CircleCI Docker cache. Calling it once in workflow (for example in the "build" job) should be enough.

# Targets Available on Codefresh

  codefresh:deps                      Install Codefresh deps
  codefresh:git-tag-docker-latest     Tag as [branch]-docker-latest in git
  codefresh:tag                       Tag using BUILD version and push to registry
  codefresh:deploy-kubernetes         Deploy to kubernetes
  codefresh:tag-deploy-cluster        Tag image as [branch]-docker-latest and deploy to the cluster
```

## Setting up your development environment

1. Clone this repository into your development environment
2. Define `BUILD_HARNESS_PATH` in your shell to be the path to where you checked out the repo. You will want to add this to your `~/.profile|~/.bashrc|~/.bash_profile|~/.zshrc`

## Using Build Harness in other repositories

1. Create a `Makefile` in in the project (if one does not already exist).
1. Add the following snippet near the top of the project's `Makefile`

*Snippet*:
```
SHELL = /bin/bash
export BUILD_HARNESS_PATH ?= $(shell until [ -d "build-harness" ] || [ "`pwd`" == '/' ]; do cd ..; done; pwd)/build-harness/
-include $(BUILD_HARNESS_PATH)/Makefile.shim
```

The default `BUILD_HARNESS_PATH` resolves to the first directory we can find by traversing up the tree until we find one named `build-harness`. e.g. We can override this behavior by setting `BUILD_HARNESS_PATH=/opt/build-harness`

Because we use a conditional assignment on the `BUILD_HARNESS_PATH`, it can always be overriden in a user's `~/.profile|~/.bashrc|~/.bash_profile` to the exact location.

**IMPORTANT** it's highly advised not to change the logic above because it needs to work both locally for development and on CircleCI

## Building images

Before building images, you must initialize dependencies.

    make deps

Then build the image

    make docker:build

You can chain targets together as well or even override environment settings, like this:

    make docker:build docker:tag docker:push DOCKER_TAG=foobar

## Codefresh Integration

Codefresh will use the `codefresh` tag of build-harness. Once your build-harness change is merged into master, please advance the `codefresh` tag. You can also temporarily tag your branch with this tag to test your changes.

Here's a minimal example of what is needed for Codefresh. Add/merge the following to your projects `codefresh.yml` file.
```yaml
  deploy_master:
    title: Deploy to master
    image: sagan/build-harness:codefresh
    working_directory: ${{main_clone}}
    environment:
      - CLUSTER_NAMESPACE=master
      - CLUSTER_DOMAIN=gladly.qa
      - IMAGE_TAG=${{CF_BRANCH_TAG_NORMALIZED}}-${{CF_SHORT_REVISION}}
    commands:
      - make codefresh:tag-deploy-cluster
    when:
      branch:
        only:
          - master
```

## Versioning

Build-harness is used in upstream repositories, so after merging changes to master please do the following:
- publish new [build-harness release](https://github.com/sagansystems/build-harness/releases) - Codefresh will automatically build build-harness image with this tag
- advance the `codefresh` [tag in build-harness](https://github.com/sagansystems/build-harness/tree/codefresh) to point to the tip of master - this will update the image used in Codefresh pipelines
- point `release-harness` Dockerfile [BUILD_HARNESS_VERSION](https://github.com/sagansystems/release-harness/blob/master/Dockerfile) to the newly created release (not to the `codefresh` tag) and merge that change to release-harness master
- publish new [release-harness release](https://github.com/sagansystems/release-harness/releases) - Codefresh will automatically build `build-harness` image with this tag
- point [gladly-release Dockerfile](https://github.com/sagansystems/gladly-release/blob/master/Dockerfile) to the newly created `release-harness` release and merge that change to `gladly-release` master. No need to create any new `gladly-release` release

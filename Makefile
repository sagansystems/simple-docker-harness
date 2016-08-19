PACKAGE_NAME := build-harness
MAKEFILE_PATH := $(strip $(MAKEFILE_LIST))
MAKEFILE_DIR := $(shell dirname "$(MAKEFILE_PATH)")
SELF = make -f $(MAKEFILE_PATH)
SHELL := /bin/bash

# Formatting codes
green = \x1b[32;01m$1\x1b[0m
yellow = \x1b[33;01m$1\x1b[0m
red = \x1b[33;31m$1\x1b[0m

define print
	@echo "$@: $1"
endef

# Ensures that a variable is exported
define assert
  @[ -n "$$$1" ] || (echo "$(1) not exported in $(@)"; exit 1)
endef

# Ensures that a variable is set
define assert_set
  @[ -n "$($1)" ] || (echo "$(1) not set in $(@)"; exit 1)
endef

# Setup the docker run-time environment
ifeq ($(CIRCLECI),true)
  include $(MAKEFILE_DIR)/modules/Makefile.circleci
endif

# Include the docker-specific targets
include $(MAKEFILE_DIR)/modules/Makefile.docker

# Include kubernetes deployment targets
include $(MAKEFILE_DIR)/modules/datadog/Makefile
include $(MAKEFILE_DIR)/modules/Makefile.kubernetes

# Include help targets
include $(MAKEFILE_DIR)/modules/Makefile.help

.PHONY : help deps

.DEFAULT_GOAL := help

# (private) Configure all dependencies
deps::
	@exit 0


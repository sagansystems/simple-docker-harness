PACKAGE_NAME := build-harness
MAKEFILE_PATH := $(strip $(MAKEFILE_LIST))
MAKEFILE_DIR := $(shell dirname "$(MAKEFILE_PATH)")
SELF = make -f $(MAKEFILE_PATH)
SHELL := /bin/bash

# Formatting codes
green = \x1b[32;01m$1\x1b[0m
yellow = \x1b[33;01m$1\x1b[0m
red = \x1b[33;31m$1\x1b[0m

ifeq ($(strip $(CLUSTER)),)
	CLUSTER = $(CLUSTER_NAMESPACE).$(CLUSTER_DOMAIN)
else
	TEMP_CLUSTER_PARTS = $(subst ., ,$(CLUSTER))
	TEMP_CLUSTER_DOMAIN_PARTS = $(wordlist 2,$(words $(TEMP_CLUSTER_PARTS)), $(TEMP_CLUSTER_PARTS))
	CLUSTER_NAMESPACE = $(word 1,$(TEMP_CLUSTER_PARTS))
	CLUSTER_DOMAIN = $(word 1,$(TEMP_CLUSTER_DOMAIN_PARTS)).$(word 2,$(TEMP_CLUSTER_DOMAIN_PARTS))
endif

export CLUSTER
export CLUSTER_NAMESPACE
export CLUSTER_DOMAIN

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

ifeq ($(CIRCLECI),true)
  ifdef CIRCLE_JOB # Circle 2.0
      include $(MAKEFILE_DIR)/modules/Makefile.circleci-2.0
  else
      include $(MAKEFILE_DIR)/modules/Makefile.circleci-1.0
  endif
endif

ifdef CF_BUILD_ID # Codefresh
  include $(MAKEFILE_DIR)/modules/Makefile.codefresh-1.0
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

print-cluster:
	@echo "CLUSTER: ${CLUSTER}"
	@echo "CLUSTER_NAMESPACE: ${CLUSTER_NAMESPACE}"
	@echo "CLUSTER_DOMAIN: ${CLUSTER_DOMAIN}"

# (private) Configure all dependencies
deps::
	@exit 0

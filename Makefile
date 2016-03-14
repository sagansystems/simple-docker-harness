MAKEFILE_PATH := $(strip $(MAKEFILE_LIST))
MAKEFILE_DIR := $(shell dirname "$(MAKEFILE_PATH)")
SELF = make -f $(MAKEFILE_PATH)

define print
	@echo "$@: $1"
endef

# Ensures that a variable is defined
define assert
  @[ -n "$$$1" ] || (echo "$(1) not defined in $(@)"; exit 1)
endef

# Setup the docker run-time environment
ifeq ($(CIRCLECI),true)
  include $(MAKEFILE_DIR)/modules/Makefile.circleci
else
  include $(MAKEFILE_DIR)/modules/Makefile.docker-machine
endif

# Include the docker-specific targets
include $(MAKEFILE_DIR)/modules/Makefile.docker

.PHONY : help env deps

.DEFAULT_GOAL := help

## Configure all dependencies
deps:
	@[ -d $(MAKEFILE_DIR)/bin ] || mkdir -p $(MAKEFILE_DIR)/bin/
	@[ -z "$(DEPS_TARGETS)" ] || $(SELF) $(DEPS_TARGETS)

# (private) include environment
env: deps
	$(eval -include $(MAKEFILE_PATH).env)

## This help screen
help:
	@printf "Available targets:\n\n"
	@awk '/^[a-zA-Z\-\_0-9%:\\]+:/ { \
	  helpMessage = match(lastLine, /^## (.*)/); \
	  if (helpMessage) { \
	    helpCommand = $$1; \
	    helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
      gsub("\\\\", "", helpCommand); \
      gsub(":$$", "", helpCommand); \
	    printf "  %-25s %s\n", helpCommand, helpMessage; \
	  } \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n"

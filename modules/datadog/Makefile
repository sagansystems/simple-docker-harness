
.PHONY : datadog\:notify-deploy-starting \
        datadog\:notify-deploy-success \
        datadog\:notify-deploy-failure

CURL := curl --silent -X POST -H "Content-type: application/json" -d @- 'https://app.datadoghq.com/api/v1/events?api_key=$(DATADOG_API_KEY)' > /dev/null

NOTIFY_MODE ?= deploy
NOTIFY_SUCCESS ?= @$(SELF) datadog:notify-$(NOTIFY_MODE)-success
NOTIFY_FAILURE ?= ($(SELF) datadog:notify-$(NOTIFY_MODE)-failure; exit 1)
NOTIFY_STARTING ?= @$(SELF) datadog:notify-$(NOTIFY_MODE)-starting

define datadog_notify_deploy
	$(call assert,KUBERNETES_APP)
	$(call assert,DATADOG_API_KEY)
	$(call assert,CLUSTER_NAMESPACE)
	$(call assert,IMAGE_TAG)
	$(call assert,CIRCLE_BUILD_NUM)
	$(call assert,CIRCLE_BRANCH)
	@envsubst < $(MAKEFILE_DIR)/modules/datadog/$(1).json | $(CURL)
endef

## Notify datadog of a deploy is starting
datadog\:notify-deploy-starting:
	$(call datadog_notify_deploy,$(subst datadog:notify-,,$@))

## Notify datadog of a deploy was successful
datadog\:notify-deploy-success:
	$(call datadog_notify_deploy,$(subst datadog:notify-,,$@))

## Notify datadog of a deploy failure
datadog\:notify-deploy-failure:
	$(call datadog_notify_deploy,$(subst datadog:notify-,,$@))

define datadog_notify_release
	$(call assert,KUBERNETES_APP)
	$(call assert,DATADOG_API_KEY)
	$(call assert,CLUSTER_NAMESPACE)
	$(call assert,IMAGE_TAG)
	@envsubst < $(MAKEFILE_DIR)/modules/datadog/$(1).json | $(CURL)
endef

## Notify datadog of a release is starting
datadog\:notify-release-starting:
	$(call datadog_notify_release,$(subst datadog:notify-,,$@))

## Notify datadog of a release was successful
datadog\:notify-release-success:
	$(call datadog_notify_release,$(subst datadog:notify-,,$@))

## Notify datadog of a release failure
datadog\:notify-release-failure:
	$(call datadog_notify_release,$(subst datadog:notify-,,$@))

## Notify stdout of a release is starting
datadog\:notify-stdout-starting:
	@echo "INFO: Rollout of $(KUBERNETES_APP):$(IMAGE_TAG) to $(CLUSTER_NAMESPACE) starting."

## Notify stdout of a release was successful
datadog\:notify-stdout-success:
	@echo "INFO: Rollout of $(KUBERNETES_APP):$(IMAGE_TAG) to $(CLUSTER_NAMESPACE) successful."

## Notify stdout of a release failure
datadog\:notify-stdout-failure:
	@echo "INFO: Rollout of $(KUBERNETES_APP):$(IMAGE_TAG) to $(CLUSTER_NAMESPACE) failed."


.PHONY : datadog\:notify-deploy-starting \
        datadog\:notify-deploy-success \
        datadog\:notify-deploy-failure

CURL := curl --silent -X POST -H "Content-type: application/json" -d @- 'https://app.datadoghq.com/api/v1/events?api_key=$(DATADOG_API_KEY)' > /dev/null

NOTIFY_SUCCESS ?= @$(SELF) datadog:notify-deploy-success
NOTIFY_FAILURE ?= ($(SELF) datadog:notify-deploy-failure; exit 1)
NOTIFY_STARTING ?= @$(SELF) datadog:notify-deploy-starting

define datadog_notify
	$(call assert,KUBERNETES_APP)
	$(call assert,DATADOG_API_KEY)
	$(call assert,CLUSTER_NAMESPACE)
	$(call assert,IMAGE_TAG)
	$(call assert,CIRCLE_BUILD_NUM)
	$(call assert,CIRCLE_BRANCH)
	@envsubst < $(MAKEFILE_DIR)/modules/datadog/$(1).json | $(CURL)
endef

## Notify datadog a deploy is starting
datadog\:notify-deploy-starting:
	$(call datadog_notify,$(subst datadog:notify-,,$@))

## datadog datadog a deploy was successful
datadog\:notify-deploy-success:
	$(call datadog_notify,$(subst datadog:notify-,,$@))

## datadog datadog a deploy failure
datadog\:notify-deploy-failure:
	$(call datadog_notify,$(subst datadog:notify-,,$@))

export CLOUD_PROVIDER ?= aws

include /build-harness/templates/Makefile.build-harness

include tasks/Makefile.*

## Create cluster
create: \
  $(CLOUD_PROVIDER)/create/all \
  helmfile/create/all \
  kubectl/display/ip \
  kubectl/implement/autoscaling
	@echo "Cluster created"

## Destroy cluster
destroy: \
  helmfile/destroy/all \
  $(CLOUD_PROVIDER)/destroy/all
	@echo "Cluster destroyed"

## Create $CACHE_PATH directory, if it doesn't already exist
create_cache_path:
	@if [ ! -d "$(CACHE_PATH)" ]; \
	then \
	    mkdir $(CACHE_PATH); \
	fi

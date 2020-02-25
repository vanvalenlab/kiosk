export CLUSTER ?= kiosk
export DOCKER_ORG ?= vanvalenlab
export DOCKER_IMAGE ?= $(DOCKER_ORG)/$(CLUSTER)
export DOCKER_TAG ?= latest
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_BUILD_FLAGS = 
export README_DEPS ?= docs/targets.md
export INSTALL_PATH ?= /usr/local/bin


-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

## Initialize build-harness, install deps, build docker container, install wrapper script and run shell
all: init deps build install run
	@exit 0

## Install dependencies (if any)
deps:
	@exit 0

## Build docker image
build:
	@make --no-print-directory docker/build

## Push docker image to registry
push:
	docker push $(DOCKER_IMAGE)

## Install wrapper script from geodesic container
install:
	@docker run --rm $(DOCKER_IMAGE_NAME) | sudo -E bash -s $(DOCKER_TAG)

## Start the geodesic shell by calling wrapper script
run:
	$(CLUSTER)

## Target for testing cluster deployment
test: export CLUSTER_NAME = deepcell-test-$(shell bash -c 'echo $$RANDOM')
test:
	# Some debug info
	echo "TEST"
	printenv
	echo $(CLOUDSDK_CORE_PROJECT) && echo $(HOME)
	pwd
	ls
	make init
	# Installations of binaries
	## helmfile
	wget https://github.com/roboll/helmfile/releases/download/v0.82.0/helmfile_linux_amd64
	chmod 764 $(TEST_HOME_DIR)/helmfile_linux_amd64
	$(TEST_HOME_DIR)/helmfile_linux_amd64 --version
	## gomplate
	wget https://github.com/hairyhenderson/gomplate/releases/download/v3.1.0/gomplate_linux-amd64-slim
	chmod 764 $(TEST_HOME_DIR)/gomplate_linux-amd64-slim
	$(TEST_HOME_DIR)/gomplate_linux-amd64-slim --version
	## kubectl
	apt-get update && sudo apt-get install -y apt-transport-https
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
	apt-get update
	apt-get install -y kubectl
	kubectl version --client
	## kubens
	wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens
	mv $(TEST_HOME_DIR)/kubens $(TEST_HOME_DIR)/conf/kubens.sh
	chmod 764 $(TEST_HOME_DIR)/conf/kubens.sh
	## helm
	wget https://get.helm.sh/helm-v2.16.3-linux-amd64.tar.gz
	tar -xzvf helm-v2.16.3-linux-amd64.tar.gz
	chmod 764 $(TEST_HOME_DIR)/linux-amd64/helm
	chmod 764 $(TEST_HOME_DIR)/linux-amd64/helm
	$(TEST_HOME_DIR)/linux-amd64/helm version -c
	## gcloud
	apt-get install apt-transport-https ca-certificates gnupg
	echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
	curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
	apt-get update && apt-get install google-cloud-sdk
	gcloud version
	echo $(CLOUDSDK_CONFIG)
	# execute make targets 
	cd ./conf && make -f Makefile.test test/create
	cd ./conf && make -f Makefile.test test/destroy
	# celebrate
	echo "TESTED"


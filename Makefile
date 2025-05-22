# minimalistic utility to test and develop locally

SHELL = /bin/sh
.DEFAULT_GOAL := help

export IMAGE_PYTORCH=osparc-python-runner-pytorch
export IMAGE_TENSORFLOW=osparc-python-runner-tensorflow
export TAG_PYTORCH=1.0.4
export TAG_TENSORFLOW=1.0.4

# PYTHON ENVIRON ---------------------------------------------------------------------------------------
.PHONY: devenv
.venv:
	@python3 --version
	python3 -m venv $@
	# upgrading package managers
	$@/bin/pip install --upgrade uv

devenv: .venv  ## create a python virtual environment with tools to dev, run and tests cookie-cutter
	# installing extra tools
	@$</bin/uv pip install wheel setuptools
	# your dev environment contains
	@$</bin/uv pip list
	@echo "To activate the virtual environment, run 'source $</bin/activate'"

# Builds new service version ----------------------------------------------------------------------------
define _bumpversion
	# upgrades as $(subst $(1),,$@) version, commits and tags
	@docker run -it --rm -v $(PWD):/ml-runner \
		-u $(shell id -u):$(shell id -g) \
		itisfoundation/ci-service-integration-library:v2.0.11 \
		sh -c "cd /ml-runner && bump2version --verbose --list --config-file $(1) $(subst $(2),,$@)"
endef

.PHONY: version-patch version-minor version-major
version-patch version-minor version-major: .bumpversion.cfg ## increases service's version
	@make compose-spec
	@$(call _bumpversion,$<,version-)
	@make compose-spec


define _create_run_script
	@docker run -it --rm -v $(PWD):/ml-runner \
		-u $(shell id -u):$(shell id -g) \
		itisfoundation/ci-service-integration-library:v2.0.11 \
		sh -c "cd /ml-runner && \
			ooil run-creator \
				--runscript $(1)/service.cli/run \
				--metadata .osparc/$(1)/metadata.yml"
endef

.PHONY: create-run-script
create-run-script: ## assembles run scrips for pytorch and tensorflow
	@$(call _create_run_script,osparc-python-runner-pytorch)
	@$(call _create_run_script,osparc-python-runner-tensorflow)
	# TODO: add check to make sure git state is not dirty in CI so it fails

.PHONY: compose-spec
compose-spec: ## runs ooil to assemble the docker-compose.yml file
	@docker run -it --rm -v $(PWD):/ml-runner \
		-u $(shell id -u):$(shell id -g) \
		itisfoundation/ci-service-integration-library:v2.0.11 \
		sh -c "cd /ml-runner && ooil compose"

build: | compose-spec	## build docker image
	docker compose build

# To test built service locally -------------------------------------------------------------------------
.PHONY: run-local
run-local:	## runs image with local configuration
	docker compose --file docker-compose-local.yml up

.PHONY: publish-local
publish-local: ## push to local throw away registry to test integration
	docker tag simcore/services/comp/${IMAGE_PYTORCH}:${DOCKER_IMAGE_TAG} registry:5000/simcore/services/comp/$(IMAGE_PYTORCH):$(DOCKER_IMAGE_TAG)
	docker push registry:5000/simcore/services/comp/$(IMAGE_PYTORCH):$(DOCKER_IMAGE_TAG)
	docker tag simcore/services/comp/${IMAGE_TENSORFLOW}:${DOCKER_IMAGE_TAG} registry:5000/simcore/services/comp/$(IMAGE_TENSORFLOW):$(DOCKER_IMAGE_TAG)
	docker push registry:5000/simcore/services/comp/$(IMAGE_TENSORFLOW):$(DOCKER_IMAGE_TAG)
	@curl registry:5000/v2/_catalog | jq

.PHONY: help
help: ## this colorful help
	@echo "Recipes for '$(notdir $(CURDIR))':"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[[:alpha:][:space:]_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""

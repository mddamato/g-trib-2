.ONESHELL:

SHELL 						:= /bin/bash
ENV_CONFIG_DIR					?= $(CURDIR)/config/${ENVIRONMENT}
ENV_BUILD_CACHE					?= ${ENV_CONFIG_DIR}/.cache

export ENV_OVERRIDE_PATH 			?= $(CURDIR)/config/${ENVIRONMENT}/Makefile

-include $(ENV_OVERRIDE_PATH)

## export all vars
export

.PHONY: help
help:
	@echo Options:
	@echo collect-rke2-dependencies
	@echo collect-glowing-tribble
	@echo collect-registry-artifacts
	@echo collect-deployment-specs
	@echo collect-cert-manager-artifacts
	@echo collect-fileserver-artifacts
	@echo compress-all
	@echo collect-all

.PHONY: preflight-check
preflight-check:
	if [ ! "${ENVIRONMENT}" ]; then \
	  @echo "NO ENVIRONMENT DEFINED"; \
	  exit 1; \
	fi

# collect rke2 dependencies
.PHONY: collect-rke2-dependencies
collect-rke2-dependencies: preflight-check
	mkdir -p ${ENV_BUILD_CACHE}/rke2;
	docker run -it -p 5050:5000 --rm --name bundler \
	-w /workingdir \
	--mount type=bind,source="`pwd`/scripts",target=/scripts \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/workingdir \
	--entrypoint /bin/sh \
	-e INSTALL_RKE2_VERSION=${RKE2_VERSION} \
	rockylinux:8 /scripts/collect_rke2_dependencies.sh;
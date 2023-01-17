.ONESHELL:

SHELL 						:= /bin/bash
ENV_CONFIG_DIR					?= $(CURDIR)/config/${ENVIRONMENT}
ENV_BUILD_CACHE					?= ${ENV_CONFIG_DIR}/.cache
VERSION 									= $(shell git describe --tags --exact-match 2>/dev/null || git symbolic-ref -q --short HEAD)
COMMIT_HASH									= $(shell git rev-parse --short HEAD 2>/dev/null)
BUILD_DATE 									= $(shell date +%FT%T%z)

export ENVIRONMENT_OVERRIDES 			?= $(CURDIR)/config/${ENVIRONMENT}/Makefile

-include $(ENVIRONMENT_OVERRIDES)

## export all vars
export

.PHONY: help
help:
	@echo Options:
	@echo collect-rke2-dependencies
	@echo collect-tar-rpm
	@echo collect-images
	@echo hoppr
	@echo compress-all

.PHONY: preflight-check
preflight-check:


	mkdir -p ${ENV_CONFIG_DIR}
	mkdir -p ${ENV_BUILD_CACHE}
	mkdir -p ${ENV_BUILD_CACHE}/tmp

	if [ ! "${ENVIRONMENT}" ]; then \
	  @echo "NO ENVIRONMENT DEFINED"; \
	  exit 1; \
	fi
	if [ ! "${SECRETS_FILE}" ]; then \
	  @echo "NO SECRETS_FILE DEFINED"; \
	  exit 1; \
	fi

	function cleanup()
	{
		stty echo
	}
	trap cleanup EXIT
	stty -echo
	REG1_PASSWORD=`sops --config ${ENV_CONFIG_DIR}/.sops.yaml --output-type dotenv --decrypt --extract '["REG1_PASSWORD"]' ${SECRETS_FILE}`
	REG1_USERNAME=`sops --config ${ENV_CONFIG_DIR}/.sops.yaml --output-type dotenv --decrypt --extract '["REG1_USERNAME"]' ${SECRETS_FILE}`
	podman login --username $$REG1_USERNAME --password $$REG1_PASSWORD registry1.dso.mil

# collect rke2 dependencies
.PHONY: collect-rke2-dependencies
collect-rke2-dependencies: preflight-check
# mkdir -p ${ENV_BUILD_CACHE}/rke2;
	podman run -it -p 5050:5000 --rm --name bundler \
	-w /workingdir \
	--mount type=bind,source="`pwd`/scripts",target=/scripts,z \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/workingdir,z \
	--entrypoint /bin/sh \
	-e INSTALL_RKE2_VERSION=${RKE2_VERSION} \
	rockylinux:8 /scripts/collect_rke2_dependencies.sh;

# run hoppr
.PHONY: hoppr
hoppr: preflight-check
	mkdir -p ${ENV_BUILD_CACHE}/tmp
	function cleanup()
	{
		rm -f ${ENV_BUILD_CACHE}/tmp/credentials.yaml
	}
	trap cleanup EXIT

	REG1_USERNAME=`sops --config ${ENV_CONFIG_DIR}/.sops.yaml --output-type dotenv --decrypt --extract '["REG1_USERNAME"]' ${SECRETS_FILE}`

	export REG1_USERNAME=$${REG1_USERNAME} && envsubst ${REG1_USERNAME} <${ENV_CONFIG_DIR}/hoppr/credentials.yaml >${ENV_BUILD_CACHE}/tmp/credentials.yaml

	podman run \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/opt/app,z \
	--mount type=bind,source="${ENV_BUILD_CACHE}",target=/output,z \
	--env=HOPPR_TRANSFER_CONFIG=hoppr/transfer.yaml \
	--env=HOPPR_LOG_FILE=/output/hoppr.log \
	--env=HOPPR_CREDS_CONFIG=/output/tmp/credentials.yaml \
	docker.io/hoppr/hopctl:latest bundle hoppr/manifest.yaml
	

# collect rke2 dependencies
.PHONY: collect-tar-rpm
collect-tar-rpm: preflight-check
	mkdir -p ${ENV_BUILD_CACHE}/bin
	for releasever in 8 ; do \
	podman run -i -p 5050:5000 --rm --name bundler \
	-w /workingdir \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/workingdir,z \
	--entrypoint /bin/sh \
	-e INSTALL_RKE2_VERSION=${RKE2_VERSION} \
	rockylinux:$${releasever} -c "cp /usr/bin/tar ./.cache/bin"; \
	done

# collect rke2 dependencies
.PHONY: collect-images
collect-images: preflight-check

	mkdir -p ${ENV_BUILD_CACHE}/registry

	podman build -f `pwd`/utility/Dockerfile `pwd`/utility/ -t utility:latest
	podman save utility:latest -o ${ENV_BUILD_CACHE}/registry/utility.tar

# rm -f ${ENV_BUILD_CACHE}/registry/registry.tar
# podman pull registry1.dso.mil/ironbank/opensource/docker/registry-v2:latest
# podman save registry1.dso.mil/ironbank/opensource/docker/registry-v2:latest -o ${ENV_BUILD_CACHE}/registry/registry.tar

# rm -f ${ENV_BUILD_CACHE}/registry/skopeo.tar
# podman pull registry1.dso.mil/ironbank/opensource/containers/skopeo:latest
# podman save registry1.dso.mil/ironbank/opensource/containers/skopeo:latest -o ${ENV_BUILD_CACHE}/registry/skopeo.tar


# build registry database
# .PHONY: collect-registry-artifacts
# collect-registry-artifacts: preflight-check
# 	mkdir -p ${ENV_BUILD_CACHE}/registry;\
# 	rm -rf ${ENV_BUILD_CACHE}/registry/db
# 	podman run -it --rm --name bundler -w /workingdir \
# 	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/config,z \
# 	--mount type=bind,source="`pwd`",target=/workingdir,z \
# 	--entrypoint /bin/sh ubi8 scripts/save_images.sh

# compress all files previously collected
.PHONY: compress-all
compress-all: preflight-check
	
	# compress the tar directory
	tar -C ${ENV_BUILD_CACHE} -cf ${ENV_BUILD_CACHE}/payload.tar rke2 hoppr.tar
	pigz ${ENV_BUILD_CACHE}/payload.tar

	# seed the to_the_airgap.sh with deploy.sh]
	rm -f ${ENV_BUILD_CACHE}/to_the_airgap.sh;
	cp scripts/deploy.sh ${ENV_BUILD_CACHE}/to_the_airgap.sh

	# add the tar rpm to the end of to_the_airgap.sh
	cat ${ENV_BUILD_CACHE}/bin/tar | base64 -w0 >> ${ENV_BUILD_CACHE}/to_the_airgap.sh

	# add a newline
	echo "" >> ${ENV_BUILD_CACHE}/to_the_airgap.sh

	# add the tar payload to the end of to_the_airgap.sh
	cat ${ENV_BUILD_CACHE}/payload.tar.gz | base64 -w0 >> ${ENV_BUILD_CACHE}/to_the_airgap.sh
	



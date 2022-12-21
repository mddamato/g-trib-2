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
	@echo collect-tar-rpm
	@echo compress-all

.PHONY: preflight-check
preflight-check:
	if [ ! "${ENVIRONMENT}" ]; then \
	  @echo "NO ENVIRONMENT DEFINED"; \
	  exit 1; \
	fi



# collect rke2 dependencies
.PHONY: collect-utility
collect-utility: preflight-check
	podman build -f `pwd`/utility/Dockerfile $(pwd)/../ -t utility
	



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
.PHONY: collect-rke2-dependencies
collect-rke2-dependencies: preflight-check
# mkdir -p ${ENV_BUILD_CACHE}/rke2;
	podman run -it -p 5050:5000 --rm --name bundler \
	-w /workingdir \
	--mount type=bind,source="`pwd`/scripts",target=/scripts \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/workingdir,z \
	--entrypoint /bin/sh \
	-e INSTALL_RKE2_VERSION=${RKE2_VERSION} \
	rockylinux:8 /scripts/collect_rke2_dependencies.sh;


# build registry database
.PHONY: collect-registry-artifacts
collect-registry-artifacts: preflight-check
	mkdir -p ${ENV_BUILD_CACHE}/registry;\
	rm -f ${ENV_BUILD_CACHE}/registry/registry.tar
	#podman pull docker.io/library/registry:2
	podman run -it --rm --name bundler \
	-w /workingdir \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/config \
	--mount type=bind,source="`pwd`",target=/workingdir \
	--entrypoint /bin/sh \
        docker.io/ananace/skopeo skopeo sync --src yaml --dest local /config/registry_images.yml /config/.cache/registry.tar;


# compress all files previously collected
.PHONY: compress-all
compress-all: preflight-check
	
	rm -rf ${ENV_BUILD_CACHE}/manifests
	cp -R ${ENV_CONFIG_DIR}/manifests ${ENV_BUILD_CACHE}/

	# compress the tar directory
	tar -C ${ENV_BUILD_CACHE} -cf ${ENV_BUILD_CACHE}/payload.tar rke2 manifests registry
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
	



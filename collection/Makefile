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
.PHONY: collect-tar-rpm
collect-tar-rpm: preflight-check
	mkdir -p ${ENV_BUILD_CACHE}/tar_rpm;
	for releasever in 8 9 ; do \
	docker run -i -p 5050:5000 --rm --name bundler \
	-w /workingdir \
	--mount type=bind,source="`pwd`/scripts",target=/scripts \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/workingdir \
	--entrypoint /bin/sh \
	-e INSTALL_RKE2_VERSION=${RKE2_VERSION} \
	rockylinux:$${releasever} -c "yum install -y tar --downloadonly --downloaddir .cache"; \
	done



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


# compress all files previously collected
.PHONY: compress-all
compress-all: preflight-check

	# compress the tar directory
	tar -C ${ENV_BUILD_CACHE} -czf ${ENV_BUILD_CACHE}/payload.tgz rke2

	# seed the to_the_airgap.sh with deploy.sh]
	rm -f ${ENV_BUILD_CACHE}/to_the_airgap.sh;
	cp scripts/deploy.sh ${ENV_BUILD_CACHE}/to_the_airgap.sh

	# add the tar rpm to the end of to_the_airgap.sh
	cat ${ENV_BUILD_CACHE}/tar*.el8.*.rpm | base64 -w0 >> ${ENV_BUILD_CACHE}/to_the_airgap.sh

	# add the tar payload to the end of to_the_airgap.sh
	cat ${ENV_BUILD_CACHE}/payload.tgz | base64 -w0 >> ${ENV_BUILD_CACHE}/to_the_airgap.sh
	



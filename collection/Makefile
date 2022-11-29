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
	podman run -it -p 5050:5000 --rm --name bundler \
	-w /workingdir \
	--mount type=bind,source="`pwd`/scripts",target=/scripts \
	--mount type=bind,source="${ENV_CONFIG_DIR}",target=/workingdir \
	--entrypoint /bin/sh \
	-e INSTALL_RKE2_VERSION=${RKE2_VERSION} \
	rockylinux:8 /scripts/collect_rke2_dependencies.sh;


# compress all files previously collected
.PHONY: compress-all
compress-all: preflight-check
	tar -C ${ENV_BUILD_CACHE} -czf ${ENV_BUILD_CACHE}/payload.tgz rke2 
# glowing-tribble.tar registrydb.tar.gz registry_image.tar dep_spec.tar cert-manager.tar fileserver
	cp scripts/deploy.sh ${ENV_BUILD_CACHE}/to_the_airgap.sh
# cat ${ENV_BUILD_CACHE}/payload.tgz >> ${ENV_BUILD_CACHE}/to_the_airgap.sh

# cat ${ENV_BUILD_CACHE}/payload.tgz | base64 | sed 's/<payloadbase64>/something/g' - ${ENV_BUILD_CACHE}/to_the_airgap.sh
# cat ${ENV_BUILD_CACHE}/tar.rpm | base64 | awk '{ your_program }' - ${ENV_BUILD_CACHE}/to_the_airgap.sh

# sed s$'\001'"<Doc>###%DOCDATA%###<\/Doc>"$'\001'"<Doc>$(cat ./sample.xml | base64)<\/Doc>"$'\001'g


#	sed "s/payloadbase64/$(cat ${ENV_BUILD_CACHE}/payload.tgz | base64 -w0)/g" -i ${ENV_BUILD_CACHE}/to_the_airgap.sh


# cat ${ENV_BUILD_CACHE}/payload.tgz | base64 -w0 > ${ENV_BUILD_CACHE}/payload.tgz.b64
# sed -i '/payloadbase64/{
# s/payloadbase64//g
# r ${ENV_BUILD_CACHE}/payload.tgz.b64
# }' ${ENV_BUILD_CACHE}/to_the_airgap.sh

	echo 'cat < EOF' >> ${ENV_BUILD_CACHE}/to_the_airgap.sh
	echo $(cat payload.tar | base64 -w0) >> ${ENV_BUILD_CACHE}/to_the_airgap.sh
	echo 'EOF' >> ${ENV_BUILD_CACHE}/to_the_airgap.sh

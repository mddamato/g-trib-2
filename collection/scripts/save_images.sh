#!/bin/bash


set -ex
yum install -y skopeo curl git pigz tar && \
    curl -LO https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.8.2-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -f helm-v3.8.2-linux-amd64.tar.gz && \
    rm -rf linux-amd64

# pullImages() {


#     pulled=""
#     while IFS= read -r i; do
#         [ -z "${i}" ] && continue
#         echo "${i}"
#         # skopeo sync --src docker --dest dir "${i}" /config/.cache/registry/db
#         # if podman pull "${i}" > /dev/null 2>&1; then
#         #     echo "Image pull success: ${i}"
#         #     pulled="${pulled} ${i}"
#         # else
#         #     if podman inspect "${i}" > /dev/null 2>&1; then
#         #         pulled="${pulled} ${i}"		
#         #     else
#         #         echo "Image pull failed: ${i}"
#         #     fi
#         # fi
#     done < "${1}"

# }

mkdir -p /config/.cache/registry/db
skopeo sync --keep-going --src yaml --dest dir /config/registry_images.yml /config/.cache/registry/db

# for arg do
#   printf '%s\n' "Arg $i: $arg"
#   i=$((i + 1))

#     while IFS= read -r i; do
#         [ -z "${i}" ] && continue

#         podman pull "${i}"
#         podman save "${i}" --format docker-dir -o /config/.cache/registry/db
#         echo "${i}"

#     done < "${arg}"

# done
#!/bin/bash


set -ex
yum install -y podman curl git pigz tar && \
    curl -LO https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.8.2-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -f helm-v3.8.2-linux-amd64.tar.gz && \
    rm -rf linux-amd64

pullImages() {


    pulled=""
    while IFS= read -r i; do
        [ -z "${i}" ] && continue
        echo "${i}"
        # skopeo sync --src docker --dest dir "${i}" /config/.cache/registry/db
        # if podman pull "${i}" > /dev/null 2>&1; then
        #     echo "Image pull success: ${i}"
        #     pulled="${pulled} ${i}"
        # else
        #     if podman inspect "${i}" > /dev/null 2>&1; then
        #         pulled="${pulled} ${i}"		
        #     else
        #         echo "Image pull failed: ${i}"
        #     fi
        # fi
    done < "${1}"

}

mkdir -p /config/.cache/registry/db
for arg do
  printf '%s\n' "Arg $i: $arg"
  i=$((i + 1))


  #skopeo sync --src docker --dest dir --all $(sed ':a;N;$!ba;s/\n/ /g' config/my-env/registry_images.txt) /config/.cache/registry/db


  #pullImages $arg

done
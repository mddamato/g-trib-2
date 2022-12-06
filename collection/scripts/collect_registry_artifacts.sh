#!/bin/sh

set -ex
apk add docker openrc bash curl git pigz tar && \
    curl -LO https://get.helm.sh/helm-v3.8.2-linux-amd64.tar.gz && \
    tar -zxvf helm-v3.8.2-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -f helm-v3.8.2-linux-amd64.tar.gz && \
    rm -rf linux-amd64


collect_images () {
/bin/bash -c "/entrypoint.sh /etc/docker/registry/config.yml" > .cache/registry.log 2>&1 &
# wait for registry
sleep 3
i=1
#Pull images to local system
for arg do
  printf '%s\n' "Arg $i: $arg"
  i=$((i + 1))
  /scripts/pull-images.sh --image-list $arg --images $arg.tar.gz
done

i=1
#Push images to local registry
for arg do
  printf '%s\n' "Arg $i: $arg"
  i=$((i + 1))
  /scripts/push-images.sh --image-list $arg --images $arg.tar.gz --registry localhost:5050
done
};

compress_dependencies () {
tar -C /workingdir/.cache -cf /workingdir/.cache/registrydb.tar registrydb
pigz --force -9 /workingdir/.cache/registrydb.tar
};

#build util and fileserver
##determine version of kubectl that matches rke2
docker build -t util --build-arg SSH_KEY="$(cat /collection/utility/id_rsa)" --build-arg KUBE_VER="$(grep RKE2_VERSION /workingdir/Makefile | awk -F\= '{ print $2 }' | awk -F\+ '{ print $1 }' | xargs)" - < /collection/utility/Dockerfile
docker build -t fileserver - < /collection/fileserver/Dockerfile

#append util and fileserver to arg list
# Collect all dependencies
collect_images $*;

#DOCKER COMMANDS ARE BEING RAN FROM THE HOST, NOT INTERNALLY, SO NEED TO USE DIFFERENT PORT HERE
helm repo add jetstack https://charts.jetstack.io
helm fetch jetstack/cert-manager --version 1.7.1
helm push cert-manager-v1.7.1.tgz oci://localhost:5000/helm-charts
rm -rf cert-manager-v1.7.1.tgz

helm repo add traefik https://helm.traefik.io/traefik
helm fetch traefik/traefik --version 10.19.3
helm push traefik-10.19.3.tgz oci://localhost:5000/helm-charts
rm -rf traefik-10.19.3.tgz

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm fetch rancher-stable/rancher --version 2.6.9
helm push rancher-2.6.9.tgz oci://localhost:5000/helm-charts
rm -rf rancher-2.6.9.tgz

#add util and fileserver to database
docker tag util localhost:5050/util-linux-amd64
docker push localhost:5050/util-linux-amd64

docker tag fileserver localhost:5050/fileserver-linux-amd64
docker push localhost:5050/fileserver-linux-amd64

#collect registry image
compress_dependencies;

docker save -o .cache/registry_image.tar registry

exit 0

# g-trib-2

## Overall Stages

Requirements:
- curl -LO https://github.com/mozilla/sops/releases/download/v3.7.3/sops-3.7.3-1.x86_64.rpm
- sudo yum install -y make git podman skopeo gnupg pinentry ./sops-*.rpm
- git clone https://github.com/mddamato/g-trib-2.git /opt/g-trib-2
- cd /opt/g-trib-2/collection
- gpg --list-keys
- # place keys in home directory
- gpg --import ${HOME}/public.pgp
- gpg --import ${HOME}/private.pgp
- rm -f ${HOME}/public.pgp ${HOME}/private.pgp

Example command:
- make ENVIRONMENT=my-env SECRETS_FILE=config/my-env/secret_mdd.env collect-rke2-dependencies collect-tar-rpm collect-images hoppr compress-all


Dependencies to collect:
- RKE2 single node airgap script tar file
- registry image tar file
- registry pod spec yaml file
- init script bash file
- registry database tar file:
  - traefik
  - rancher
  - utility image
  - helm charts?



Install process:
1) Dependency Collection
   1) A tar file containing the util image:
      1) Terraform installed
      2) ansible installed
   2) RKE2 Bundle
   3) glowing-tribble git repo tar
   4) Registry Database
   5) Registry Image Tar file
   6) Ship to existing Jumpbox in airgap
   7) Build Util image and push to registry
   8) Build file-server image and push to registry
2) Configure Jumpbox with Jumpbox config script
   1) Install RKE2
   2) Set up registry
      1) place registry image in /images directory
      2) place registry pod spec into /manifests directory
      3) extract image registry database
   3) Set up Util
      1) place util pod spec into /manifests directory
      2) extract glowing-tribble git repo tar file to /var/lib/rancher/hostPaths/util
   4) Set up RPM server
      1) extract RPM file server database
      2) place RPM file server pod spec in /manifests
3) Start RKE2-Server
4) Terraform to build infrastructure (kubectl exec -it util -- make terra)
   1) Build HAProxy VMs
   2) Build local cluster VMs
   3) Build downstream cluster VMs
5) Run Ansible
   1) HA Proxy configuration and installation
   2) Install RKE2 on local cluster
   3) Install RKE2 on downstream clusters
   4) HAProxy Installation on dedicated VM


6) Helm chart deployments
   1) Metal LB
   2) Traefik
   3) Rancher





# Devel

docker build -t util -f Dockerfile-util .

docker run --rm -it \
-v $(pwd):/mnt -w /mnt \
--network host util

# Offline

docker build -t util -f Dockerfile-util-airgap .


# RKE2 Airgap Package:

curl -LO https://rfed-public.s3-us-gov-east-1.amazonaws.com/bundles/rke-government-deps-offline-bundle-el8-v1.23.5%2Brke2r1.tar.gz
tar xzf rke-government-deps-offline-bundle-el8-v1.23.5%2Brke2r1.tar.gz
sudo chmod +x install.sh && sudo ./install.sh

# PGP Notes

gpg --output public.pgp --armor --export C21FDF0CBD8D0CDE890B6CE9B1EAF7DF3D0A1F1A
gpg --output private.pgp --armor --export-secret-key C21FDF0CBD8D0CDE890B6CE9B1EAF7DF3D0A1F1A

sops --config config/my-env/.sops.yaml --encrypt /home/admin/g-trib-2/collection/config/my-env/secret_mdd.env

sops --config config/my-env/.sops.yaml --encrypt /home/admin/g-trib-2/collection/config/my-env/secret_ajm.env

sops --config config/my-env/.sops.yaml --decrypt config/my-env/hoppr/credentials.yaml > config/my-env/.cache/secrets

sops --config config/my-env/.sops.yaml updatekeys config/my-env/hoppr/credentials.yaml

sops --config config/my-env/.sops.yaml config/my-env/secret_mdd.env

## note
	REG1_PASSWORD=`sops --config ${ENV_CONFIG_DIR}/.sops.yaml --output-type yaml --decrypt --extract '["credential_required_services"][0]["pass"]' config/my-env/hoppr/credentials.yaml`
	REG1_USERNAME=`sops --config ${ENV_CONFIG_DIR}/.sops.yaml --output-type yaml --decrypt --extract '["credential_required_services"][0]["user"]' config/my-env/hoppr/credentials.yaml`
	podman login --username $$REG1_USERNAME --password $$REG1_PASSWORD registry1.dso.mil
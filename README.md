# g-trib-2

## Overall Stages

Requirements:
- yum install -y make git podman
- alias docker=podman
- 
- sysctl user.max_user_namespaces=15000
- git clone https://github.com/mddamato/g-trib-2.git /opt/g-trib-2
- cd /opt/g-trib-2/collection

Example command:
- make collect-rke2-dependencies ENVIRONMENT=my-env


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
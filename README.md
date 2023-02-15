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





# generating test certificates

> These are stored as registry_certs.yaml and ca_certs.yaml in the secrets directory

```shell
cat > CA_Issuer_Bootstrap.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: glowing-tribble
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-issuer
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: g-trib-ca
  namespace: glowing-tribble
spec:
  isCA: true
  commonName: g-trib-ca
  secretName: root-secret
  duration: 26280h
  privateKey:
    algorithm: ECDSA
    size: 521
  issuerRef:
    name: selfsigned-issuer
    kind: ClusterIssuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: g-trib-issuer
  namespace: glowing-tribble
spec:
  ca:
    secretName: root-secret
EOF
kubectl apply -f CA_Issuer_Bootstrap.yaml

cat > registry_cert.yaml <<EOF
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: registry-glowing-tribble-com
  namespace: glowing-tribble
spec:
  secretName: registry-glowing-tribble-com-tls
  duration: 8760h
  renewBefore: 360h
  subject:
    organizations:
      - Glowing-Tribble-Mega-Corporation
  commonName: registry.glowing-tribble.com
  isCA: false
  privateKey:
    algorithm: ECDSA
    size: 521
  usages:
    - server auth
    - client auth
  dnsNames:
    - registry.glowing-tribble.com
    - registry.glowing-tribble.svc.cluster.local
    - www.registry.glowing-tribble.com
  issuerRef:
    name:  g-trib-issuer
    kind: Issuer
    group: cert-manager.io
EOF
kubectl apply -f registry_cert.yaml

kubectl get secret registry-glowing-tribble-com-tls -n glowing-tribble -o yaml
kubectl get secret root-secret -n glowing-tribble -o yaml

kubectl delete -f registry_cert.yaml
kubectl delete -f CA_Issuer_Bootstrap.yaml
```

# vault notes

vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write pki/root/generate/internal common_name=glowing-tribble.com ttl=87600h
vault write pki/config/urls issuing_certificates="http://vault.glowing-tribble.com:8200/v1/pki/ca" crl_distribution_points="http://vault.glowing-tribble.com:8200/v1/pki/crl"
vault write pki/roles/example-dot-com \
    allowed_domains=example.com \
    allow_subdomains=true max_ttl=72h

vault write pki/issue/example-dot-com \
    common_name=blah.example.com


## vault init

mkdir -p /vault/data/tmp
vault operator init > /vault/data/tmp/init.out
export VAULT_TOKEN=$(grep Token /vault/data/tmp/init.out | cut -d' ' -f  4)
echo $VAULT_TOKEN > /vault/data/tmp/key
export MIN_MASTER_KEYS=$(cat /vault/data/tmp/init.out | grep -e "2:\|3:\|4:" |  awk '{print $4}')

for key in $MIN_MASTER_KEYS
do
  vault operator unseal $key
done

until vault login -no-store $VAULT_TOKEN >& /dev/null; do echo "Waiting to login to vault"; sleep 5; done;

vault auth enable kubernetes

vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  issuer="https://kubernetes.default.svc.cluster.local"   
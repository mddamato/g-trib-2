#Script to extract embedded tarball and configure the jumpbox with Secure registry, fileserver, utility-server, and cert-manager

process_tar() {
  cd $WORK_DIR

  setenforce 0

  cd rke2
  sh install.sh
  cd ..

#   mv registry_image.tar /var/lib/rancher/rke2/agent/images/.
#   mkdir -p /var/lib/rancher/rke2/server/manifests
#   tar -xf dep_spec.tar
#   rm -rf dep_spec.tar 
#   mv registry/registry*.yaml /var/lib/rancher/rke2/server/manifests/.
#   rm -rf registry  
#   mkdir /var/lib/rancher/hostPaths
#   tar -xzf registrydb.tar.gz -C /var/lib/rancher/hostPaths/
#   rm -rf registrydb.tar.gz

#   tar -xf glowing-tribble.tar -C /var/lib/rancher/hostPaths/
#   rm -rf glowing-tribble.tar

#   mv fileserver /var/lib/rancher/hostPaths/
#   tar -xzf rke2/rke_rpm_deps.tar.gz -C /var/lib/rancher/hostPaths/fileserver/
#   rm -rf rke2

#   #Enable insecure registry so we can pull down cert-manager
#   cat > /etc/rancher/rke2/registries.yaml << EOF
# mirrors:
#   glowing-tribble:30000:
#     endpoint:
#       - "http://glowing-tribble:30000"
# EOF

  #Disable nginx ingress controller
  cat > /etc/rancher/rke2/config.yaml << EOF
disable:
  - rke2-ingress-nginx
EOF

  echo "Starting RKE2 Server Serivce.  This will take a few minutes."
  systemctl start rke2-server

  #Configure kubectl

  cat >> ~/.bashrc <<EOF
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
export KU_NS=default
alias ku="kubectl -n \\\$KU_NS"
EOF
  source ~/.bashrc

  #Install HELM
  # tar -xf cert-manager.tar
  # rm -rf cert-manager.tar
  # cp /var/lib/rancher/hostPaths/fileserver/helm-v3.8.2-linux-amd64.tar.gz .
  # tar -zxf helm-v3.8.2-linux-amd64.tar.gz
  # mv linux-amd64/helm /usr/local/bin/helm
  # rm -f helm-v3.8.2-linux-amd64.tar.gz
  # rm -rf linux-amd64

  #Wait for registry to become available
  # REG=`kubectl get pods -A | grep registry-insecure | awk '{ print $2 }'`  
  # while [ -z "$REG" ]; do
  #   sleep 5 
  #   REG=`kubectl get pods -A | grep registry-insecure | awk '{ print $2 }'`
  # done
  # kubectl wait --for=condition=ready pod $REG -n glowing-tribble --timeout=300s

  #Pull helm chart and cert-manager
#   kubectl apply -f /tmp/cert-manager.crds.yaml
#   rm -rf /tmp/cert-manager.crds.yaml
#   sleep 3
#   helm pull oci://localhost:30000/helm-charts/cert-manager --version v1.7.1
#   helm install cert-manager cert-manager-v1.7.1.tgz --namespace cert-manager --create-namespace --version v1.7.1 --wait \
# --set image.repository=glowing-tribble:30000/quay.io/jetstack/cert-manager-controller \
# --set webhook.image.repository=glowing-tribble:30000/quay.io/jetstack/cert-manager-webhook \
# --set cainjector.image.repository=glowing-tribble:30000/quay.io/jetstack/cert-manager-cainjector \
# --set startupapicheck.image.repository=glowing-tribble:30000/quay.io/jetstack/cert-manager-ctl
#   rm -rf cert-manager-v1.7.1.tgz

#   cat > cert-manager.yaml << EOF
# ---
# apiVersion: cert-manager.io/v1
# kind: ClusterIssuer
# metadata:
#   name: selfsigned-issuer
# spec:
#   selfSigned: {}
# ---
# apiVersion: cert-manager.io/v1
# kind: Certificate
# metadata:
#   name: selfsigned-ca
#   namespace: cert-manager
# spec:
#   isCA: true
#   commonName: selfsigned-ca
#   secretName: root-secret
#   duration: 52596h
#   renewBefore: 43830h
#   privateKey:
#     algorithm: ECDSA
#     size: 256
#   issuerRef:
#     name: selfsigned-issuer
#     kind: ClusterIssuer
#     group: cert-manager.io
# ---
# apiVersion: cert-manager.io/v1
# kind: ClusterIssuer
# metadata:
#   name: ca-issuer
# spec:
#   ca:
#     secretName: root-secret
# ---
# apiVersion: cert-manager.io/v1
# kind: Certificate
# metadata:
#   name: glowing-tribble
#   namespace: glowing-tribble
# spec:
#   # Secret names are always required.
#   secretName: glowing-tribble-tls
#   duration: 2160h # 90d
#   renewBefore: 360h # 15d

#   # The use of the common name field has been deprecated since 2000 and is
#   # discouraged from being used.
#   commonName: glowing-tribble
#   isCA: false
#   privateKey:
#     algorithm: RSA
#     encoding: PKCS1
#     size: 2048
#   usages:
#     - server auth
#     - client auth
#   dnsNames:
#     - glowing-tribble
#   issuerRef:
#     name: ca-issuer
#     kind: ClusterIssuer
# EOF

  # kubectl apply -f cert-manager.yaml
  # rm -rf cert-manager.yaml

  #Wait for certs to be added to the secret and add ca cert to the system chain
  # CERT=`kubectl get secret -n glowing-tribble | grep glowing-tribble-tls`
  # while [ -z "$CERT" ]; do
  #   sleep 5 
  #   CERT=`kubectl get secret -n glowing-tribble | grep glowing-tribble-tls`
  # done
  # CERT_ROOT=`kubectl get secret -n cert-manager | grep root-secret`
  # while [ -z "$CERT_ROOT" ]; do
  #   sleep 5 
  #   TLS=`kubectl get secret -n cert-manager | grep root-secret`
  # done

  # kubectl get secret root-secret -n cert-manager -o jsonpath='{.data.tls\.crt}' | base64 -d > tls_root.crt

  # mv tls_root.crt /etc/pki/ca-trust/source/anchors/glowing-tribble-ca.crt
  # update-ca-trust extract

  # systemctl restart rke2-server

  #Wait for secure registry to come online before pulling anything else.  Could disable insecure registry at this point.
#   REG=`kubectl get pods -A | grep registry | grep -v -insecure | awk '{ print $2 }'`  
#   kubectl wait --for=condition=ready pod ${REG} -n glowing-tribble --timeout=300s

#   kubectl apply -f utility/utility.yaml
#   kubectl apply -f /var/lib/rancher/hostPaths/fileserver/fileserver.yaml
#   rm -rf utility /var/lib/rancher/hostPaths/fileserver/fileserver.yaml

#   cat >> ~/.bashrc <<EOF
# export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
# export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin
# export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
# #export KU_NS=default
# #alias ku="kubectl -n \\\$KU_NS"
# alias ku="kubectl"
# EOF
# source ~/.bashrc
}

# IPADDR=`ip -f inet addr show ens192 | awk '/inet / {print $2}' | awk -F\/ '{print $1}'`
# echo "${IPADDR}   glowing-tribble" >> /etc/hosts

#yum install -y tar;

# line number where payload starts
#PAYLOAD_LINE=$(awk '/^__PAYLOAD_BEGINS__/ { print NR + 1; exit 0; }' $0)

# directory where a tarball is to be extracted
WORK_DIR=/tmp

# extract the embedded tar file
#tail -n +${PAYLOAD_LINE} $0 | tar -zpvx -C $WORK_DIR

#cat $WORK_DIR/payload.tgz.b64 | base64 -d > payload.tgz
cat $0 | tail -1 | head -1 | base64 -d > payload.tgz
tar -zvxf $WORK_DIR/payload.tgz -C $WORK_DIR

# perform actions with the extracted content
process_tar


#__PAYLOAD_BEGINS__




exit 0
# cat > tar.rpm <<EOF
# tarrpmbase64
# EOF

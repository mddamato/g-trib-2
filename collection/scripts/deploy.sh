
process_tar() {
  cd $WORK_DIR

  setenforce 0

  cd rke2
  PATH=$PATH:$WORK_DIR/tar sh install.sh
  cd ..


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


}

WORK_DIR=/tmp

cat $0 | tail -2 | head -1 | tr -d '\n' | base64 -d > $WORK_DIR/tar
export PATH=$PATH:$WORK_DIR/tar
chmod +x $WORK_DIR/tar

cat $0 | tail -1 | tr -d '\n' | base64 -d > $WORK_DIR/payload.tgz
$WORK_DIR/tar -zvxf $WORK_DIR/payload.tgz -C $WORK_DIR

# perform actions with the extracted content
process_tar

exit 0

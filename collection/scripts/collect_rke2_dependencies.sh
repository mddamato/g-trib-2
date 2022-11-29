#!/bin/bash

# Pass in INSTALL_RKE2_VERSION to set version to download
# -e INSTALL_RKE2_VERSION=v1.21.11+rke2r1

set -e

SKIP_IMAGES_DL=${SKIP_IMAGES_DL:-'false'}

setup_env() {


  INSTALL_RKE2_CHANNEL="stable"
  INSTALL_RKE2_METHOD="yum"
  # --- bail if we are not root ---
  if [ ! $(id -u) -eq 0 ]; then
      fatal "You need to be root to perform this install"
  fi

  # --- make sure install type has a value
  if [ -z "${INSTALL_RKE2_TYPE}" ]; then
      INSTALL_RKE2_TYPE="server"
  fi

  if [ -z "${INSTALL_RKE2_AGENT_IMAGES_DIR}" ]; then
      INSTALL_RKE2_AGENT_IMAGES_DIR="/var/lib/rancher/rke2/agent/images"
  fi
}

setup_arch() {
  case ${ARCH:=$(uname -m)} in
  amd64)
      ARCH=amd64
      SUFFIX=$(uname -s | tr '[:upper:]' '[:lower:]')-${ARCH}
      ;;
  x86_64)
      ARCH=amd64
      SUFFIX=$(uname -s | tr '[:upper:]' '[:lower:]')-${ARCH}
      ;;
  *)
      fatal "unsupported architecture ${ARCH}"
      ;;
  esac
}

get_release_version() {
  if [ -n "${INSTALL_RKE2_COMMIT}" ]; then
      version="commit ${INSTALL_RKE2_COMMIT}"
  elif [ -n "${INSTALL_RKE2_VERSION}" ]; then
      version=${INSTALL_RKE2_VERSION}
  else
      echo "finding release for channel ${INSTALL_RKE2_CHANNEL}"
      INSTALL_RKE2_CHANNEL_URL=${INSTALL_RKE2_CHANNEL_URL:-'https://update.rke2.io/v1-release/channels'}
      version_url="${INSTALL_RKE2_CHANNEL_URL}/${INSTALL_RKE2_CHANNEL}"
      version=$(curl -w "%{url_effective}" -L -s -S ${version_url} -o /dev/null | sed -e 's|.*/||')
      INSTALL_RKE2_VERSION="${version}"
  fi
}

install_conf() {
  maj_ver="7"
  if [ -r /etc/redhat-release ] || [ -r /etc/centos-release ] || [ -r /etc/oracle-release ]; then
      dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
      maj_ver=$(echo "$dist_version" | sed -E -e "s/^([0-9]+)\.?[0-9]*$/\1/")
      case ${maj_ver} in
          7|8)
              :
              ;;
          *) # In certain cases, like installing on Fedora, maj_ver will end up being something that is not 7 or 8
              maj_ver="7"
              ;;
      esac
  fi
  case "${INSTALL_RKE2_CHANNEL}" in
      v*.*)
          # We are operating with a version-based channel, so we should parse our version out
          rke2_majmin=$(echo "${INSTALL_RKE2_CHANNEL}" | sed -E -e "s/^v([0-9]+\.[0-9]+).*/\1/")
          rke2_rpm_channel=$(echo "${INSTALL_RKE2_CHANNEL}" | sed -E -e "s/^v[0-9]+\.[0-9]+-(.*)/\1/")
          # If our regex fails to capture a "sane" channel out of the specified channel, fall back to `stable`
          if [ "${rke2_rpm_channel}" = ${INSTALL_RKE2_CHANNEL} ]; then
              info "using stable RPM repositories"
              rke2_rpm_channel="stable"
          fi
          ;;
      *)
          get_release_version
          rke2_majmin=$(echo "${INSTALL_RKE2_VERSION}" | sed -E -e "s/^v([0-9]+\.[0-9]+).*/\1/")
          rke2_rpm_channel=${1}
          ;;
  esac
  echo "using ${rke2_majmin} series from channel ${rke2_rpm_channel}"
  rpm_site="rpm.rancher.io"
  if [ "${rke2_rpm_channel}" = "testing" ]; then
      rpm_site="rpm-${rke2_rpm_channel}.rancher.io"
  fi
  rm -f /etc/yum.repos.d/rancher-rke2*.repo
  cat <<-EOF >"/etc/yum.repos.d/rancher-rke2.repo"
[rancher-rke2-common-${rke2_rpm_channel}]
name=Rancher RKE2 Common (${1})
baseurl=https://${rpm_site}/rke2/${rke2_rpm_channel}/common/centos/${maj_ver}/noarch
enabled=1
gpgcheck=1
gpgkey=https://${rpm_site}/public.key
[rancher-rke2-${rke2_majmin}-${rke2_rpm_channel}]
name=Rancher RKE2 ${rke2_majmin} (${1})
baseurl=https://${rpm_site}/rke2/${rke2_rpm_channel}/${rke2_majmin}/centos/${maj_ver}/x86_64
enabled=1
gpgcheck=1
gpgkey=https://${rpm_site}/public.key
EOF
  rke2_rpm_version=$(echo "${INSTALL_RKE2_VERSION}" | sed -E -e "s/[\+-]/~/g" | sed -E -e "s/v(.*)/\1/")
}

fatal() {
  echo "$!"
  exit
}

do_download() {

  if [ "${SKIP_IMAGES_DL}" = "false" ]; then
    curl -LO ${RKE_IMAGES_DL_SHASUM}

    if [ "${OLD_ASSETS}" == 1 ]; then
      # OLD SCHEMA: rke2-images.
      # grab and verify rke2.images
      curl -LO ${RKE_CORE_IMAGES_DL_URL};
      CHECKSUM_ACTUAL=$(sha256sum "rke2-images.linux-amd64.tar.zst" | awk '{print $1}');
      CHECKSUM_EXPECTED=$(grep "rke2-images.linux-amd64.tar.zst" "sha256sum-amd64.txt" | awk '{print $1}');
      if [ "${CHECKSUM_EXPECTED}" != "${CHECKSUM_ACTUAL}" ]; then echo "FATAL: RKE_CORE_IMAGES_DL_URL download sha256 does not match"; exit 1; fi

    else
      # NEW SCHEMA: rke2-images-core, rke2-images-canal
      # grab and verify rke2-images-core
      curl -LO ${RKE_CORE_IMAGES_DL_URL};
      CHECKSUM_ACTUAL=$(sha256sum "rke2-images-core.linux-amd64.tar.zst" | awk '{print $1}');
      CHECKSUM_EXPECTED=$(grep "rke2-images-core.linux-amd64.tar.zst" "sha256sum-amd64.txt" | awk '{print $1}');
      if [ "${CHECKSUM_EXPECTED}" != "${CHECKSUM_ACTUAL}" ]; then echo "FATAL: RKE_CORE_IMAGES_DL_URL download sha256 does not match"; exit 1; fi
      # grab and verify rke2-images-canal
      curl -LO ${RKE_CANAL_IMAGES_DL_URL};
      CHECKSUM_ACTUAL=$(sha256sum "rke2-images-canal.linux-amd64.tar.zst" | awk '{print $1}');
      CHECKSUM_EXPECTED=$(grep "rke2-images-canal.linux-amd64.tar.zst" "sha256sum-amd64.txt" | awk '{print $1}');
      if [ "${CHECKSUM_EXPECTED}" != "${CHECKSUM_ACTUAL}" ]; then echo "FATAL: RKE_CANAL_IMAGES_DL_URL download sha256 does not match"; exit 1; fi
    fi


    # Grab binaries
    curl -LO ${RKE_BINARIES_DL_URL};
    rm -f sha256sum-amd64.txt
  fi

  # download all rpms and their dependencies
  case ${maj_ver} in
    7)
      mkdir rke_rpm_deps;
      cd rke_rpm_deps;
      yum install -y --releasever=/ --installroot=$(pwd) --downloadonly --downloaddir $(pwd) ${YUM_PACKAGES};
      createrepo -v .;
      cd ..;
      tar -cvf rke_rpm_deps.tar rke_rpm_deps;
      rm -rf rke_rpm_deps;
      pigz rke_rpm_deps.tar
      ;;
    8)
      dnf install -y epel-release
      ## download from epel when packages are fixed
      curl -LO http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages/modulemd-tools-0.7-4.el8.noarch.rpm
      dnf install -y ./modulemd-tools-0.7-4.el8.noarch.rpm;
      rm -f modulemd-tools-0.7-4.el8.noarch.rpm

      mkdir -p rke_rpm_deps/Packages;
      cd rke_rpm_deps/Packages;
      yum install -y --releasever=/ --installroot=$(pwd) --downloadonly --downloaddir $(pwd) ${YUM_PACKAGES};
      cd ..
      createrepo_c .;
      repo2module  -s stable -d . modules.yaml;
      modifyrepo_c --mdtype=modules ./modules.yaml ./repodata;
      cd ..;
      tar -cvf rke_rpm_deps.tar rke_rpm_deps;
      rm -rf rke_rpm_deps;
      pigz rke_rpm_deps.tar
      ;;
    *)
      :
      ;;
  esac
}

setup_env
setup_arch
install_conf "stable"

RKE2_VERSION_SUFFIX=${rke2_rpm_version#*\~}
RKE2_VERSION_FULL=${rke2_rpm_version%\~*}
YUM_PACKAGES="unzip rke2-server-$rke2_rpm_version rke2-agent-$rke2_rpm_version"

# test to see what asset schema we are on. Newer versions split everything out. Older versions only use rke2-images.
if [[ $(curl -sIL -w "%{http_code}" "https://github.com/rancher/rke2/releases/download/v${RKE2_VERSION_FULL}%2B${RKE2_VERSION_SUFFIX}/rke2-images-canal.linux-amd64.tar.zst") != 200 ]]; then
  OLD_ASSETS=1
else
  OLD_ASSETS=0
fi

# We need these for all schemas
RKE_IMAGES_DL_SHASUM="https://github.com/rancher/rke2/releases/download/v${RKE2_VERSION_FULL}%2B${RKE2_VERSION_SUFFIX}/sha256sum-amd64.txt"
RKE_BINARIES_DL_URL="https://github.com/rancher/rke2/releases/download/v${RKE2_VERSION_FULL}%2B${RKE2_VERSION_SUFFIX}/rke2.linux-amd64.tar.gz"

if [ "${OLD_ASSETS}" == 1 ]; then
  RKE_CORE_IMAGES_DL_URL="https://github.com/rancher/rke2/releases/download/v${RKE2_VERSION_FULL}%2B${RKE2_VERSION_SUFFIX}/rke2-images.linux-amd64.tar.zst"
else
  # NEW SCHEMA: rke2-images-core, rke2-images-canal
  RKE_CORE_IMAGES_DL_URL="https://github.com/rancher/rke2/releases/download/v${RKE2_VERSION_FULL}%2B${RKE2_VERSION_SUFFIX}/rke2-images-core.linux-amd64.tar.zst"
  RKE_CANAL_IMAGES_DL_URL="https://github.com/rancher/rke2/releases/download/v${RKE2_VERSION_FULL}%2B${RKE2_VERSION_SUFFIX}/rke2-images-canal.linux-amd64.tar.zst"
fi


# create a working directory, install dependency collection dependencies
rm -rf .cache/rke2
workdir=.cache/rke2
mkdir -p $workdir;
cd $workdir;
yum install -y pigz yum-utils createrepo unzip epel-release tar;

do_download
if [ "${OLD_ASSETS}" == 1 ]; then
  cat <<-EOFF > install.sh
    #!/bin/bash

    # # Unpack
    # tar xzvf rke-government-deps-*.tar.gz

    INSTALL_TYPE=\${1:-"server"}

    if [ "\$INSTALL_TYPE" != "agent" ] && [ "\$INSTALL_TYPE" != "server" ] ; then
      echo "Input INSTALL_TYPE must be either \"agent\" or \"server\""
      echo "Example: ./install.sh agent"
      exit 1
    fi

    if [ \$# -eq 0 ]
      then
        echo "Defaulting to \"server\" type install. Pass in \"agent\" as parameter to install agent"
        echo "Example: ./install.sh agent"
    fi

    # Check if you can run Yum
    if command -v yum >/dev/null 2>&1; then

      # RHEL/Centos: Install using Yum
      # Make repo directory
      mkdir -p /var/lib/rancher/yum_repos

      # Unpack rpm repo into repo directory
      tar xzf rke_rpm_deps.tar.gz -C /var/lib/rancher/yum_repos

      # Create local rpm repo configuration
      echo "[rke_rpm_deps]" > /etc/yum.repos.d/rke_rpm_deps.repo
      echo "name=rke_rpm_deps" >> /etc/yum.repos.d/rke_rpm_deps.repo
      echo "baseurl=file:///var/lib/rancher/yum_repos/rke_rpm_deps" >> /etc/yum.repos.d/rke_rpm_deps.repo
      echo "enabled=0" >> /etc/yum.repos.d/rke_rpm_deps.repo
      echo "gpgcheck=0" >> /etc/yum.repos.d/rke_rpm_deps.repo

      # Install
      yum install -y --disablerepo=* --enablerepo="rke_rpm_deps" rke2-\${INSTALL_TYPE}

    else

      # Ubuntu: Install using the binaries
      tar xzf ./rke2.linux-amd64.tar.gz
      /usr/bin/cp ./bin/rke2 /usr/local/bin/rke2
      /usr/bin/cp ./bin/rke2-uninstall.sh /usr/local/bin/rke2-uninstall.sh
      /usr/bin/cp ./bin/rke2-killall.sh /usr/local/bin/rke2-killall.sh
      /usr/bin/cp ./lib/systemd/system/rke2-\${INSTALL_TYPE}.env /etc/systemd/system/rke2-\${INSTALL_TYPE}.env
      /usr/bin/cp ./lib/systemd/system/rke2-\${INSTALL_TYPE}.service /etc/systemd/system/rke2-\${INSTALL_TYPE}.service
      /usr/bin/mkdir -p /usr/share/rke2
      /usr/bin/cp ./share/rke2/rke2-cis-sysctl.conf /usr/share/rke2/rke2-cis-sysctl.conf
      systemctl daemon-reload

    fi

    # Make images directory
    mkdir -p /var/lib/rancher/rke2/agent/images/

    # Unpack and copy images into images directory
    cp rke2-images.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/

    echo "Done"
    exit 0

    # # If you're using a CIS profile setting, you need to perform additional steps (https://docs.rke2.io/security/hardening_guide/)
    # cp -f /usr/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
    # systemctl restart systemd-sysctl
    # useradd -r -c "etcd user" -s /sbin/nologin -M etcd

    # Now add RKE2 configuration at /etc/rancher/rke2/config.d/, and start the service with 'systemctl start rke2-server' or 'systemctl start rke2-agent'
    # Configuration reference https://docs.rke2.io/install/install_options/server_config/
    # Configuration reference https://docs.rke2.io/install/install_options/agent_config/
EOFF
else
  cat <<-EOFF > install.sh
    #!/bin/bash

    # # Unpack
    # tar xzvf rke-government-deps-*.tar.gz

    INSTALL_TYPE=\${1:-"server"}

    if [ "\$INSTALL_TYPE" != "agent" ] && [ "\$INSTALL_TYPE" != "server" ] ; then
      echo "Input INSTALL_TYPE must be either \"agent\" or \"server\""
      echo "Example: ./install.sh agent"
      exit 1
    fi

    if [ \$# -eq 0 ]
      then
        echo "Defaulting to \"server\" type install. Pass in \"agent\" as parameter to install agent"
        echo "Example: ./install.sh agent"
    fi

    # Check if you can run Yum
    if command -v yum >/dev/null 2>&1; then

      # RHEL/Centos: Install using Yum
      # Make repo directory
      mkdir -p /var/lib/rancher/yum_repos

      # Unpack rpm repo into repo directory
      tar xzf rke_rpm_deps.tar.gz -C /var/lib/rancher/yum_repos

      # Create local rpm repo configuration
      echo "[rke_rpm_deps]" > /etc/yum.repos.d/rke_rpm_deps.repo
      echo "name=rke_rpm_deps" >> /etc/yum.repos.d/rke_rpm_deps.repo
      echo "baseurl=file:///var/lib/rancher/yum_repos/rke_rpm_deps" >> /etc/yum.repos.d/rke_rpm_deps.repo
      echo "enabled=0" >> /etc/yum.repos.d/rke_rpm_deps.repo
      echo "gpgcheck=0" >> /etc/yum.repos.d/rke_rpm_deps.repo

      # Install
      yum install -y --disablerepo=* --enablerepo="rke_rpm_deps" rke2-\${INSTALL_TYPE}

    else

      # Ubuntu: Install using the binaries
      tar xzf ./rke2.linux-amd64.tar.gz
      /usr/bin/cp ./bin/rke2 /usr/local/bin/rke2
      /usr/bin/cp ./bin/rke2-uninstall.sh /usr/local/bin/rke2-uninstall.sh
      /usr/bin/cp ./bin/rke2-killall.sh /usr/local/bin/rke2-killall.sh
      /usr/bin/cp ./lib/systemd/system/rke2-\${INSTALL_TYPE}.env /etc/systemd/system/rke2-\${INSTALL_TYPE}.env
      /usr/bin/cp ./lib/systemd/system/rke2-\${INSTALL_TYPE}.service /etc/systemd/system/rke2-\${INSTALL_TYPE}.service
      /usr/bin/mkdir -p /usr/share/rke2
      /usr/bin/cp ./share/rke2/rke2-cis-sysctl.conf /usr/share/rke2/rke2-cis-sysctl.conf
      systemctl daemon-reload

    fi

    # Make images directory
    mkdir -p /var/lib/rancher/rke2/agent/images/

    # Unpack and copy images into images directory
    cp rke2-images-core.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/
    cp rke2-images-canal.linux-amd64.tar.zst /var/lib/rancher/rke2/agent/images/

    echo "Done"
    exit 0

    # # If you're using a CIS profile setting, you need to perform additional steps (https://docs.rke2.io/security/hardening_guide/)
    # cp -f /usr/share/rke2/rke2-cis-sysctl.conf /etc/sysctl.d/60-rke2-cis.conf
    # systemctl restart systemd-sysctl
    # useradd -r -c "etcd user" -s /sbin/nologin -M etcd

    # Now add RKE2 configuration at /etc/rancher/rke2/config.d/, and start the service with 'systemctl start rke2-server' or 'systemctl start rke2-agent'
    # Configuration reference https://docs.rke2.io/install/install_options/server_config/
    # Configuration reference https://docs.rke2.io/install/install_options/agent_config/
EOFF
fi


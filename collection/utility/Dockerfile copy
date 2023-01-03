FROM docker.io/redhat/ubi8:latest

WORKDIR /var/lib/utility

# Install systemd -- See https://hub.docker.com/_/centos/
# RUN echo "enabled=0" >> /etc/yum/pluginconf.d/subscription-manager.conf && \
#   yum -y update; yum clean all; \
#   (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
#   rm -f /lib/systemd/system/multi-user.target.wants/*;\
#   rm -f /etc/systemd/system/*.wants/*;\
#   rm -f /lib/systemd/system/local-fs.target.wants/*; \
#   rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
#   rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
#   rm -f /lib/systemd/system/basic.target.wants/*;\
#   rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum makecache --timer \
  && yum -y install initscripts \
  && yum -y update \
  && yum -y install \
  sudo \
  which \
  hostname \
  python3 \
  python3-devel \
  gcc \
  git \
  unzip \
  yum-utils \
  make \
  python38 \
  wget \
  #epel-release \
  jq \
  && yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo \
  && yum install -y terraform \
  && yum clean all 

ARG SSH_KEY
RUN mkdir /root/.ssh/; echo "$SSH_KEY" > /root/.ssh/id_rsa; chmod 0700 /root/.ssh/id_rsa

RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

RUN pip-3.8 install --upgrade pip && \
  pip-3.8 install ansible yamllint ansible-lint

RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

RUN curl -LO https://github.com/mddamato/g-trib-2/archive/refs/heads/main.zip && \
    unzip main.zip && \
    cp -R g-trib-2-main/* . && \
    rm -rf g-trib-2-main && \
    rm -f main.zip

ENTRYPOINT ["/bin/bash", "-c"]

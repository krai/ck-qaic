#!/bin/bash

# Usage: WORKSPACE_DIR=/local/mnt/workspace bash setup_centos.sh

_WORKSPACE_DIR=${WORKSPACE_DIR:-$HOME/MLC2.0}
sudo yum upgrade -y
sudo yum install -y \
  git wget patch vim which \
  zip unzip bzip2-devel \
  openssl-devel libffi-devel \
  lm_sensors ipmitool \
  yum-utils lvm2 device-mapper-persistent-data \
  dnf acl
sudo yum clean all
sudo dnf install python3 python3-pip python3-devel

sudo yum remove -y docker docker-common
sudo yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum list docker-ce --showduplicates | sort -r | head -12
sudo yum install -y docker-ce-20.10.12-3.el7
docker --version

export WORKSPACE_DIR=${_WORKSPACE_DIR}
export WORKSPACE_DOCKER=${_WORKSPACE_DIR}/docker
export DOCKER_DAEMON_JSON=/etc/docker/daemon.json

sudo mkdir -p $WORKSPACE_DOCKER
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo cp /etc/systemd/system/docker.service.d/override.conf{,.bak}
echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd --graph=$WORKSPACE_DOCKER --storage-driver=overlay2" | \
sudo tee -a /etc/systemd/system/docker.service.d/override.conf
cat /etc/systemd/system/docker.service.d/override.conf

sudo systemctl enable docker
sudo systemctl start docker
sudo docker system info

sudo usermod -aG docker $USER

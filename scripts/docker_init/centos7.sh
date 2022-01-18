#!/bin/bash
#Usage: WORKSPACE=/local/mnt/workspace bash centos7.sh
WORKSPACE=${WORKSPACE:-$HOME/MLC2.0}
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

export WORKSPACE=$WORKSPACE
export WORKSPACE_DOCKER=$WORKSPACE/docker
export DOCKER_DAEMON_JSON=/etc/docker/daemon.json

sudo mkdir -p $WORKSPACE_DOCKER
sudo mkdir -p /etc/systemd/system/docker.service.d/
sudo cp /etc/systemd/system/docker.service.d/override.conf{,.bak}
echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd --graph=$WORKSPACE_DOCKER --storage-driver=overlay2" | \
sudo tee -a /etc/systemd/system/docker.service.d/override.conf
cat /etc/systemd/system/docker.service.d/override.conf

sudo systemctl enable docker
sudo systemctl start docker
docker system info

sudo usermod -aG qaic,docker,sudo $USER

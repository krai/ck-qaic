#!/bin/bash
#Usage: WORKSPACE=/local/mnt/workspace ./ubuntu-20.04.sh
WORKSPACE=${WORKSPACE:-$HOME/MLC2.0}
sudo apt upgrade -y
sudo apt install -y \
  git wget patch vim \
  libbz2-dev lzma \
  python3-dev python3-pip \
  lm-sensors ipmitool \
  acl
sudo apt clean all
sudo apt install docker-ce
docker --version

export WORKSPACE=$WORKSPACE
export WORKSPACE_DOCKER=$WORKSPACE/docker
export DOCKER_DAEMON_JSON=/etc/docker/daemon.json

sudo mkdir -p $WORKSPACE_DOCKER
sudo cp $DOCKER_DAEMON_JSON{,.bak}
echo -e "{\n\t\"data-root\": \"$WORKSPACE_DOCKER\"\n}" | sudo tee -a $DOCKER_DAEMON_JSON
cat $DOCKER_DAEMON_JSON

sudo service docker start
docker system info

sudo usermod -aG qaic,docker,sudo $USER

bash ck_init.sh

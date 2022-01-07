#!/bin/bash
WORKSPACE=${WORKSPACE:-$HOME}
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

echo -n "\
export CK_PYTHON=${CK_PYTHON:-$(which python3)}
export CK_WORKSPACE=$WORKSPACE
export CK_TOOLS=$WORKSPACE/$USER/CK-TOOLS
export CK_REPOS=$WORKSPACE/$USER/CK-REPOS
export CK_EXPERIMENT_REPO=mlperf_v2.0.$(hostname).$USER
export CK_EXPERIMENT_DIR=$WORKSPACE/$USER/CK-REPOS/$CK_EXPERIMENT_REPO/experiment
export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
source ~/.bashrc

sudo mkdir -p $CK_WORKSPACE/$USER && sudo chown $USER:qaic $CK_WORKSPACE/$USER

$CK_PYTHON -m pip install --ignore-installed pip setuptools testresources ck==2.6.0 --user --upgrade
ck pull repo --url=https://github.com/krai/ck-qaic

ck add repo:$CK_EXPERIMENT_REPO --quiet
ck add $CK_EXPERIMENT_REPO:experiment:dummy --common_func
ck rm  $CK_EXPERIMENT_REPO:experiment:dummy --force
chgrp -R qaic $CK_EXPERIMENT_DIR
chmod -R g+ws $CK_EXPERIMENT_DIR
setfacl -R -d -m group:qaic:rwx $CK_EXPERIMENT_DIR

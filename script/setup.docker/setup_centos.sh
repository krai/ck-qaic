#!/bin/bash

# Usage: WORKSPACE_DIR=/local/mnt/workspace bash setup_centos.sh

# Copyright (c) 2022 Krai Ltd.
#
# SPDX-License-Identifier: BSD-3-Clause.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

function exit_if_error() {
  message="$1"
  if [ "${?}" != "0" ]; then
    echo ""
    echo "ERROR: ${message}"
    exit 1
  fi
}

_WORKSPACE_DIR=${WORKSPACE_DIR:-/local/mnt/workspace}
_YUM_INSTALL=${YUM_INSTALL:-"yes"}
_DOCKER_INSTALL=${DOCKER_INSTALL:-"yes"}
_PYTHON_INSTALL=${PYTHON_INSTALL:-"yes"}

echo "'$0' parameters:"
echo "- WORKSPACE_DIR=${_WORKSPACE_DIR}"
echo "- YUM_INSTALL=${_YUM_INSTALL}"
echo "- PYTHON_INSTALL=${_PYTHON_INSTALL}"
echo "- DOCKER_INSTALL=${_DOCKER_INSTALL}"
echo

# Install system packages using yum.
if [[ "${_YUM_INSTALL}" == "yes" ]]; then

sudo yum upgrade -y
sudo yum install -y \
  git wget patch vim which \
  zip unzip bzip2-devel \
  openssl-devel libffi-devel \
  lm_sensors ipmitool \
  yum-utils lvm2 device-mapper-persistent-data \
  make epel-release htop tmux \
  dnf acl
sudo yum clean all
sudo dnf install -y python3 python3-pip python3-devel \
  libarchive cmake scl-utils gcc-toolset-11-gcc-c++

fi # YUM_INSTALL

# Install Python >= 3.7 from source.
if [[ "${_PYTHON_INSTALL}" == "yes" ]]; then

export PYTHON_VERSION=3.8.12
cd /usr/src \
&& wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
&& tar xzf Python-${PYTHON_VERSION}.tgz \
&& rm -f Python-${PYTHON_VERSION}.tgz \
&& cd /usr/src/Python-${PYTHON_VERSION} \
&& ./configure --enable-optimizations && make -j8 altinstall \
&& rm -rf /usr/src/Python-${PYTHON_VERSION}*

fi # PYTHON_INSTALL

# Install Docker following: https://docs.docker.com/engine/install/centos/
if [[ "${_DOCKER_INSTALL}" == "yes" ]]; then

# Remove old Docker installations.
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

# Test
sudo docker system info

exit_if_error "Docker installation failed!"

fi # DOCKER_INSTALL

sudo usermod -aG docker $USER

# # Fix permissions on the 'sudo' command.
# chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo

echo
echo "DONE."
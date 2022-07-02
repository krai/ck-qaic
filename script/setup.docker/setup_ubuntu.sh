#!/bin/bash

# Usage: WORKSPACE_DIR=/local/mnt/workspace bash setup_ubuntu.sh

#
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
_APT_INSTALL=${APT_INSTALL:-"yes"}
_DOCKER_INSTALL=${DOCKER_INSTALL:-"yes"}

echo "'$0' parameters:"
echo "- WORKSPACE_DIR=${_WORKSPACE_DIR}"
echo "- APT_INSTALL=${_APT_INSTALL}"
echo "- DOCKER_INSTALL=${_DOCKER_INSTALL}"
echo

# Install system packages using apt.
if [[ "${_APT_INSTALL}" == "yes" ]]; then

sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
  git wget patch vim \
  libbz2-dev lzma \
  python3-dev python3-pip \
  lm-sensors ipmitool \
  ca-certificates curl gnupg lsb-release \
  acl
sudo apt clean all
exit_if_error "apt install failed!"

fi # APT_INSTALL


# Install Docker following: https://docs.docker.com/engine/install/ubuntu/
if [[ "${_DOCKER_INSTALL}" == "yes" ]]; then
# Remove old Docker installations.
sudo apt-get remove docker docker-engine docker.io containerd runc

sudo mkdir -p /etc/apt/keyrings
sudo mv /etc/apt/keyrings/docker.gpg{,.bak}
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
     $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

export WORKSPACE_DIR=${_WORKSPACE_DIR}
export WORKSPACE_DOCKER=${_WORKSPACE_DIR}/docker
export DOCKER_DAEMON_JSON=/etc/docker/daemon.json

sudo mkdir -p $WORKSPACE_DOCKER
sudo cp $DOCKER_DAEMON_JSON{,.bak}
echo -e "{\n\t\"data-root\": \"$WORKSPACE_DOCKER\"\n}" | sudo tee -a $DOCKER_DAEMON_JSON
cat $DOCKER_DAEMON_JSON

sudo service docker restart
sudo docker system info | grep "Docker Root Dir:"

# Test.
sudo docker --version
sudo docker run hello-world
sudo docker image ls

exit_if_error "Docker installation failed!"

fi # DOCKER_INSTALL

# FIXME: Remove from the script as requires logging out and logging in again anyway?
sudo usermod -aG qaic,docker,sudo $USER
groups

echo
echo "DONE."

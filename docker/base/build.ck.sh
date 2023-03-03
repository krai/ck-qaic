#/bin/bash

#
# Copyright (c) 2021-2022 Krai Ltd.
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

_NO_CACHE=${NO_CACHE:-"no"}
if [[ "${_NO_CACHE}" == "yes" ]]; then
  __NO_CACHE="--no-cache"
fi

# Personal Access Token for accessing private repositories on GitHub.
_CK_QAIC_PAT=${CK_QAIC_PAT:-""}
# Which variant of the CK-QAIC repo to use to build the image (public "https://github.com/krai/ck-qaic" by default).
_CK_QAIC_BUILD_REPO=${CK_QAIC_BUILD_REPO:-"ck-qaic"}
# Which variant of the CK-QAIC repo to use inside the image (public "https://github.com/krai/ck-qaic" by default).
_CK_QAIC_REPO=${CK_QAIC_REPO:-"ck-qaic"}
# Which branch of the CK-QAIC repo to use inside the image ("main" by default).
_CK_QAIC_CHECKOUT=${CK_QAIC_CHECKOUT:-"main"}

_DOCKER_OS=${DOCKER_OS:-ubuntu}
_DOCKER_CK_COMMON_IMAGE="krai/ck.common:${_DOCKER_OS}_latest"
_DOCKER_BASE_IMAGE="krai/base:${_DOCKER_OS}_latest"

if [[ "$(docker images -q ${_DOCKER_BASE_IMAGE} 2> /dev/null)" == "" ]]; then
  cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base) && ./build.base.sh
fi

# Use GCC >= 10.
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-11}
# Use Python >= 3.7.
_PYTHON_VER=${PYTHON_VER:-3.9.14}
# Use CK >= 2.5.9.
_CK_VER=${CK_VER:-2.6.1}
# Create a non-root user with a fixed group id and a fixed user id.
#QAIC_GROUP_ID=$(getent group qaic | cut -d: -f3)
#_GROUP_ID=${GROUP_ID:-${QAIC_GROUP_ID}}
_GROUP_ID=${GROUP_ID:-1500}
_USER_ID=${USER_ID:-2000}

if [[ "${_DOCKER_OS}" == "ubuntu" ]]; then
  _PYTHON_VER="3.8.10"
fi

echo
echo "Building image: '${_DOCKER_CK_COMMON_IMAGE}'"
read -d '' CMD <<END_OF_CMD
cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base) && \
time docker build ${__NO_CACHE} \
--build-arg CK_VER=${_CK_VER} \
--build-arg GCC_MAJOR_VER=${_GCC_MAJOR_VER} \
--build-arg PYTHON_VER=${_PYTHON_VER} \
--build-arg PYTHON_MAJOR_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f1) \
--build-arg PYTHON_MINOR_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f2) \
--build-arg PYTHON_PATCH_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f3) \
--build-arg CK_QAIC_PAT=${_CK_QAIC_PAT} \
--build-arg CK_QAIC_REPO=${_CK_QAIC_REPO} \
--build-arg CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} \
--build-arg GROUP_ID=${_GROUP_ID} \
--build-arg USER_ID=${_USER_ID} \
--build-arg DOCKER_OS=${_DOCKER_OS} \
-f Dockerfile.ck \
-t ${_DOCKER_CK_COMMON_IMAGE} .
END_OF_CMD
echo "Command: ${CMD}"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi

echo
echo "Done (building '${_DOCKER_CK_COMMON_IMAGE}')"
echo

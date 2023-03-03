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

function exit_if_error() {
  if [ "${?}" != "0" ]; then exit 1; fi
}

if [[ $# < 1 ]]; then
  echo "Please enter the model name to build the Docker image for (one of: bert, resnet50, ssd-resnet34, ssd-mobilenet, retinanet, coco).";
  exit 1;
fi
MODEL=$1
echo "Building CK (QAIC-independent) image for '${MODEL}' ..."

_CK_QAIC_PAT=${CK_QAIC_PAT:-""}
_CK_QAIC_REPO=${CK_QAIC_REPO:-"ck-qaic"}
_CK_QAIC_CHECKOUT=${CK_QAIC_CHECKOUT:-"main"}
_CK_QAIC_BUILD_REPO=${CK_QAIC_BUILD_REPO:-"ck-qaic"}

_DOCKER_OS=${DOCKER_OS:-"ubuntu"}
_DOCKER_MODEL_IMAGE="krai/ck.${MODEL}:${_DOCKER_OS}_latest"
_DOCKER_COMMON_IMAGE="krai/ck.common:${_DOCKER_OS}_latest"

# Use Python >= 3.7.
_PYTHON_VER=${PYTHON_VER:-"3.9.14"}
if [[ "${_DOCKER_OS}" == "ubuntu" ]]; then
  _PYTHON_VER="3.8.10"
fi

_NO_CACHE=${NO_CACHE:-"no"}
if [[ "${_NO_CACHE}" == "yes" ]]; then
  __NO_CACHE="--no-cache"
fi

if [[ "$(docker images -q ${_DOCKER_COMMON_IMAGE} 2> /dev/null)" == "" ]]; then
  cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base) && ./build.ck.sh
  exit_if_error
fi

if [ "${_DOCKER_MODEL_IMAGE}" == "krai/ck.coco:${DOCKER_OS}_latest" ]; then
  _DOCKER_MODEL_IMAGE="coco:latest"
fi

echo
echo "Building image: '${_DOCKER_MODEL_IMAGE}'"
echo
read -d '' CMD <<END_OF_CMD
cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:${MODEL}) && \
docker build ${__NO_CACHE} \
--build-arg DOCKER_OS=${_DOCKER_OS} \
--build-arg CK_QAIC_PAT=${_CK_QAIC_PAT} \
--build-arg CK_QAIC_REPO=${_CK_QAIC_REPO} \
--build-arg CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} \
--build-arg PYTHON_MAJOR_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f1) \
--build-arg PYTHON_MINOR_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f2) \
--build-arg PYTHON_PATCH_VER=$(echo ${_PYTHON_VER} | cut -d '.' -f3) \
-t ${_DOCKER_MODEL_IMAGE} \
-f Dockerfile.ck .
END_OF_CMD
echo "Command: ${CMD}"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi
exit_if_error

echo
echo "Done (building '${_DOCKER_MODEL_IMAGE}')"
echo

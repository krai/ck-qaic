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

_DOCKER_OS=${DOCKER_OS:-centos}

if [[ "$(docker images -q krai/base.${_DOCKER_OS} 2> /dev/null)" == "" ]]; then
  cd $(ck find ck-qaic:docker:base) && ./build.base.sh
fi

# Create a non-root user with a fixed group id and a fixed user id.
#QAIC_GROUP_ID=$(getent group qaic | cut -d: -f3)
#_GROUP_ID=${GROUP_ID:-${QAIC_GROUP_ID}}
_GROUP_ID=${GROUP_ID:-1500}
_USER_ID=${USER_ID:-2000}
_ARCH=${ARCH:-$(uname -m)}

_SDK_DIR=${SDK_DIR:-/local/mnt/workspace/sdks}
_SDK_VER=${SDK_VER:-1.6.80}

_APPS_SDK=${APPS_SDK:-"${_SDK_DIR}/qaic-apps-${_SDK_VER}.zip"}
if [[ ! -f "${_APPS_SDK}" ]]; then
  echo "ERROR: File '${_APPS_SDK}' does not exist!"
  exit 1
fi
echo "Using Apps SDK: ${_APPS_SDK}"

_PLATFORM_SDK=${PLATFORM_SDK:-"${_SDK_DIR}/qaic-platform-sdk-${_ARCH}-${_DOCKER_OS}-${_SDK_VER}.zip"}
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  _PLATFORM_SDK="${_SDK_DIR}/qaic-platform-sdk-${_ARCH}-${_SDK_VER}.zip"
fi
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  _PLATFORM_SDK="${_SDK_DIR}/qaic-platform-sdk-${_SDK_VER}.zip"
fi
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  echo "ERROR: File '${_PLATFORM_SDK}' does not exist!"
  exit 1
fi
echo "Using Platform SDK: ${_PLATFORM_SDK}"

TMP_DIR=$(ck find ck-qaic:docker:base)/tmp
echo ${TMP_DIR}
if [ ! -d "${TMP_DIR}" ]; then
  mkdir -p "${TMP_DIR}"
  if [ $? -ne 0 ]; then
    echo "Failed to create ${TMP_DIR}"
    exit 1
  fi
fi

rm -rvf ${TMP_DIR}/*
cp -vf ${_APPS_SDK} ${TMP_DIR}
cp -vf ${_PLATFORM_SDK} ${TMP_DIR}

if [ ! -z "${NO_CACHE}" ]; then
  _NO_CACHE="--no-cache"
fi

echo "Image: 'krai/qaic.${_DOCKER_OS}:${_SDK_VER}'"
read -d '' CMD <<END_OF_CMD
cd $(ck find ck-qaic:docker:base) && \
time docker build ${_NO_CACHE} \
--build-arg GROUP_ID=${_GROUP_ID} \
--build-arg USER_ID=${_USER_ID} \
--build-arg ARCH=${_ARCH} \
--build-arg DOCKER_OS=${_DOCKER_OS} \
-f Dockerfile.qaic \
-t krai/qaic:${_DOCKER_OS}_${_SDK_VER} .
END_OF_CMD
echo "Command: '${CMD}'"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi

echo
echo "Done."

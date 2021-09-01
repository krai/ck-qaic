#/bin/bash

#
# Copyright (c) 2021 Krai Ltd.
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

# Obtain qaic-docker-1.0.tar.gz from Qualcomm and extract it to e.g. $HOME.
_DOCKER_DIR=${DOCKER_DIR:-$HOME/qaic-docker-1.0}
_DOCKER_OS=${DOCKER_OS:-centos7}

_SDK_DIR=${SDK_DIR:-/local/mnt/workspace/sdks}
_SDK_VER=${SDK_VER:-1.5.6}

_APPS_SDK=${APPS_SDK:-"${_SDK_DIR}/qaic-apps-${_SDK_VER}.zip"}
if [[ ! -f "${_APPS_SDK}" ]]; then
  echo "ERROR: File '${_APPS_SDK}' does not exist!"
  exit 1
fi

_PLATFORM_SDK=${PLATFORM_SDK:-"${_SDK_DIR}/qaic-platform-sdk-${_SDK_VER}.zip"}
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  _PLATFORM_SDK="${_SDK_DIR}/qaic-platform-sdk-x86_64-${_SDK_VER}.zip"
fi
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  echo "ERROR: File '${_PLATFORM_SDK}' does not exist!"
  exit 1
fi

read -d '' CMD <<END_OF_CMD
cd ${_DOCKER_DIR} && rm -rf ./temp && chmod u+x ./build_image.sh && \
time ./build_image.sh --os ${_DOCKER_OS} --tag ${_SDK_VER} \
--apps-sdk ${_APPS_SDK} --platform-sdk ${_PLATFORM_SDK}
END_OF_CMD

echo "Running ..."
echo "${CMD}"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi

echo
echo "Done."
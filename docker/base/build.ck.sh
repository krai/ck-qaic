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

_DOCKER_OS=${DOCKER_OS:-centos7}

if [[ "$(docker images -q krai/base.${_DOCKER_OS} 2> /dev/null)" == "" ]]; then
  cd $(ck find ck-qaic:docker:base) && ./build.base.sh
fi

# Use GCC >= 10.
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-11}
# Use Python >= 3.7.
_PYTHON_VER=${PYTHON_VER:-3.10.4}
# Use CK >= 2.5.9.
_CK_VER=${CK_VER:-2.6.1}
# Which branch of repo:ck-qaic to use (main by default).
_CK_QAIC_CHECKOUT=${CK_QAIC_CHECKOUT:-main}
# Create a non-root user with a fixed group id and a fixed user id.
#QAIC_GROUP_ID=$(getent group qaic | cut -d: -f3)
#_GROUP_ID=${GROUP_ID:-${QAIC_GROUP_ID}}
_GROUP_ID=${GROUP_ID:-1500}
_USER_ID=${USER_ID:-2000}

if [ ! -z "${NO_CACHE}" ]; then
  _NO_CACHE="--no-cache"
fi

echo "Image: 'krai/ck.common.${_DOCKER_OS}'"
read -d '' CMD <<END_OF_CMD
cd $(ck find ck-qaic:docker:base) && \
time docker build ${_NO_CACHE} \
--build-arg GCC_MAJOR_VER=${_GCC_MAJOR_VER} \
--build-arg PYTHON_VER=${_PYTHON_VER} \
--build-arg CK_VER=${_CK_VER} \
--build-arg CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} \
--build-arg GROUP_ID=${_GROUP_ID} \
--build-arg USER_ID=${_USER_ID} \
-f Dockerfile.ck.${_DOCKER_OS} \
-t krai/ck.common.${_DOCKER_OS} .
END_OF_CMD
echo "Command: ${CMD}"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi

echo
echo "Done."

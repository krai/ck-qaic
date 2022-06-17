#!/bin/bash

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

_DOCKER_OS=${DOCKER_OS:-ubuntu}
_SDK_VER=${SDK_VER:-1.7.0.34}
_SDK_DIR=${SDK_DIR:-/local/mnt/workspace/sdks}

# Build SDK-independent base image.
DOCKER_OS=${_DOCKER_OS} $(ck find ck-qaic:docker:base)/build.base.sh
exit_if_error "Failed to build SDK-independent base image!"
docker run --rm krai/base:${_DOCKER_OS}_latest
exit_if_error "Failed to test SDK-independent base image!"

# Build SDK-independent common image.
DOCKER_OS=${_DOCKER_OS} $(ck find ck-qaic:docker:base)/build.ck.sh
exit_if_error "Failed to build SDK-independent common image!"
docker run --rm krai/ck.common:${_DOCKER_OS}_latest
exit_if_error "Failed to test SDK-independent common image!"

# Build SDK-dependent base image.
DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} SDK_DIR=${_SDK_DIR} $(ck find ck-qaic:docker:base)/build.qaic.sh
exit_if_error "Failed to build SDK-dependent base image!"
export SDK_VER=${_SDK_VER} && docker run --privileged --rm krai/qaic:${_DOCKER_OS}_${_SDK_VER}
exit_if_error "Failed to test SDK-dependent base image!"

echo
echo "Done (building all images)."

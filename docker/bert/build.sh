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

_BASE_OS=${BASE_OS:-centos7}
_BASE_IMAGE=${BASE_IMAGE:-qran-${_BASE_OS}}
_SDK_VER=${SDK_VER:-1.5.9}
_PYTHON_VER=${PYTHON_VER:-3.8.11}
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-10}
_DEBUG_BUILD=${DEBUG_BUILD:no}

_CK_QAIC_BRANCH=${CK_QAIC_BRANCH:-main}
_CK_QAIC_PERCENTILE_CALIBRATION=${CK_QAIC_PERCENTILE_CALIBRATION:-no}

QAIC_GROUP_ID=$(cut -d: -f3 < <(getent group qaic))
_GROUP_ID=${GROUP_ID:-${QAIC_GROUP_ID}}
_USER_ID=${USER_ID:-2000}

read -d '' CMD <<END_OF_CMD
cd $(ck find ck-qaic:docker:bert) && \
time docker build \
--build-arg BASE_IMAGE=${_BASE_IMAGE} \
--build-arg SDK_VER=${_SDK_VER} \
--build-arg PYTHON_VER=${_PYTHON_VER} \
--build-arg GCC_MAJOR_VER=${_GCC_MAJOR_VER} \
--build-arg GROUP_ID=${_GROUP_ID} \
--build-arg USER_ID=${_USER_ID} \
--build-arg CK_QAIC_BRANCH=${_CK_QAIC_BRANCH} \
--build-arg CK_QAIC_PERCENTILE_CALIBRATION=${_CK_QAIC_PERCENTILE_CALIBRATION} \
--build-arg DEBUG_BUILD=${_DEBUG_BUILD} \
-t krai/mlperf.bert.${_BASE_OS}:${_SDK_VER} \
-f Dockerfile.${_BASE_OS} .
END_OF_CMD
echo "Running: ${CMD}"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi

echo
echo "Done."

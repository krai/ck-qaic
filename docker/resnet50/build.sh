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
_SDK_VER=${SDK_VER:-1.5.6}
_PYTHON_VER=${PYTHON_VER:-3.8.12}
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-10}

# Preprocess the reduced (500 images) or full ImageNet validation dataset
# (50,000 images), or use the full preprocessed dataset. The latter two
# options result in the same image suffix 'full'.
_IMAGENET=${IMAGENET:-full}
if [[ "${_IMAGENET}" == "full" || "${_IMAGENET}" == "preprocessed" ]]
then
  _IMAGENET_SUFFIX="full"
else
  _IMAGENET_SUFFIX="min"
  if [[ "${_IMAGENET}" != "min"  ]]; then
    echo "Warning: mapping 'IMAGENET=${_IMAGENET}' to 'IMAGENET=min'."
  fi
fi

QAIC_GROUP_ID=$(cut -d: -f3 < <(getent group qaic))
_GROUP_ID=${GROUP_ID:-${QAIC_GROUP_ID}}
_USER_ID=${USER_ID:-2000}

read -d '' CMD <<END_OF_CMD
cd $(ck find ck-qaic:docker:resnet50) && \
time docker build \
--build-arg BASE_OS=${_BASE_OS} \
--build-arg BASE_IMAGE=${_BASE_IMAGE} \
--build-arg SDK_VER=${_SDK_VER} \
--build-arg PYTHON_VER=${_PYTHON_VER} \
--build-arg GCC_MAJOR_VER=${_GCC_MAJOR_VER} \
--build-arg GROUP_ID=${_GROUP_ID} \
--build-arg USER_ID=${_USER_ID} \
-t mlperf.resnet50.${_BASE_OS}.onbuild:${_SDK_VER} \
-f Dockerfile.${_BASE_OS} .
END_OF_CMD
echo "Running: ${CMD}"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi

time docker build \
-t krai/mlperf.resnet50.${_IMAGENET_SUFFIX}.${_BASE_OS}:${_SDK_VER} . \
-f-<<EOF
FROM mlperf.resnet50.${_BASE_OS}.preamble:${_SDK_VER}
COPY --from=mlperf.resnet50.${_IMAGENET_SUFFIX}.${_BASE_OS}.onbuild:${_SDK_VER} /home/krai/CK       /home/krai/CK
COPY --from=mlperf.resnet50.${_IMAGENET_SUFFIX}.${_BASE_OS}.onbuild:${_SDK_VER} /home/krai/CK_REPOS /home/krai/CK_REPOS
COPY --from=mlperf.resnet50.${_IMAGENET_SUFFIX}.${_BASE_OS}.onbuild:${_SDK_VER} /home/krai/CK_TOOLS /home/krai/CK_TOOLS
EOF
 
echo
echo "Done."

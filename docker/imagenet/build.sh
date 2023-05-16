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

_DOCKER_OS=${DOCKER_OS:-ubuntu}
_DATASETS_DIR=${DATASETS_DIR:-/local/mnt/workspace/datasets}
_IMAGENET_NAME=${IMAGENET_NAME:-imagenet}
_IMAGENET_DIR=${_DATASETS_DIR}/${_IMAGENET_NAME}

if [[ "${DATASETS_DIR}" == "no" ]]; then
  time docker build -t imagenet:latest . -f-<<EOF
FROM ubuntu:20.04
RUN mkdir /imagenet && touch /imagenet/ILSVRC2012_val_00000001.JPEG
EOF
  exit 0
fi

if [[ ! -f "${_IMAGENET_DIR}/ILSVRC2012_val_00000001.JPEG" ]]; then
  echo "ERROR: File '${_IMAGENET_DIR}/ILSVRC2012_val_00000001.JPEG' does not exist!"
  exit 1
fi

# The image tag ('imagenet') and the path in that image ('/imagenet') are hardcoded on purpose.
if [[ "${_DOCKER_OS}" == "ubuntu" || "${_DOCKER_OS}" == "deb" ]]; then
  time docker build -t imagenet:latest ${_IMAGENET_DIR} -f-<<EOF
FROM ubuntu:20.04
ADD / /imagenet
EOF
elif [[ "${_DOCKER_OS}" == "centos" ]]; then
  time docker build -t imagenet:latest ${_IMAGENET_DIR} -f-<<EOF
FROM centos:7
ADD / /imagenet
EOF
fi

echo
echo "Done (building 'imagenet:latest' image)."
echo

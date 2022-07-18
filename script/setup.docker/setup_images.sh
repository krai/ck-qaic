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
  if [ "${?}" != "0" ]; then
    echo ""
    echo "ERROR: $1"
    exit 1
  fi
}

_DOCKER_OS=${DOCKER_OS:-ubuntu}
_CK_QAIC_CHECKOUT=${CK_QAIC_CHECKOUT:-"main"}
_WORKSPACE_DIR=${WORKSPACE_DIR:-"/local/mnt/workspace"}
_DATASETS_DIR=${DATASETS_DIR:-"${_WORKSPACE_DIR}/datasets"}
_IMAGENET_NAME=${IMAGENET_NAME:-"imagenet"}
_SDK_DIR=${SDK_DIR:-"${_WORKSPACE_DIR}/sdks"}
_SDK_VER=${SDK_VER:-1.7.1.12}
_PYTHON_VER=${PYTHON_VER:-3.9.13}
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-11}
_CK_VER=${CK_VER:-2.6.1}
_GROUP_ID=${GROUP_ID:-1500}
_USER_ID=${USER_ID:-2000}
_CK_QAIC_PCV_BERT=${CK_QAIC_PCV_BERT:-'9980'}
_CK_QAIC_PCV_RESNET50=${CK_QAIC_PCV_RESNET50:-''}
_CK_QAIC_PERCENTILE_CALIBRATION=${CK_QAIC_PERCENTILE_CALIBRATION:-no}
_COMPILE_PRO=${COMPILE_PRO:-yes}
_COMPILE_STD=${COMPILE_STD:-no}
 #_NO_CACHE=${NO_CACHE:-"--no-cache"}

if [[ "${_DOCKER_OS}" == "ubuntu" ]]; then
  _PYTHON_VER="3.8.10"
fi

#===============================================================================
# Build & test base images.
#===============================================================================

# Build SDK-independent base image.
echo "Building SDK-independent base image ..."
DOCKER_OS=${_DOCKER_OS} GCC_MAJOR_VER=${_GCC_MAJOR_VER} PYTHON_VER=${_PYTHON_VER} $(ck find ck-qaic:docker:base)/build.base.sh
exit_if_error "Failed to build SDK-independent base image!"
# Test SDK-independent base image.
echo "Testing SDK-independent base image ..."
docker run --rm krai/base:${_DOCKER_OS}_latest
exit_if_error "Failed to test SDK-independent base image!"

# Build SDK-independent common image.
echo "Building SDK-independent common image ..."
DOCKER_OS=${_DOCKER_OS} GCC_MAJOR_VER=${_GCC_MAJOR_VER} PYTHON_VER=${_PYTHON_VER} CK_VER=${_CK_VER} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} GROUP_ID=${_GROUP_ID} USER_ID=${_USER_ID} \
$(ck find ck-qaic:docker:base)/build.ck.sh
exit_if_error "Failed to build SDK-independent common image!"
# Test SDK-independent common image.
echo "Testing SDK-independent common image ..."
docker run --rm krai/ck.common:${_DOCKER_OS}_latest
exit_if_error "Failed to test SDK-independent common image!"

# Build SDK-dependent base image.
echo "Building SDK-dependent base image ..."
WORKSPACE_DIR=${_WORKSPACE_DIR} DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} SDK_DIR=${_SDK_DIR} GROUP_ID=${_GROUP_ID} USER_ID=${_USER_ID} $(ck find ck-qaic:docker:base)/build.qaic.sh
exit_if_error "Failed to build SDK-dependent base image!"
# Test SDK-dependent base image.
echo "Testing SDK-dependent base image ..."
export SDK_VER=${_SDK_VER} && docker run --privileged --group-add $(getent group qaic | cut -d: -f3) --rm krai/qaic:${_DOCKER_OS}_${_SDK_VER}
exit_if_error "Failed to test SDK-dependent base image!"

#===============================================================================
# Build & test benchmark images.
#===============================================================================

#------------------------------------------------------------------------------
# ResNet50.
#-------------------------------------------------------------------------------

# Build ImageNet image.
if [[ "$(docker images -q imagenet:latest 2> /dev/null)" == "" ]]; then
  echo "Building ImageNet image ..."
  DATASETS_DIR=${_DATASETS_DIR} IMAGENET_NAME=${_IMAGENET_NAME} $(ck find ck-qaic:docker:imagenet)/build.sh
  exit_if_error "Failed to build ImageNet image!"
fi
# Test ImageNet image.
echo "Testing ImageNet image ..."
docker run --rm imagenet:latest /bin/bash -c "du -hs /imagenet"
exit_if_error "Failed to test ImageNet image!"

# Build SDK-independent image.
echo "Building SDK-independent ResNet50 image ..."
DOCKER_OS=${_DOCKER_OS} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} PYTHON_VER=${_PYTHON_VER} $(ck find repo:ck-qaic)/docker/build_ck.sh resnet50
exit_if_error "Failed to build SDK-independent ResNet50 image!"
# Test SDK-independent image.
echo "Testing SDK-independent ResNet50 image ..."
docker run --rm krai/ck.resnet50:${_DOCKER_OS}_latest
exit_if_error "Failed to test SDK-independent ResNet50 image!"

# Build SDK-dependent image.
echo "Building SDK-dependent ResNet50 image ..."
DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} CK_QAIC_PCV=${_CK_QAIC_PCV_RESNET50} COMPILE_PRO=${_COMPILE_PRO} COMPILE_STD=${_COMPILE_STD} $(ck find repo:ck-qaic)/docker/build.sh resnet50
exit_if_error "Failed to build SDK-dependent ResNet50 image!"
# Test SDK-dependent image.
echo "Testing SDK-dependent ResNet50 image ..."
export SDK_VER=${_SDK_VER} && docker run --privileged --group-add $(getent group qaic | cut -d: -f3) --rm krai/mlperf.resnet50.full:${_DOCKER_OS}_${_SDK_VER}
exit_if_error "Failed to test SDK-dependent ResNet50 image!"

#-------------------------------------------------------------------------------
# BERT.
#-------------------------------------------------------------------------------

# Build SDK-independent image.
echo "Building SDK-independent BERT image ..."
DOCKER_OS=${_DOCKER_OS} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} PYTHON_VER=${_PYTHON_VER} $(ck find repo:ck-qaic)/docker/build_ck.sh bert
exit_if_error "Failed to build SDK-independent BERT image!"
# Test SDK-independent image.
echo "Testing SDK-independent BERT image ..."
docker run --rm krai/ck.bert:${_DOCKER_OS}_latest
exit_if_error "Failed to test SDK-independent BERT image!"

# Build SDK-dependent image.
echo "Building SDK-dependent BERT image ..."
DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} CK_QAIC_PCV=${_CK_QAIC_PCV_BERT} COMPILE_PRO=${_COMPILE_PRO} COMPILE_STD=${_COMPILE_STD} $(ck find repo:ck-qaic)/docker/build.sh bert
exit_if_error "Failed to build SDK-dependent BERT image!"
# Test SDK-dependent image.
echo "Testing SDK-dependent BERT image ..."
export SDK_VER=${_SDK_VER} && docker run --privileged --group-add $(getent group qaic | cut -d: -f3) --rm krai/mlperf.bert:${_DOCKER_OS}_${_SDK_VER}
exit_if_error "Failed to test SDK-dependent BERT image!"

#-------------------------------------------------------------------------------
# RetinaNet.
#-------------------------------------------------------------------------------
_WORKLOAD=retinanet

# Build SDK-independent image.
echo "Building SDK-independent ${_WORKLOAD} image ..."
DOCKER_OS=${_DOCKER_OS} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} PYTHON_VER=${_PYTHON_VER} $(ck find repo:ck-qaic)/docker/build_ck.sh ${_WORKLOAD}
exit_if_error "Failed to build SDK-independent ${_WORKLOAD} image!"
# Test SDK-independent image.
echo "Testing SDK-independent ${_WORKLOAD} image ..."
docker run --rm krai/ck.${_WORKLOAD}:${_DOCKER_OS}_latest
exit_if_error "Failed to test SDK-independent ${_WORKLOAD} image!"

# Build SDK-dependent image.
echo "Building SDK-dependent ${_WORKLOAD} image ..."
DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} CK_QAIC_PCV=${_CK_QAIC_PCV_BERT} COMPILE_PRO=${_COMPILE_PRO} COMPILE_STD=${_COMPILE_STD} $(ck find repo:ck-qaic)/docker/build.sh ${_WORKLOAD}
exit_if_error "Failed to build SDK-dependent ${_WORKLOAD} image!"
# Test SDK-dependent image.
echo "Testing SDK-dependent ${_WORKLOAD} image ..."
export SDK_VER=${_SDK_VER} && docker run --privileged --group-add $(getent group qaic | cut -d: -f3) --rm krai/mlperf.${_WORKLOAD}:${_DOCKER_OS}_${_SDK_VER}
exit_if_error "Failed to test SDK-dependent ${_WORKLOAD} image!"

#-------------------------------------------------------------------------------

echo
echo "DONE (building ALL images)."
echo

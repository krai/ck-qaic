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

# Convert comma-separated workload list into array.
_WORKLOADS=${WORKLOADS:-"resnet50,bert"}
IFS=',' read -ra _WORKLOADS_AS_ARRAY <<< "${_WORKLOADS}"

_DOCKER_OS=${DOCKER_OS:-ubuntu}
_CK_QAIC_CHECKOUT=${CK_QAIC_CHECKOUT:-"main"}
_WORKSPACE_DIR=${WORKSPACE_DIR:-"/local/mnt/workspace"}
_DATASETS_DIR=${DATASETS_DIR:-"${_WORKSPACE_DIR}/datasets"}
_IMAGENET_NAME=${IMAGENET_NAME:-"imagenet"}
_SDK_DIR=${SDK_DIR:-"${_WORKSPACE_DIR}/sdks"}
_SDK_VER=${SDK_VER:-1.7.1.12}
_PYTHON_VER=${PYTHON_VER:-3.9.14}
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-11}
_CK_VER=${CK_VER:-2.6.1}
_GROUP_ID=${GROUP_ID:-1500}
_USER_ID=${USER_ID:-2000}
_CK_QAIC_PCV_BERT=${CK_QAIC_PCV_BERT:-9985}
_CK_QAIC_PCV_RESNET50=${CK_QAIC_PCV_RESNET50:-''}
_CK_QAIC_PERCENTILE_CALIBRATION=${CK_QAIC_PERCENTILE_CALIBRATION:-no}
_PRECALIBRATED_PROFILE_RETINANET=${PRECALIBRATED_PROFILE_RETINANET:-yes}
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
CMD="DOCKER_OS=${_DOCKER_OS} GCC_MAJOR_VER=${_GCC_MAJOR_VER} PYTHON_VER=${_PYTHON_VER} $(ck find ck-qaic:docker:base)/build.base.sh"
echo ${CMD}; eval ${CMD}
exit_if_error "Failed to build SDK-independent base image!"
echo
# Test SDK-independent base image.
echo "Testing SDK-independent base image ..."
CMD="docker run --rm krai/base:${_DOCKER_OS}_latest"
echo ${CMD}; eval ${CMD}
exit_if_error "Failed to test SDK-independent base image!"
echo
# Build SDK-independent common image.
echo "Building SDK-independent common image ..."
CMD="DOCKER_OS=${_DOCKER_OS} GCC_MAJOR_VER=${_GCC_MAJOR_VER} PYTHON_VER=${_PYTHON_VER} CK_VER=${_CK_VER} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} GROUP_ID=${_GROUP_ID} USER_ID=${_USER_ID} $(ck find ck-qaic:docker:base)/build.ck.sh"
echo ${CMD}; eval ${CMD}
exit_if_error "Failed to build SDK-independent common image!"
echo
# Test SDK-independent common image.
echo "Testing SDK-independent common image ..."
CMD="docker run --rm krai/ck.common:${_DOCKER_OS}_latest"
echo ${CMD}; eval ${CMD}
exit_if_error "Failed to test SDK-independent common image!"
echo
# Build SDK-dependent base image.
echo "Building SDK-dependent base image ..."
CMD="WORKSPACE_DIR=${_WORKSPACE_DIR} DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} SDK_DIR=${_SDK_DIR} GROUP_ID=${_GROUP_ID} USER_ID=${_USER_ID} $(ck find ck-qaic:docker:base)/build.qaic.sh"
echo ${CMD}; eval ${CMD}
exit_if_error "Failed to build SDK-dependent base image!"
echo
# Test SDK-dependent base image.
echo "Testing SDK-dependent base image ..."
CMD="export SDK_VER=${_SDK_VER} && docker run --privileged --group-add $(getent group qaic | cut -d: -f3) --rm krai/qaic:${_DOCKER_OS}_${_SDK_VER}"
echo ${CMD}; eval ${CMD}
#exit_if_error "Failed to test SDK-dependent base image!"
echo

#===============================================================================
# Build & test workload images.
#===============================================================================
WORKLOAD_INDEPENDENT_PARAMS="CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} PYTHON_VER=${_PYTHON_VER}"
for _WORKLOAD in ${_WORKLOADS_AS_ARRAY[@]}
do
  SDK_INDEPENDENT_IMAGE="krai/ck.${_WORKLOAD}:${_DOCKER_OS}_latest"
  SDK_DEPENDENT_IMAGE="krai/mlperf.${_WORKLOAD}:${_DOCKER_OS}_${_SDK_VER}"
  #-----------------------------------------------------------------------------
  # ResNet50-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "resnet50" ]]; then
    SDK_DEPENDENT_IMAGE="krai/mlperf.${_WORKLOAD}.full:${_DOCKER_OS}_${_SDK_VER}"
    WORKLOAD_DEPENDENT_PARAMS="COMPILE_PRO=${_COMPILE_PRO} COMPILE_STD=${_COMPILE_STD}" # TODO: Add "CK_QAIC_PCV=${_CK_QAIC_PCV_RESNET50}"?
    # Build ImageNet image.
    if [[ "$(docker images -q imagenet:latest 2> /dev/null)" == "" ]]; then
      echo "Building ImageNet image ..."
      CMD="DATASETS_DIR=${_DATASETS_DIR} IMAGENET_NAME=${_IMAGENET_NAME} $(ck find ck-qaic:docker:imagenet)/build.sh"
      echo ${CMD}; eval ${CMD}
      exit_if_error "Failed to build ImageNet image!"
    fi
    # Test ImageNet image.
    echo "Testing ImageNet image ..."
    CMD="docker run --rm imagenet:latest /bin/bash -c \"du -hs /imagenet\""
    echo ${CMD}; eval ${CMD}
    exit_if_error "Failed to test ImageNet image!"
  fi
  #-----------------------------------------------------------------------------
  # RetinaNet-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "retinanet" ]]; then
    WORKLOAD_DEPENDENT_PARAMS="COMPILE_PRO=${_COMPILE_PRO} COMPILE_STD=${_COMPILE_STD} PRECALIBRATED_PROFILE=${_PRECALIBRATED_PROFILE_RETINANET}"
  fi
  #-----------------------------------------------------------------------------
  # BERT-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "bert" ]]; then
    WORKLOAD_DEPENDENT_PARAMS="COMPILE_PRO=${_COMPILE_PRO} COMPILE_STD=${_COMPILE_STD} CK_QAIC_PCV=${_CK_QAIC_PCV_BERT}"
  fi
  echo
  #-----------------------------------------------------------------------------
  # Build & test.
  #-----------------------------------------------------------------------------
  # Build SDK-independent image.
  echo "Building SDK-independent image for '${_WORKLOAD}' ..."
  CMD="${WORKLOAD_INDEPENDENT_PARAMS} $(ck find repo:ck-qaic)/docker/build_ck.sh ${_WORKLOAD}"
  echo ${CMD}; eval ${CMD}
  exit_if_error "Failed to build SDK-independent image for '${_WORKLOAD}'!"
  echo
  # Test SDK-independent image.
  echo "Testing SDK-independent image for '${_WORKLOAD}' ..."
  CMD="docker run --rm ${SDK_INDEPENDENT_IMAGE}"
  echo ${CMD}; eval ${CMD}
  exit_if_error "Failed to test SDK-independent image for '${_WORKLOAD}'!"
  echo
  # Build SDK-dependent image.
  echo "Building SDK-dependent image for '${_WORKLOAD}' ..."
  CMD="${WORKLOAD_INDEPENDENT_PARAMS} ${WORKLOAD_DEPENDENT_PARAMS} $(ck find repo:ck-qaic)/docker/build.sh ${_WORKLOAD}"
  echo ${CMD}; eval ${CMD}
  exit_if_error "Failed to build SDK-dependent image for '${_WORKLOAD}'!"
  echo
  # Test SDK-dependent image.
  echo "Testing SDK-dependent image for '${_WORKLOAD}' ..."
  export SDK_VER=${_SDK_VER}
  CMD="docker run --privileged --group-add $(getent group qaic | cut -d: -f3) --rm ${SDK_DEPENDENT_IMAGE}"
  echo ${CMD}; eval ${CMD}
  #exit_if_error "Failed to test SDK-dependent image for '${_WORKLOAD}'!"
done # for WORKLOAD in WORKLOADS

#-------------------------------------------------------------------------------

echo
echo "DONE (building ALL images)."
echo

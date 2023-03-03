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
_CK_QAIC_PAT=${CK_QAIC_PAT:-""}
_CK_QAIC_BUILD_REPO=${CK_QAIC_BUILD_REPO:-"ck-qaic"}
_CK_QAIC_REPO=${CK_QAIC_REPO:-"ck-qaic"}
_CK_QAIC_CHECKOUT=${CK_QAIC_CHECKOUT:-"main"}
_WORKSPACE_DIR=${WORKSPACE_DIR:-"/local/mnt/workspace"}
_DATASETS_DIR=${DATASETS_DIR:-"${_WORKSPACE_DIR}/datasets"}
_IMAGENET_NAME=${IMAGENET_NAME:-"imagenet"}
_SDK_DIR=${SDK_DIR:-"${_WORKSPACE_DIR}/sdks"}
_SDK_VER=${SDK_VER:-1.8.3.7}
_PYTHON_VER=${PYTHON_VER:-3.9.16}
_GCC_MAJOR_VER=${GCC_MAJOR_VER:-11}
_CK_VER=${CK_VER:-2.6.1}
_GROUP_ID=${GROUP_ID:-1500}
_USER_ID=${USER_ID:-2000}
_COMPILE_DC=${COMPILE_DC:-no}
_COMPILE_EDGE=${COMPILE_EDGE:-no}
_COMPILE_PRO=${COMPILE_PRO:-yes}
_COMPILE_STD=${COMPILE_STD:-no}

# For Ubuntu 20.04, force system Python 3.8 and GCC 9.4.
if [[ "${_DOCKER_OS}" == "ubuntu" ]]; then
  _PYTHON_VER="3.8.10"
  _GCC_MAJOR_VER="11"
fi

# Use precalibrated profile.
_PRECALIBRATED_PROFILE=${PRECALIBRATED_PROFILE:-no}
_PRECALIBRATED_PROFILE_BERT=${PRECALIBRATED_PROFILE_BERT:-${_PRECALIBRATED_PROFILE}}
_PRECALIBRATED_PROFILE_RESNET50=${PRECALIBRATED_PROFILE_RESNET50:-${_PRECALIBRATED_PROFILE}}
_PRECALIBRATED_PROFILE_RETINANET=${PRECALIBRATED_PROFILE_RETINANET:-${_PRECALIBRATED_PROFILE}}
_PRECALIBRATED_PROFILE_SSD_RESNET34=${PRECALIBRATED_PROFILE_SSD_RESNET34:-${_PRECALIBRATED_PROFILE}}
_PRECALIBRATED_PROFILE_SSD_MOBILENET=${PRECALIBRATED_PROFILE_SSD_MOBILENET:-${_PRECALIBRATED_PROFILE}}

# Use percentile calibration value.
_PCV_BERT=${PCV_BERT:-9984}
_PCV_RESNET50=${PCV_RESNET50:-''}

# Use percentile calibration.
_PERCENTILE_CALIBRATION=${PERCENTILE_CALIBRATION:-no}
_PERCENTILE_CALIBRATION_BERT=${PERCENTILE_CALIBRATION_BERT:-${_PERCENTILE_CALIBRATION}}
_PERCENTILE_CALIBRATION_RESNET50=${PERCENTILE_CALIBRATION_RESNET50:-${_PERCENTILE_CALIBRATION}}

# Force '--no-cache' for all base/common/qaic and/or workload images.
_NO_CACHE=${NO_CACHE:-no}
# Build all base/common/qaic images with '--no-cache'.
_NO_CACHE_BASE=${NO_CACHE_BASE:-${_NO_CACHE}}
# Build all workload images with '--no-cache'.
_NO_CACHE_WORKLOAD=${NO_CACHE_WORKLOAD:-${_NO_CACHE}}

#===============================================================================
# Build & test base images.
#===============================================================================

# Build SDK-independent base image.
echo "Building SDK-independent base image ..."
CMD="NO_CACHE=${_NO_CACHE_BASE} DOCKER_OS=${_DOCKER_OS} GCC_MAJOR_VER=${_GCC_MAJOR_VER} PYTHON_VER=${_PYTHON_VER} $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base)/build.base.sh"
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
CMD="NO_CACHE=${_NO_CACHE_BASE} DOCKER_OS=${_DOCKER_OS} GCC_MAJOR_VER=${_GCC_MAJOR_VER} PYTHON_VER=${_PYTHON_VER} CK_VER=${_CK_VER} CK_QAIC_PAT=${_CK_QAIC_PAT} CK_QAIC_REPO=${_CK_QAIC_REPO} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} GROUP_ID=${_GROUP_ID} USER_ID=${_USER_ID} $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base)/build.ck.sh"
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
CMD="NO_CACHE=${_NO_CACHE_BASE} WORKSPACE_DIR=${_WORKSPACE_DIR} DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} SDK_DIR=${_SDK_DIR} GROUP_ID=${_GROUP_ID} USER_ID=${_USER_ID} $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base)/build.qaic.sh"
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
WORKLOAD_INDEPENDENT_PARAMS="NO_CACHE=${_NO_CACHE_WORKLOAD} CK_QAIC_PAT=${_CK_QAIC_PAT} CK_QAIC_REPO=${_CK_QAIC_REPO} CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} DOCKER_OS=${_DOCKER_OS} SDK_VER=${_SDK_VER} PYTHON_VER=${_PYTHON_VER} COMPILE_PRO=${_COMPILE_PRO} COMPILE_STD=${_COMPILE_STD} COMPILE_DC=${_COMPILE_DC} COMPILE_EDGE=${_COMPILE_EDGE}"
for _WORKLOAD in ${_WORKLOADS_AS_ARRAY[@]}
do
  SDK_INDEPENDENT_IMAGE="krai/ck.${_WORKLOAD}:${_DOCKER_OS}_latest"
  SDK_DEPENDENT_IMAGE="krai/mlperf.${_WORKLOAD}:${_DOCKER_OS}_${_SDK_VER}"
  #-----------------------------------------------------------------------------
  # ResNet50-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "resnet50" ]]; then
    SDK_DEPENDENT_IMAGE="krai/mlperf.${_WORKLOAD}.full:${_DOCKER_OS}_${_SDK_VER}"
    WORKLOAD_DEPENDENT_PARAMS="PRECALIBRATED_PROFILE=${_PRECALIBRATED_PROFILE_RESNET50} CK_QAIC_PCV=${_PCV_RESNET50}" # TODO: Add PERCENTILE_CALIBRATION_RESNET50?
    # Build ImageNet image.
    if [[ "$(docker images -q imagenet:latest 2> /dev/null)" == "" ]]; then
      echo "Building ImageNet image ..."
      CMD="DATASETS_DIR=${_DATASETS_DIR} IMAGENET_NAME=${_IMAGENET_NAME} $(ck find ${_CK_QAIC_BUILD_REPO}:docker:imagenet)/build.sh"
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
  # BERT-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "bert" ]]; then
    WORKLOAD_DEPENDENT_PARAMS="PRECALIBRATED_PROFILE=${_PRECALIBRATED_PROFILE_BERT} CK_QAIC_PCV=${_PCV_BERT}" # TODO: Add PERCENTILE_CALIBRATION_BERT?
  fi
  #-----------------------------------------------------------------------------
  # RetinaNet-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "retinanet" ]]; then
    WORKLOAD_DEPENDENT_PARAMS="PRECALIBRATED_PROFILE=${_PRECALIBRATED_PROFILE_RETINANET}"
  fi
  #-----------------------------------------------------------------------------
  # SSD-ResNet34-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "ssd-resnet34" ]]; then
    WORKLOAD_DEPENDENT_PARAMS="PRECALIBRATED_PROFILE=${_PRECALIBRATED_PROFILE_SSD_RESNET34}"
  fi
  #-----------------------------------------------------------------------------
  # SSD-MobileNet-dependent setup.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "ssd-mobilenet" ]]; then
    WORKLOAD_DEPENDENT_PARAMS="PRECALIBRATED_PROFILE=${_PRECALIBRATED_PROFILE_SSD_MOBILENET}"
  fi
  #-----------------------------------------------------------------------------
  # Common SSD-ResNet34 and SSD-MobileNet-dependent setup: build COCO image.
  #-----------------------------------------------------------------------------
  if [[ ${_WORKLOAD} == "ssd-mobilenet" ]] || [[ ${_WORKLOAD} == "ssd-resnet34" ]]; then
    # Build COCO image.
    if [[ "$(docker images -q coco:latest 2> /dev/null)" == "" ]]; then
      echo "Building COCO image ..."
      CMD="${WORKLOAD_INDEPENDENT_PARAMS} $(ck find repo:${_CK_QAIC_BUILD_REPO})/docker/build_ck.sh coco"
      echo ${CMD}; eval ${CMD}
      exit_if_error "Failed to build COCO image!"
    fi
    # Test COCO image.
    echo "Testing COCO image ..."
    CMD="docker run --rm coco:latest"
    echo ${CMD}; eval ${CMD}
    exit_if_error "Failed to test COCO image for '${_WORKLOAD}'!"
    echo
  fi
  #-----------------------------------------------------------------------------
  echo
  #-----------------------------------------------------------------------------
  # Build & test.
  #-----------------------------------------------------------------------------
  # Build SDK-independent workload image.
  echo "Building SDK-independent image for '${_WORKLOAD}' ..."
  CMD="${WORKLOAD_INDEPENDENT_PARAMS} $(ck find repo:${_CK_QAIC_BUILD_REPO})/docker/build_ck.sh ${_WORKLOAD}"
  echo ${CMD}; eval ${CMD}
  exit_if_error "Failed to build SDK-independent image for '${_WORKLOAD}'!"
  echo
  # Test SDK-independent workload image.
  echo "Testing SDK-independent image for '${_WORKLOAD}' ..."
  CMD="docker run --rm ${SDK_INDEPENDENT_IMAGE}"
  echo ${CMD}; eval ${CMD}
  exit_if_error "Failed to test SDK-independent image for '${_WORKLOAD}'!"
  echo
  # Build SDK-dependent workload image.
  echo "Building SDK-dependent image for '${_WORKLOAD}' ..."
  CMD="${WORKLOAD_INDEPENDENT_PARAMS} ${WORKLOAD_DEPENDENT_PARAMS} $(ck find repo:${_CK_QAIC_BUILD_REPO})/docker/build.sh ${_WORKLOAD}"
  echo ${CMD}; eval ${CMD}
  exit_if_error "Failed to build SDK-dependent image for '${_WORKLOAD}'!"
  echo
  # Test SDK-dependent workload image.
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

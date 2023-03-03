#!/bin/bash

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

if [[ $# < 1 ]]; then
  echo "Please enter the model name to build the Docker image for (one of: bert, resnet50, retinanet, ssd-resnet34, ssd-mobilenet).";
  exit 1;
fi

function exit_if_error() {
  if [ "${?}" != "0" ]; then exit 1; fi
}

MODEL=$1

echo "Building image for '${MODEL}' ..."

_DOCKER_OS=${DOCKER_OS:-"ubuntu"}
_BASE_IMAGE=${BASE_IMAGE:-"krai/qaic"}
_SDK_VER=${SDK_VER:-"1.7.1.12"}

_CK_QAIC_PAT=${CK_QAIC_PAT:-""}
_CK_QAIC_REPO=${CK_QAIC_REPO:-"ck-qaic"}
_CK_QAIC_CHECKOUT=${CK_QAIC_CHECKOUT:-"main"}
_CK_QAIC_BUILD_REPO=${CK_QAIC_BUILD_REPO:-"ck-qaic"}

_CK_QAIC_PCV=${CK_QAIC_PCV:-''}
_CK_QAIC_PERCENTILE_CALIBRATION=${CK_QAIC_PERCENTILE_CALIBRATION:-no}

_PRECALIBRATED_PROFILE=${PRECALIBRATED_PROFILE:-no}
# Compile for Datacenter scenarios: Offline (always included), Server.
_COMPILE_DC=${COMPILE_DC:-no}
# Compile for Edge scenarios: Offline (always included), SingleStream, MultiStream.
_COMPILE_EDGE=${COMPILE_EDGE:-no}
# Compile for PCIe Pro cards (16 NSPs).
_COMPILE_PRO=${COMPILE_PRO:-yes}
# Compile for PCIe Standard cards (14 NSPs).
_COMPILE_STD=${COMPILE_STD:-no}

_DEBUG_BUILD=${DEBUG_BUILD:-no}
_SAVE_IMAGE=${SAVE_IMAGE:-no}

QAIC_GROUP_ID=$(getent group qaic | cut -d: -f3)
_GROUP_ID=${GROUP_ID:-${QAIC_GROUP_ID}}
_USER_ID=${USER_ID:-2000}

EXTRA_DOCKER_ARG=""

if [[ ${MODEL} == "resnet50" ]]; then
  _IMAGENET=${IMAGENET:-full}
  if [[ "${_IMAGENET}" == "full" || "${_IMAGENET}" == "preprocessed" ]]
  then
    _IMAGENET_SUFFIX="full"
  else
    _IMAGENET_SUFFIX="min"
  fi
  DOCKER_IMAGE_NAME="krai/mlperf.${MODEL}.${_IMAGENET_SUFFIX}"
else
  DOCKER_IMAGE_NAME="krai/mlperf.${MODEL}"
fi

HASH_REPLACE=""
if [[ "${PRECALIBRATED_PROFILE}" == "yes" ]]; then
  # Profile hashes for SSD-ResNet34.
  _OLD_PROFILE_HASH=${OLD_PROFILE_HASH:-0xDAA5B34A47B4A6B1} # v2.0 profile
  _NEW_PROFILE_HASH=${NEW_PROFILE_HASH:-0x204696F6ADF96AB2} # v1.8.0.137 hash
  if [[ "${MODEL}" == "ssd-resnet34" ]] || [[ "${MODEL}" == "retinanet" ]]; then
    HASH_REPLACE="sed -i 's/${_OLD_PROFILE_HASH}/${_NEW_PROFILE_HASH}/g' ./${MODEL}/bs.1/profile.yaml &&";
  fi
fi

if [[ ${_CK_QAIC_PERCENTILE_CALIBRATION} == "yes" ]]; then
  _DEBUG_BUILD=yes
fi

if [[ ${_DEBUG_BUILD} != 'no' ]]; then tag_suffix='_DEBUG'; else tag_suffix=''; fi

_NO_CACHE=${NO_CACHE:-"no"}
if [[ "${_NO_CACHE}" == "yes" ]]; then
  __NO_CACHE="--no-cache"
fi

#if [[ ${CLEAN_MODEL_BASE} == 'yes' ]]; then
#  docker image rm krai/ck.${MODEL}:${_DOCKER_OS}_latest --force
#fi

if [[ "$(docker images -q krai/qaic:${_DOCKER_OS}_${_SDK_VER} 2> /dev/null)" == "" ]]; then
  echo "Building base SDK image for v${_SDK_VER} ...";
  cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base) && SDK_VER=${_SDK_VER} ./build.qaic.sh
  exit_if_error
fi

if [[ "$(docker images -q krai/ck.${MODEL}:${_DOCKER_OS}_latest 2> /dev/null)" == "" ]]; then
  echo "Building base CK image for '${MODEL}' ...";
  cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:base) && IMAGENET=${_IMAGENET} ../build_ck.sh ${MODEL}
  exit_if_error
fi

read -d '' CMD <<END_OF_CMD
cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:${MODEL}) && \
cp -r $(ck find repo:${_CK_QAIC_BUILD_REPO})/profile/${MODEL} . && \
${HASH_REPLACE} \
time docker build ${__NO_CACHE} \
--build-arg BASE_IMAGE=${_BASE_IMAGE} \
--build-arg SDK_VER=${_SDK_VER} \
--build-arg DOCKER_OS=${_DOCKER_OS} \
${EXTRA_DOCKER_ARG} \
--build-arg CK_QAIC_PAT=${_CK_QAIC_PAT} \
--build-arg CK_QAIC_REPO=${_CK_QAIC_REPO} \
--build-arg CK_QAIC_CHECKOUT=${_CK_QAIC_CHECKOUT} \
--build-arg CK_QAIC_PCV=${_CK_QAIC_PCV} \
--build-arg CK_QAIC_PERCENTILE_CALIBRATION=${_CK_QAIC_PERCENTILE_CALIBRATION} \
--build-arg COMPILE_DC=${_COMPILE_DC} \
--build-arg COMPILE_EDGE=${_COMPILE_EDGE} \
--build-arg COMPILE_PRO=${_COMPILE_PRO} \
--build-arg COMPILE_STD=${_COMPILE_STD} \
--build-arg PRECALIBRATED_PROFILE=${_PRECALIBRATED_PROFILE} \
--build-arg DEBUG_BUILD=${_DEBUG_BUILD} \
-t ${DOCKER_IMAGE_NAME}:${_DOCKER_OS}_${_SDK_VER}${tag_suffix} \
-f Dockerfile.mlperf .
END_OF_CMD
echo "Running: ${CMD}"
if [ -z "${DRY_RUN}" ]; then
  eval ${CMD}
fi
exit_if_error

if [[ ${_CK_QAIC_PERCENTILE_CALIBRATION} == "yes" ]]; then
  if [[ "$(docker images -q ${DOCKER_IMAGE_NAME}:${_DOCKER_OS}_${_SDK_VER}_PC 2> /dev/null)" == "" ]]; then
    CONTAINER=$(docker run -dt --privileged --user=krai:kraig --group-add $(getent group qaic \
      | cut -d: -f3) --rm ${DOCKER_IMAGE_NAME}:${_DOCKER_OS}_${_SDK_VER}${tag_suffix} bash)

    if [[ "${_COMPILE_STD}" == "yes" ]]; then _NSP_COUNT=14 _CARD=std ; fi
    if [[ "${_COMPILE_PRO}" == "yes" ]]; then _NSP_COUNT=16 _CARD=pro ; fi

    if [[ "${MODEL}" == "resnet50" ]]; then
      docker exec $CONTAINER /bin/bash -c "ck clean env --tags=compiled,resnet50.pcie.${_NSP_COUNT}nsp --force"
      docker exec $CONTAINER /bin/bash -c "\$(ck find repo:ck-qaic)/package/model-qaic-compile/percentile-calibration.sh \
        resnet50 resnet50.pcie.${_NSP_COUNT}nsp.offline offline ${_SDK_VER} ${_CARD};"
    fi

    if [[ "${MODEL}" == "bert" ]]; then
      docker exec $CONTAINER /bin/bash -c "ck clean env --tags=compiled,bert-99 --force"
      docker exec $CONTAINER /bin/bash -c "\$(ck find repo:ck-qaic)/package/model-qaic-compile/percentile-calibration.sh \
        bert-99 bert-99.pcie.${_NSP_COUNT}nsp.offline,seg.384 offline ${_SDK_VER} ${_CARD};"
    fi

    if [[ "${MODEL}" == "retinanet" ]]; then
      docker exec $CONTAINER /bin/bash -c "ck clean env --tags=compiled,retinanet --force"
      docker exec $CONTAINER /bin/bash -c "\$(ck find repo:ck-qaic)/package/model-qaic-compile/percentile-calibration.sh \
        retinanet retinanet.pcie.${_NSP_COUNT}nsp.offline offline ${_SDK_VER} ${_CARD};"
    fi

    if [[ "${MODEL}" == "ssd-resnet34" ]]; then
      docker exec $CONTAINER /bin/bash -c "ck clean env --tags=compiled,ssd-resnet34 --force"
      docker exec $CONTAINER /bin/bash -c "\$(ck find repo:ck-qaic)/package/model-qaic-compile/percentile-calibration.sh \
        ssd-resnet34 ssd-resnet34.pcie.${_NSP_COUNT}nsp.offline offline ${_SDK_VER} ${_CARD};"
    fi

    if [[ "${MODEL}" == "ssd-mobilenet" ]]; then
      docker exec $CONTAINER /bin/bash -c "ck clean env --tags=compiled,ssd-mobilenet --force"
      docker exec $CONTAINER /bin/bash -c "\$(ck find repo:ck-qaic)/package/model-qaic-compile/percentile-calibration.sh \
        ssd-mobilenet ssd-mobilenet.pcie.${_NSP_COUNT}nsp.offline offline ${_SDK_VER} ${_CARD};"
    fi

    docker exec $CONTAINER /bin/bash -c 'ck rm experiment:* --force'
    docker commit $CONTAINER ${DOCKER_IMAGE_NAME}:${_DOCKER_OS}_${_SDK_VER}'_PC'

read -d '' CMD <<END_OF_CMD
  cd $(ck find ${_CK_QAIC_BUILD_REPO}:docker:${MODEL}) && \
  time docker build ${__NO_CACHE} \
  --build-arg BASE_IMAGE=${_BASE_IMAGE} \
  --build-arg SDK_VER=${_SDK_VER} \
  --build-arg DOCKER_OS=${_DOCKER_OS} \
  -t ${DOCKER_IMAGE_NAME}:${_DOCKER_OS}_${_SDK_VER} \
  -f Dockerfile.pc .
END_OF_CMD
    echo "Running: ${CMD}"
    if [ -z "${DRY_RUN}" ]; then
      eval ${CMD}
    fi
  fi
fi

if [[ ${_SAVE_IMAGE} == 'yes' ]]; then
  docker image save ${DOCKER_IMAGE_NAME}:${_DOCKER_OS}_${_SDK_VER}${tag_suffix} -o ${HOME}/${MODEL}'.'${_SDK_VER}
fi

echo
echo "Done (building '${DOCKER_IMAGE_NAME}:${_DOCKER_OS}_${_SDK_VER}${tag_suffix}')"
echo

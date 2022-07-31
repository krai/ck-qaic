#!/bin/bash

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
function exit_if_error() {
    if [ "${?}" != "0" ]; then exit 1; fi
}

aic_binary_dir=./elfs

mkdir -p ${INSTALL_DIR}/install
mkdir -p ${INSTALL_DIR}/${aic_binary_dir}

if [ -e ${aic_binary_dir}/constants.bin ]; then
    # qaic-exec can't dump the constants binary if it already exists
    rm -f ${aic_binary_dir}/constants.bin
fi

rm -rf $aic_binary_dir

# Quantization profile.
profile=${CK_ENV_COMPILER_GLOW_PROFILE_YAML}
echo "Profile: '${profile}'"

# Model: assume either ONNX or TF.
model=${CK_ENV_ONNX_MODEL_ONNX_FILEPATH:-$CK_ENV_TENSORFLOW_MODEL_TF_FROZEN_FILEPATH}
# Source model.
echo "Model: '${model}'"

_COMPILER_PARAMS_SCENARIO_BASE=_COMPILER_PARAMS_${_COMPILER_PARAMS_SCENARIO_NAME}_BASE
_COMPILER_ARGS_SCENARIO=${_COMPILER_ARGS_NAME_PREFIX}"_COMPILER_ARGS_"${_COMPILER_PARAMS_SCENARIO_NAME}
_COMPILER_PARAMS=${!_COMPILER_PARAMS_SCENARIO_BASE}" "${!_COMPILER_ARGS_SCENARIO}" "${_COMPILER_PARAMS_SUT}" "${_COMPILER_PARAMS}

if [[ -n ${_EXTERNAL_QUANTIZATION} ]]; then
  echo ${CK_ENV_COMPILER_GLOW_PROFILE_DIR}
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[EXTERNAL_QUANTIZATION_FILE]"/$profile}
  LOAD_PROFILE=""
elif [[ -n ${_NO_QUANTIZATION} ]]; then
  LOAD_PROFILE=""
else
  LOAD_PROFILE="-load-profile=${profile}"
fi

if [[ -n ${_ENABLE_CHANNEL_WISE} ]]; then
  _COMPILER_PARAMS=${_COMPILER_PARAMS}" -enable-channelwise"
fi

if [[ -n ${CK_ENV_COMPILER_GLOW_PROFILE_DIR} ]]; then
  node_precision="${CK_ENV_COMPILER_GLOW_PROFILE_DIR}/node-precision.yaml"
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[NODE_PRECISION_FILE]"/$node_precision}
fi

if [[ -n ${_SEG} ]]; then
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[SEG]"/$_SEG}
fi

if [[ -n ${_BATCH_SIZE_EXPLICIT} ]]; then
  _BATCH_SIZE=${_BATCH_SIZE:-1}
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[BATCH_SIZE]"/${_BATCH_SIZE}}
else
  if [[ ${_BATCH_SIZE} > 0 ]]; then
    _COMPILER_PARAMS=${_COMPILER_PARAMS}" -batchsize=$_BATCH_SIZE"
  fi
fi

if [[ -n ${_PERCENTILE_CALIBRATION_VALUE} ]]; then
  _QUANTIZATION_PARAMS=${_QUANTIZATION_PARAMS/"[PERCENTILE_CALIBRATION_VALUE]"/$_PERCENTILE_CALIBRATION_VALUE}
fi

_COMPILER_PARAMS="${_COMPILER_PARAMS} ${_QUANTIZATION_PARAMS} ${_EXTRA_COMPILER_PARAMS}"

if [[ -n ${_COMPILER_PARAMS} ]]; then
  echo "Compiler Params: ${_COMPILER_PARAMS}"
  # Compile only.
  echo
  echo "Compile QAIC network binaries:"
  read -d '' CMD <<END_OF_CMD
  ${QAIC_TOOLCHAIN_PATH}/exec/qaic-exec -model=${model} \
  ${LOAD_PROFILE} -aic-binary-dir=${aic_binary_dir} \
  ${_COMPILER_PARAMS}
END_OF_CMD
  echo ${CMD}
  eval ${CMD}
  exit_if_error
  export COMPILER_PARAMS=${_COMPILER_PARAMS}
  echo "Done."
  exit
fi
exit -1


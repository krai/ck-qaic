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

# remove a previous installation if it exists
rm -rf ${INSTALL_DIR}/*

BIN_DIR=elfs

if [ "$_PRECISION" = mixed ]; then

echo "Generating mixed precision model..."

${QAIC_TOOLCHAIN_PATH}/exec/qaic-exec -aic-num-cores=4 -load-profile=${CK_ENV_COMPILER_GLOW_PROFILE_YAML} -m=${CK_ENV_ONNX_MODEL_ONNX_FILEPATH} \
    -aic-binary-dir=${INSTALL_DIR}/${BIN_DIR} -aic-hw -aic-hw-version=2.0 \
    -execute-nodes-in-fp16=Mul,Add,Div,Erf,Softmax,Sub,Gather,LayerNormalization,Mul \
    -quantization-schema=symmetric_with_uint8 -quantization-precision=Int8 -aic-minimize-host-traffic \
    -quantization-precision-bias=Int32 -quantization-calibration=Percentile -percentile-calibration-value=99.9980 \
    -compiler-args="-onnx-define-symbol=batch_size,1 -onnx-define-symbol=seg_length,${_SEG} -aic-form-axis-uniform-constants -aic-ddr-to-multicast -aic-userdma-producer-dma" \
    -aic-compile-only-test

elif [ "$_PRECISION" = fp16 ]; then

echo "Generating fp16 precision model..."

${QAIC_TOOLCHAIN_PATH}/exec/qaic-exec \
    -m=${CK_ENV_ONNX_MODEL_ONNX_FILEPATH} \
    -convert-to-fp16 \
    -aic-hw -aic-num-cores=4 -mos=4 -ols=1 \
    '-compiler-args=-aic-perf-metrics -aic-time-passes -aic-version -aic-ddr-to-multicast -aic-form-axis-uniform-constants -aic-userdma-producer-dma -onnx-define-symbol=batch_size,1 -onnx-define-symbol=seg_length,384' \
    -aic-compile-only-test \
    -aic-binary-dir=${INSTALL_DIR}/${BIN_DIR}

else
#not a valid option
exit 1
fi


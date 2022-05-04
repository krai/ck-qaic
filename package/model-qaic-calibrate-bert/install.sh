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

# remove the old installation if it exists.
rm -rf *


mkdir -p packed


# pack the dataset

PYTHONPATH=$PYTHONPATH:${CK_ENV_MLPERF_INFERENCE}/language/bert/ \
${CK_ENV_COMPILER_PYTHON_FILE} ${ORIGINAL_PACKAGE_DIR}/pack.py ${CK_ENV_DATASET_SQUAD_TOKENIZED} ${INSTALL_DIR}/packed \
                               ${ORIGINAL_PACKAGE_DIR}/strategySetCalib.txt ${ORIGINAL_PACKAGE_DIR}/strategyRepeatCountCalib.txt

# create a list of the input files

cd packed
for dir in */; do
    echo "./$dir/input_ids.raw,./$dir/input_mask.raw,./$dir/segment_ids.raw,./$dir/input_position_ids.raw" >> inputfiles.txt
done

# quantize the model

${QAIC_TOOLCHAIN_PATH}/exec/qaic-exec -m=${CK_ENV_ONNX_MODEL_ROOT}/model.onnx \
-onnx-define-symbol=batch_size,1 -onnx-define-symbol=seg_length,${_PACKED_SEQ_LEN} \
-input-list-file=${INSTALL_DIR}/packed/inputfiles.txt -num-histogram-bins=512 -dump-profile=${INSTALL_DIR}/profile.yaml -profiling-threads=4

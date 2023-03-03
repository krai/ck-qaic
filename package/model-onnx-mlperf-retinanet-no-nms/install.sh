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

INSTALL_SCRIPT_NAME=install.sh

echo "${INSTALL_SCRIPT_NAME} : Converting Retinanet ResNext50 from Pytorch to ONNX and stripping NMS..."

cd ${INSTALL_DIR}

rm -rf *

if [[ -n ${_DOWNLOAD} ]]; then

wget https://zenodo.org/record/6951458/files/retinanet.onnx

else

#clone mlcommons training directory to access script to convert from pytorch to ONNX
git clone https://github.com/mlcommons/training.git
exit_if_error

#apply patch to terminate the model before NMS and to dump the priors
cd training
git apply --reject --whitespace=fix ${ORIGINAL_PACKAGE_DIR}/remove-nms-and-extract-priors.patch
exit_if_error

#run the script to generate the binary
cd ${INSTALL_DIR}

PYTHONPATH=${INSTALL_DIR}/training/single_stage_detector/ssd/
${CK_ENV_COMPILER_PYTHON_FILE} ${INSTALL_DIR}/training/single_stage_detector/scripts/pth_to_onnx.py \
                               --input ${CK_ENV_PYTORCH_MODEL_PYTORCH_FILEPATH} \
                               --output ${INSTALL_DIR}//retinanet.onnx \
                               --image-size 800 800
exit_if_error

# remove temporary files
rm -rf ${INSTALL_DIR}/training

fi

echo "${INSTALL_SCRIPT_NAME} : Done."

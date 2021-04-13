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

# Model: assume either ONNX or TF.
model=${CK_ENV_ONNX_MODEL_ONNX_FILEPATH:-$CK_ENV_TENSORFLOW_MODEL_TF_FROZEN_FILEPATH}
echo "Model: '${model}'"

if [[ -n ${_AIMET_MODEL} ]]; then
     AIMET_RUN="${INSTALL_DIR}/ssd-resnet34"
     cp -r ${PACKAGE_DIR}/$AIMET_RUN .
     PYTHON="/usr/bin/python3.6"
     COCO_CAL_DIR="${CK_ENV_DATASET_IMAGE_DIR}/${CK_ENV_DATASET_COCO_TRAIN_TRAIN_IMAGE_DIR}"
     PYTHONPATH=${PYTHONPATH}:${CK_ENV_MLPERF_INFERENCE}/vision/classification_and_detection/python
     PYTHONPATH=${CK_ENV_MLPERF_INFERENCE}/vision/classification_and_detection/python
     AIMET_PATH=${CK_ENV_LIB_AIMET}/../../../lib/x86_64-linux-gnu:${CK_ENV_LIB_AIMET}/../../../lib/python
     export PYTHONPATH=${AIMET_PATH}:$PYTHONPATH
     export LD_LIBRARY_PATH=${AIMET_PATH}:$LD_LIBRARY_PATH
     export LD_LIBRARY_PATH=${AIMET_PATH}
     cd ${AIMET_RUN}
     rm -rf output
     rm -rf preprocessed
     ln -s ${CK_ENV_MLPERF_INFERENCE} inference
     wget -nc "https://zenodo.org/record/3236545/files/resnet34-ssd1200.pytorch"
     echo "PYTHONPATH=${PYTHONPATH} LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${PYTHON} ssd_resnet_aimet.py resnet34-ssd1200.pytorch annotations.json ${COCO_CAL_DIR}"
     ${PYTHON} ssd_resnet_aimet.py resnet34-ssd1200.pytorch annotations.json ${COCO_CAL_DIR}
     exit_if_error
     rm -rf preprocessed
     echo "Done."
     exit 0
fi

# Calibration dataset.
images=${CK_ENV_DATASET_PREPROCESSED_DIR}/${CK_ENV_DATASET_PREPROCESSED_FOF}
echo "Calibration images: '${images}'"
# Remove old files.
rm -f ${INSTALL_DIR}/*.raw
# Remove old image list file.
image_list="${INSTALL_DIR}/image_list.txt"
rm -f ${image_list}

# Batch size.
batchsize=${_BATCH_SIZE:-1}

filenames=`cat $images`
i=0;
lastset=""
for filename in ${filenames}
do
  echo $filename
  filename="${filename%%;*}"
  if [[ $(($i%$batchsize)) == 0 ]]; then
     #echo $filename;
     newfilename="${filename}.raw"
     echo "${INSTALL_DIR}/${newfilename}" >>${image_list}
  fi
  if [[ $i -lt $batchsize ]]; then
    lastset="${filename}#${lastset}"
  fi
  echo "cat ${CK_ENV_DATASET_PREPROCESSED_DIR}/$filename >> ${INSTALL_DIR}/${newfilename}"
  cat "${CK_ENV_DATASET_PREPROCESSED_DIR}/$filename" >> "${INSTALL_DIR}/${newfilename}"
  exit_if_error
  let i++;
done
IFS='#' read -ra XFILE <<< "$lastset"
j=0
size=${#XFILE[$@]}
while [ $(($i%$batchsize)) -ne 0 ] 
do
     if [[ $j -eq $size ]]; then
       j=0;
     fi
     filename=${XFILE[$j]}
     echo "cat ${CK_ENV_DATASET_PREPROCESSED_DIR}/$filename >> ${INSTALL_DIR}/${newfilename}"
     cat "${CK_ENV_DATASET_PREPROCESSED_DIR}/$filename" >> "${INSTALL_DIR}/${newfilename}"
     exit_if_error
     let i++;
     let j++;
done


if [[ -n ${_COMPILER_PARAMS} ]]; then
  # Generate the profile.yaml file from the calibration dataset using best known options.
  echo ${_COMPILER_PARAMS}
  read -d '' CMD <<END_OF_CMD
  ${QAIC_TOOLCHAIN_PATH}/exec/qaic-exec \
  -input-list-file=${image_list} \
  -batchsize=${batchsize} \
  ${_COMPILER_PARAMS} \
  -dump-profile=${INSTALL_DIR}/profile.yaml \
  -model=${model}
END_OF_CMD
  echo ${CMD}
  eval ${CMD}
  exit_if_error
  echo "Done."
  exit 0
fi

exit -1

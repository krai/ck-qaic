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

if [[ -n ${_NODE_PRECISION_FILE_PATH} ]]; then
     echo "Copying Node Precision file: '${_NODE_PRECISION_FILE_PATH}'";
     cp ${PACKAGE_DIR}/${_NODE_PRECISION_FILE_PATH} ${INSTALL_DIR}/
     _COMPILER_PARAMS=${_COMPILER_PARAMS/"[NODE_PRECISION_FILE]"/${INSTALL_DIR}/node-precision.yaml}
fi

if [[ -n ${_AIMET_MODEL} ]]; then
     AIMET_RUN="ssd-resnet34"
     rm -rf ${INSTALL_DIR}/$AIMET_RUN
     cp -r ${PACKAGE_DIR}/$AIMET_RUN ${INSTALL_DIR}/$AIMET_RUN
     PYTHON="${CK_ENV_COMPILER_PYTHON_FILE}"
     COCO_CAL_DIR="${CK_ENV_DATASET_IMAGE_DIR}/${CK_ENV_DATASET_COCO_TRAIN_TRAIN_IMAGE_DIR}"
     cd ${INSTALL_DIR}/${AIMET_RUN}
     rm -rf output
     rm -rf preprocessed
     ${PYTHON} -m pip install torchvision==0.5.0 pycocotools numpy pyyaml tensorboard tqdm onnx Pillow jsonschema opencv-python-headless
     ln -s ${CK_ENV_MLPERF_INFERENCE} inference
     wget -nc "https://zenodo.org/record/3236545/files/resnet34-ssd1200.pytorch"
     #echo "PYTHONPATH=${PYTHONPATH} LD_LIBRARY_PATH=${LD_LIBRARY_PATH} ${PYTHON} ssd_resnet_aimet.py resnet34-ssd1200.pytorch annotations.json ${COCO_CAL_DIR}"
     ${PYTHON} ssd_resnet_aimet.py resnet34-ssd1200.pytorch annotations.json ${COCO_CAL_DIR}
     mv output/ssd_resnet34_aimet.encodings.yaml ${INSTALL_DIR}/profile.yaml
     mv output/ssd_resnet34_aimet.onnx ${INSTALL_DIR}/
     mv node-precision.yaml ${INSTALL_DIR}/
     rm -rf output
     exit_if_error
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


# If batch size is explicit then place the batch size in the command line.
batchsize=${_BATCH_SIZE:-1}

if [[ -n ${_BATCH_SIZE_EXPLICIT} ]]; then
_COMPILER_PARAMS=${_COMPILER_PARAMS/"[BATCH_SIZE]"/${_BATCH_SIZE}}
batch_size_implicit=""
else
batch_size_implicit="-batchsize=${batchsize}"
fi

if [[ -n ${_IMAGE_ORDER_FILE_PATH} ]]; then
filenames=`cat  ${PACKAGE_DIR}/$_IMAGE_ORDER_FILE_PATH | sed "s/jpg/rgbf32/g"`
echo ${PACKAGE_DIR}/$_IMAGE_ORDER_FILE_PATH
echo $filenames
else
filenames=`cat $images`
fi

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
  ${batch_size_implicit} \
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

#!/bin/bash

_INSTALL_BENCHMARK_RESNET50=${INSTALL_BENCHMARK_RESNET50:-"yes"}
_INSTALL_BENCHMARK_BERT=${INSTALL_BENCHMARK_BERT:-"yes"}
_DEVICE_DATASETS_DIR=${DEVICE_DATASETS_DIR:-"${HOME}"}

. run_common.sh

echo "Running '$0'"
print_variables "${!_@}"

if [[ "${_INSTALL_BENCHMARK_RESNET50}" == "yes" ]]; then
  _DEVICE_DATASETS=${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val
  if [[ -d "${_DEVICE_DATASETS}" ]]; then
    echo "Directory '${_DEVICE_DATASETS}' already exists!"
  else
    echo "Extracting dataset to '${_DEVICE_DATASETS}'"
    tar -xvf ${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val.tar -C ${_DEVICE_DATASETS_DIR}
    # Detect dataset.
    ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
    --full_path=${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG

    # Preprocess dataset.
    ck install package \
    --dep_add_tags.dataset-source=original,full \
    --tags=dataset,imagenet,val,full,preprocessed,using-opencv,for.resnet50.quantized,layout.nhwc,side.224,validation
    exit_if_error "Failed to preprocess ImageNet dataset!"
  fi
fi

if [[ "${_INSTALL_BENCHMARK_BERT}" == "yes" ]]; then

  # Install implicit dependencies via pip.
  source $HOME/.bashrc
  exit_if_empty ${CK_PYTHON} "Please set CK_PYTHON first!"
  ${CK_PYTHON} -m pip install --user onnx-simplifier
  ${CK_PYTHON} -m pip install --user tokenization
  ${CK_PYTHON} -m pip install --user nvidia-pyindex
  ${CK_PYTHON} -m pip install --user onnx-graphsurgeon==0.3.11

  # Install explicit dependencies via CK (also via pip, but register with CK at the same time).
  ck install package --tags=python-package,onnx --force_version=1.8.1 --quiet
  ck install package --tags=lib,python-package,pytorch --force_version=1.8.1 --quiet
  ck install package --tags=lib,python-package,transformers --force_version=2.4.0

  # Download the SQuAD v1.1 dataset.
  ck install package --tags=dataset,squad,raw,width.384 --quiet
  ck install package --tags=dataset,calibration,squad,pickle,width.384 --quiet
fi

# TODO
# if [[ "${_INSTALL_BENCHMARKS_OBJECT_DETECTION}" == "yes" ]]; then
# fi

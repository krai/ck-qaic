#!/bin/bash

_INSTALL_WORKLOAD_RESNET50=${INSTALL_WORKLOAD_RESNET50:-"yes"}
_INSTALL_WORKLOAD_BERT=${INSTALL_WORKLOAD_BERT:-"yes"}
_DEVICE_DATASETS_DIR=${DEVICE_DATASETS_DIR:-"${HOME}"}
_DEVICE_IMAGENET_DIR=${DEVICE_IMAGENET_DIR:-dataset-imagenet-ilsvrc2012-val}

. common.sh

echo "Running '$0' ..."
print_variables "${!_@}"
echo
echo "Press Ctrl-C to break ..."
sleep 10

if [[ "${_INSTALL_WORKLOAD_RESNET50}" == "yes" ]]; then
  _DEVICE_DATASETS=${_DEVICE_DATASETS_DIR}/${_DEVICE_IMAGENET_DIR}
  if [[ -d "${_DEVICE_DATASETS}" ]]; then
    echo "Directory '${_DEVICE_DATASETS}' already exists!"
  else
    # Extract dataset.
    echo "Extracting dataset to '${_DEVICE_DATASETS}' ..."
    tar -xvf ${_DEVICE_DATASETS_DIR}/${_DEVICE_IMAGENET_DIR}.tar -C ${_DEVICE_DATASETS_DIR}
    exit_if_error "Failed to extract ImageNet dataset!"
    # Detect dataset.
    echo "full" | ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
    --full_path=${_DEVICE_DATASETS_DIR}/${_DEVICE_IMAGENET_DIR}/ILSVRC2012_val_00000001.JPEG
    exit_if_error "Failed to detect ImageNet dataset!"
    # Preprocess dataset.
    ck install package \
    --dep_add_tags.dataset-source=original,full \
    --tags=dataset,imagenet,val,full,preprocessed,using-opencv,for.resnet50.quantized,layout.nhwc,side.224,validation
    exit_if_error "Failed to preprocess ImageNet dataset!"
  fi
fi

if [[ "${_INSTALL_WORKLOAD_BERT}" == "yes" ]]; then

  # Install implicit dependencies via pip.
  source $HOME/.bashrc
  exit_if_empty ${CK_PYTHON} "Please set CK_PYTHON first!"
  ${CK_PYTHON} -m pip install --user onnx-simplifier
  ${CK_PYTHON} -m pip install --user tokenization
  #${CK_PYTHON} -m pip install --user nvidia-pyindex
  #${CK_PYTHON} -m pip install --user onnx-graphsurgeon==0.3.11

  # Install explicit dependencies via CK (also via pip, but register with CK at the same time).
  ck install package --tags=python-package,onnx --force_version=1.8.1 --quiet
  ck install package --tags=lib,python-package,pytorch --force_version=1.8.1 --quiet
  ck install package --tags=lib,python-package,transformers --force_version=2.4.0

  # Download the SQuAD v1.1 dataset.
  ck install package --tags=dataset,squad,raw,width.384 --quiet
  ck install package --tags=dataset,calibration,squad,pickle,width.384 --quiet
fi

# TODO
# if [[ "${_INSTALL_WORKLOAD_RETINANET}" == "yes" ]]; then
# fi

echo
echo "Done."

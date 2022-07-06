#!/bin/bash

_BENCHMARKS=${BENCHMARKS:-("resnet50")}
_DEVICE_DATASETS_DIR=${DEVICE_DATASETS_DIR:-"${HOME}"}

. run_common.sh

echo "Running '$0'"
print_variables "${!_@}"

if [[ -z $(contains_element "resnet50" "${_BENCHMARKS[@]}") ]]; then
    _DEVICE_DATASETS=${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val
    if [[ ! -f "${_DEVICE_DATASETS}" ]]; then
      echo "Passing: File '${_DEVICE_DATASETS}' already exist!"
    else
      echo "Extracting dataset to '${_DEVICE_DATASETS}'"
      ## Detect dataset
      tar -xvf ${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val.tar -C ${_DEVICE_DATASETS_DIR}
      ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
      --full_path=${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG

      ## Preprocess
      ck install package \
      --dep_add_tags.dataset-source=original,full \
      --tags=dataset,imagenet,val,full,preprocessed,using-opencv,for.resnet50.quantized,layout.nhwc,side.224,validation
      exit_if_error "Failed to preprocess resnet50 dataset!"
    fi
fi

# TODO
# if [[ contains_element "object_detection" "${_BENCHMARKS[@]}" ]]; then
# fi

# TODO
# if [[ contains_element "language_processing" "${_BENCHMARKS[@]}" ]]; then
# fi
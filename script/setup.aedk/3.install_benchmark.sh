#!/bin/bash

# HOST_DATA_DIR:-"/datasets/dataset-imagenet-ilsvrc2012-val.tar"
# DEVICE_DATASETS_DIR:-"/data/dataset-imagenet-ilsvrc2012-val.tar"
function contains_element () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

_BENCHMARKS=${BENCHMARKS:-("image_classification")}
_DEVICE_DATASETS_DIR=${DEVICE_DATASETS_DIR:-"/data"}

echo "'$0' Install benchmark dependencies parameters:"
echo "- BENCHMARKS=${_BENCHMARKS}"
echo "- DEVICE_DATASETS_DIR=${_DEVICE_DATASETS_DIR}"
echo


if [[ -z $(contains_element "image_classification" "${_BENCHMARKS[@]}") ]]; then
    ## Detect dataset
    sudo tar -xvf ${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val.tar -C ${_DEVICE_DATASETS_DIR}
    ck detect soft:dataset.imagenet.val --extra_tags=ilsvrc2012,full \
    --full_path=${_DEVICE_DATASETS_DIR}/dataset-imagenet-ilsvrc2012-val/ILSVRC2012_val_00000001.JPEG

    ## Preprocess
    ck install package \
    --dep_add_tags.dataset-source=original,full \
    --tags=dataset,imagenet,val,full,preprocessed,using-opencv,for.resnet50.quantized,layout.nhwc,side.224,validation
fi

# TODO
# if [[ contains_element "object_detection" "${_BENCHMARKS[@]}" ]]; then
# fi

# TODO
# if [[ contains_element "language_processing" "${_BENCHMARKS[@]}" ]]; then
# fi
#!/bin/bash

# For locating ImageNet.
_DEVICE_DATASETS_DIR=${DEVICE_DATASETS_DIR:-${HOME}}
_DEVICE_IMAGENET_DIR=${DEVICE_IMAGENET_DIR:-dataset-imagenet-ilsvrc2012-val}

# For locating SDK directory and specifying SDK version.
_SDK_DIR=${SDK_DIR:-${HOME}}
_SDK_VER=${SDK_VER:-1.8.0.137}
_CLEAN_PLATFORM_SDK=${CLEAN_PLATFORM_SDK:-no}

_CLEAN_WORKLOAD_BERT=${CLEAN_WORKLOAD_BERT:-no}
_CLEAN_WORKLOAD_RESNET50=${CLEAN_WORKLOAD_RESNET50:-no}
_CLEAN_WORKLOAD_RETINANET=${CLEAN_WORKLOAD_RETINANET:-no}
_CLEAN_WORKLOAD_SSD_RESNET34=${CLEAN_WORKLOAD_SSD_RESNET34:-no}
_CLEAN_WORKLOAD_SSD_MOBILENET=${CLEAN_WORKLOAD_SSD_MOBILENET:-no}

_CLEAN_MISC=${CLEAN_MISC:-no}
_CLEAN_ALL=${CLEAN_ALL:-no}
if [[ "${_CLEAN_ALL}" == "yes" ]]; then
  _CLEAN_MISC=yes
  _CLEAN_PLATFORM_SDK=yes
  _CLEAN_WORKLOAD_BERT=yes
  _CLEAN_WORKLOAD_RESNET50=yes
  _CLEAN_WORKLOAD_RETINANET=yes
  _CLEAN_WORKLOAD_SSD_RESNET34=yes
  _CLEAN_WORKLOAD_SSD_MOBILENET=yes
fi

# Summarize space used by directories initially.
echo "SPACE USED INITIALLY"

echo "- ImageNet:"
_IMAGENET_DIR=${_DEVICE_DATASETS_DIR}/${_DEVICE_IMAGENET_DIR}
du -hs ${_IMAGENET_DIR}

echo "- OpenImages:"
_OPENIMAGES_DIR=$(ck locate env --tags=dataset,openimages,original,validation)
du -hs ${_OPENIMAGES_DIR}

echo "- COCO:"
_COCO_DIR=$(ck locate env --tags=dataset,coco.2017,original)
du -hs ${_COCO_DIR}

echo "- Platform SDK:"
_PLATFORM_SDK_DIR=${_SDK_DIR}/qaic-platform-sdk-${_SDK_VER}
du -hs ${_PLATFORM_SDK_DIR}

_MLPERF_INFERENCE_DIR=$(ck locate env --tags=mlperf,inference,source)
echo "- MLPerf Inference:"
du -hs ${_MLPERF_INFERENCE_DIR}

_PROTOBUF_DIR=$(ck locate env --tags=lib,protobuf-host)
echo "- Protobuf:"
du -hs ${_PROTOBUF_DIR}

echo "- TOTAL:"
df -h ${HOME}

echo
echo "CLEANING UP ..."

# Clean up for ResNet50: original ImageNet.
if [[ "${_CLEAN_WORKLOAD_RESNET50}" == "yes" ]]; then
  echo "- ImageNet:"
  if [[ -d ${_IMAGENET_DIR} ]]; then
    rm -rf ${_IMAGENET_DIR} && mkdir ${_IMAGENET_DIR} && touch ${_IMAGENET_DIR}/ILSVRC2012_val_00000001.JPEG
  else
    echo "WARNING: ImageNet not found!"
  fi
  # TODO: Clean up the tarball.
fi

# Clean up for RetinaNet: original OpenImages.
if [[ "${_CLEAN_WORKLOAD_RETINANET}" == "yes" ]]; then
  echo "- OpenImages:"
  if [[ -d ${_OPENIMAGES_DIR} ]]; then
    rm -rf ${_OPENIMAGES_DIR}/validation
  else
    echo "WARNING: OpenImages not found!"
  fi
fi

# Clean up for SSD-MobileNet or SSD-ResNet34.
if [[ "${_CLEAN_WORKLOAD_SSD_MOBILENET}" == "yes" || "${_CLEAN_WORKLOAD_SSD_RESNET34}" == "yes" ]]; then
  echo "- COCO:"
  if [[ -d ${_COCO_DIR} ]]; then rm -rf \
    ${_COCO_DIR}/annotations/*train* \
    ${_COCO_DIR}/val2017/* && mkdir ${_COCO_DIR}/val2017/ && touch ${_COCO_DIR}/val2017/000000000139.jpg
  else
    echo "WARNING: COCO not found!"
  fi
fi

# Clean up Platform SDK.
if [[ "${_CLEAN_PLATFORM_SDK}" == "yes" ]]; then
  echo "- Platform SDK:"
  if [[ -d ${_PLATFORM_SDK_DIR} ]]; then
    rm -rf ${_PLATFORM_SDK_DIR}
  else
    echo "WARNING: Platform SDK not found!"
  fi
fi

# Clean up misc directories.
if [[ "${_CLEAN_MISC}" == "yes" ]]; then
  echo "- MLPerf Inference:"
  # Remove Git history for the MLPerf Inference repo (~500M).
  if [[ -d ${_MLPERF_INFERENCE_DIR} ]]; then
    rm -rf ${_MLPERF_INFERENCE_DIR}/inference/.git
  else
    echo "WARNING: MLPerf Inference source not found!"
  fi
  # Remove Protobuf src (~150M).
  echo "- Protobuf:"
  if [[ -d ${_PROTOBUF_DIR} ]]; then
    rm -rf ${_PROTOBUF_DIR}/src
  else
    echo "WARNING: Protobuf not found!"
  fi
fi

echo

# Summarize file space remaining after cleaning up.
echo "SPACE STILL IN USE:"

echo "- ImageNet:"
du -hs ${_IMAGENET_DIR}

echo "- OpenImages:"
du -hs ${_OPENIMAGES_DIR}

echo "- COCO:"
du -hs ${_COCO_DIR}

echo "- Platform SDK:"
du -hs ${_PLATFORM_SDK_DIR}

echo "- MLPerf Inference:"
du -hs ${_MLPERF_INFERENCE_DIR}

echo "- Protobuf:"
du -hs ${_PROTOBUF_DIR}

echo "- TOTAL:"
df -h ${HOME}

echo
echo "DONE (cleaning)."
echo

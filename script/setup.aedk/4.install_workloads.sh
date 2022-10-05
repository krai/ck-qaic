#!/bin/bash

# For locating ImageNet.
_DEVICE_DATASETS_DIR=${DEVICE_DATASETS_DIR:-${HOME}}
_DEVICE_IMAGENET_DIR=${DEVICE_IMAGENET_DIR:-dataset-imagenet-ilsvrc2012-val}

_INSTALL_WORKLOAD_BERT=${INSTALL_WORKLOAD_BERT:-no}
_INSTALL_WORKLOAD_RESNET50=${INSTALL_WORKLOAD_RESNET50:-no}
_INSTALL_WORKLOAD_RETINANET=${INSTALL_WORKLOAD_RETINANET:-no}
_INSTALL_WORKLOAD_SSD_RESNET34=${INSTALL_WORKLOAD_SSD_RESNET34:-no}
_INSTALL_WORKLOAD_SSD_MOBILENET=${INSTALL_WORKLOAD_SSD_MOBILENET:-no}

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
  ck install package --tags=dataset,imagenet,aux,from.berkeley
fi

if [[ "${_INSTALL_WORKLOAD_BERT}" == "yes" ]]; then

  # Install implicit dependencies via pip.
  source $HOME/.bashrc
  exit_if_empty ${CK_PYTHON} "Please set CK_PYTHON first!"
  #${CK_PYTHON} -m pip install --user tokenization

  # Install explicit dependencies via CK (also via pip, but register with CK at the same time).
  ck install package --tags=python-package,onnx --force_version=1.8.1 --quiet
  ck install package --tags=lib,python-package,pytorch --force_version=1.8.1 --quiet
  ck install package --tags=lib,python-package,transformers --force_version=2.4.0

  # Download and preprocess the SQuAD v1.1 dataset.
  ck install package --tags=dataset,squad,raw,width.384 --quiet
  ck install package --tags=dataset,calibration,squad,pickle,width.384 --quiet
fi

if [[ "${_INSTALL_WORKLOAD_RETINANET}" == "yes" ]] || [[ "${_INSTALL_WORKLOAD_SSD_RESNET34}" == "yes" ]] || [[ "${_INSTALL_WORKLOAD_SSD_MOBILENET}" == "yes" ]]; then
  if [[ ! -d $(ck locate env --tags=opencv-python-headless) ]]; then
    ck install package --tags=opencv-python-headless
  fi
  ck install package --tags=tool,coco,master
  ck install package --tags=lib,nms,abp,master
fi

if [[ "${_INSTALL_WORKLOAD_RETINANET}" == "yes" ]]; then
  python3 -m pip install fiftyone torch torchvision
  if [[ ! -d $(ck locate env --tags=dataset,openimages,original,validation) ]]; then
    ck install package --tags=dataset,openimages,original,validation
  fi
  if [[ ! -d $(ck locate env --tags=dataset,preprocessed,openimages,for.retinanet.onnx.preprocessed.quantized,validation,full) ]]; then
    ck install package --tags=dataset,preprocessed,openimages,for.retinanet.onnx.preprocessed.quantized,validation,full
  fi
fi

if [[ "${_INSTALL_WORKLOAD_SSD_RESNET34}" == "yes" ]] || [[ "${_INSTALL_WORKLOAD_SSD_MOBILENET}" == "yes" ]]; then
  if [[ ! -d $(ck locate env --tags=dataset,coco,original) ]]; then
    ck install package --tags=dataset,coco.2017,val --quiet
  fi
fi

if [[ "${_INSTALL_WORKLOAD_SSD_RESNET34}" == "yes" ]]; then
  if [[ ! -d $(ck locate env --tags=dataset,object-detection,for.ssd_resnet34.onnx.preprocessed.quantized,using-opencv,full,validation) ]]; then
    ck install package --dep_add_tags.lib-python-cv2=opencv-python-headless --quiet \
    --tags=dataset,object-detection,for.ssd_resnet34.onnx.preprocessed.quantized,using-opencv,full --extra_tags=validation
  fi
fi

if [[ "${_INSTALL_WORKLOAD_SSD_MOBILENET}" == "yes" ]]; then
  if [[ ! -d $(ck locate env --tags=dataset,object-detection,for.ssd_mobilenet.onnx.preprocessed.quantized,using-opencv,full,validation) ]]; then
    ck install package --dep_add_tags.lib-python-cv2=opencv-python-headless --quiet \
    --tags=dataset,object-detection,for.ssd_mobilenet.onnx.preprocessed.quantized,using-opencv,full,validation
  fi
fi

echo
echo "DONE (installing workloads)."
echo

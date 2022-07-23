#!/bin/bash

export DEVICE_IP=aedk3
export DEVICE_PORT=3233
export DEVICE_BASE_DIR="/data"
export DEVICE_GROUP="krai"
export DEVICE_USER="krai"
export DEVICE_OS=centos
export DEVICE_OS_OVERRIDE=no
export DEVICE_DATASETS_DIR=${DEVICE_BASE_DIR}/${DEVICE_USER}
export HOST_DATASETS_DIR="/datasets"
export PYTHON_VERSION=3.9.13
export INSTALL_BENCHMARK_RESNET50=yes
export INSTALL_BENCHMARK_BERT=yes

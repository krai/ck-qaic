#!/bin/bash

export DEVICE_IP=rb6
export DEVICE_PORT=3241
export HOST_DATASETS_DIR="/datasets"
export DEVICE_BASE_DIR="/data"
export DEVICE_GROUP="krai"
export DEVICE_USER="krai"
export DEVICE_DATASETS_DIR=${DEVICE_BASE_DIR}/${DEVICE_USER}
export DEVICE_OS=centos
export PYTHON_VERSION=3.9.13
export BENCHMARKS=("resnet50")
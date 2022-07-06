#!/bin/bash

export AEDK1=aedk1
export HOST_DATASETS_DIR="/datasets"
export BASE_DIR="/data"
export USER="krai"
export DEVICE_DATASETS_DIR=${BASE_DIR}\${USER}
export DEVICE_OS=centos
export PYTHON_VERSION=3.9.13
export BENCHMARKS=("resnet50")
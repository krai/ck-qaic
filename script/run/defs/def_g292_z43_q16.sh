#!/bin/bash

# BERT-99% (mixed precision).
BERT99_OFFLINE_OVERRIDE_BATCH_SIZE=4096
BERT99_SERVER_OVERRIDE_BATCH_SIZE=1024
BERT99_OFFLINE_TARGET_QPS=11400
BERT99_SERVER_TARGET_QPS=11320

# BERT-99.9% (FP16 precision).
BERT999_OFFLINE_OVERRIDE_BATCH_SIZE=4096
BERT999_SERVER_OVERRIDE_BATCH_SIZE=1024
BERT999_OFFLINE_TARGET_QPS=5300
BERT999_SERVER_TARGET_QPS=5300

# ResNet50.
RESNET50_OFFLINE_TARGET_QPS=350000
RESNET50_SERVER_TARGET_QPS=318097
RESNET50_MAX_WAIT=50

# SSD-ResNet34.
SSD_RESNET34_OFFLINE_TARGET_QPS=7000
SSD_RESNET34_SERVER_TARGET_QPS=7100

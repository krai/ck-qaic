#!/bin/bash

# BERT-99% (mixed precision).
BERT99_OFFLINE_OVERRIDE_BATCH_SIZE=4096
BERT99_SERVER_OVERRIDE_BATCH_SIZE=1024
BERT99_OFFLINE_TARGET_QPS=2925
BERT99_SERVER_TARGET_QPS=2555

# BERT-99.9% (FP16 precision).
BERT999_OFFLINE_OVERRIDE_BATCH_SIZE=4096
BERT999_SERVER_OVERRIDE_BATCH_SIZE=1024
BERT999_OFFLINE_TARGET_QPS=1425
BERT999_SERVER_TARGET_QPS=1280

# ResNet50.
RESNET50_OFFLINE_TARGET_QPS=92000
RESNET50_SERVER_TARGET_QPS=91200
RESNET50_MAX_WAIT=1800

# Use workload-specific frequency limits.
RUN_CMD_COMMON_SUFFIX_DEFAULT='--vc --sleep_before_ck_benchmark_sec=120'
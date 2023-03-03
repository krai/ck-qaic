#!/bin/bash

# Retinanet
RETINANET_SINGLESTREAM_TARGET_LATENCY=30
RETINANET_MULTISTREAM_TARGET_LATENCY=130
RETINANET_OFFLINE_TARGET_QPS=180

# Use workload-specific frequency limits.
RUN_CMD_COMMON_SUFFIX_DEFAULT='--vc'
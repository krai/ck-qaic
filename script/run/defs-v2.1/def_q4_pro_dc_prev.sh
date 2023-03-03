#!/bin/bash

# Retinanet
RETINANET_OFFLINE_TARGET_QPS=750
RETINANET_SERVER_TARGET_QPS=474

# Use workload-specific frequency limits.
RUN_CMD_COMMON_SUFFIX_DEFAULT='--vc --sleep_before_ck_benchmark_sec=120'

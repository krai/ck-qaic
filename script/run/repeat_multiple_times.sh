#!/bin/bash

_DEFS_DIR=${DEFS_DIR:-"./defs-v2.0"}

_DRY_RUN=${DRY_RUN:-no}
_QUICK_RUN=${QUICK_RUN:-no}
_SHORT_RUN=${SHORT_RUN:-no}
_UPDATE_CK_QAIC=${UPDATE_CK_QAIC:-yes}

_SUT=${SUT:-r282_z93_q2}
_WORKLOADS=("resnet50" "ssd_mobilenet" "ssd_resnet34" "bert")

_REPEAT=${REPEAT:-6}
_PRE_FAN=${PRE_FAN:-200}
_POST_FAN=${POST_FAN:-200}
_DEVICE_IDS=${DEVICE_IDS:-0,1}

_SLEEP=${SLEEP:-300}
if [[ "${_QUICK_RUN}" == "yes" ]]; then
  _SLEEP=10
fi

for _WORKLOAD in "${_WORKLOADS[@]}"; do # for each workload
  for (( i=1; i<=${_REPEAT}; i++ )); do # repeat several times
    UPDATE_CK_QAIC=${_UPDATE_CK_QAIC} DEFS_DIR=${_DEFS_DIR} DIVISION=open SDK_VER=1.6.80 \
    DRY_RUN=${_DRY_RUN} QUICK_RUN=${_QUICK_RUN} SHORT_RUN=${_SHORT_RUN} \
    SUT=${_SUT} WORKLOADS=${_WORKLOAD} OFFLINE_ONLY=yes \
    RUN_CMD_COMMON_SUFFIX="\
      --pre_fan=${_PRE_FAN} --post_fan=${_POST_FAN} \
      --device_ids=${_DEVICE_IDS} --vc --timestamp \
      --sleep_before_ck_benchmark_sec=${_SLEEP}" \
    DOCKER=yes ./run_edge.sh
    if [[ "${_DRY_RUN}" == "yes" ]]; then
      sleep 5s
    fi
  done
done

# Turn off the fans (level 5 => 3,150 RPM).
ipmitool raw 0x2e 0x10 0x0a 0x3c 0 64 1 5 0xFF

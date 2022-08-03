#!/bin/bash

_category="datacenter"
DOCKER=${DOCKER:-"yes"}
DOCKER_OS=${DOCKER_OS:-"ubuntu"}
WORKLOADS=${WORKLOADS:-"resnet50,bert"}

. run_common.sh

if [ ${SUT} == 'g292_z43_q16e' ] || [ ${SUT} == 'g292_z43_q16' ]  ; then
    DEVICE_IDS_OVERRIDE=' --device_ids=2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17'
fi

RUN_CMD_COMMON_SUFFIX="${RUN_CMD_COMMON_SUFFIX_DEFAULT} ${RUN_CMD_COMMON_SUFFIX} $DEVICE_IDS_OVERRIDE $POWER_YES $CMD_QUOTE"

# ResNet50.
OFFLINE_TARGET_QPS=$(getQPS "${RESNET50_OFFLINE_TARGET_QPS}")
SERVER_TARGET_QPS=$(getQPS "${RESNET50_SERVER_TARGET_QPS}")
MAX_WAIT=${RESNET50_MAX_WAIT:-1800}
if [[ $SERVER_TARGET_QPS == '1' ]]; then
  SERVER_TARGET_QPS=1000
  SET_SERVER_QUERY_COUNT="--server_query_count=1000"
elif [[ ${QPS_DIV} != 1 ]]; then
  SET_SERVER_QUERY_COUNT="--server_query_count=$(getServerQueryCount ${SERVER_TARGET_QPS})"
else
  SET_SERVER_QUERY_COUNT=""
fi
RUN_CMD_PREFIX="$RUN_CMD_PREFIX_RESNET50 $CMD_QUOTE"
RUN_CMD_SUFFIX="$RUN_CMD_COMMON_SUFFIX $RUN_CMD_SUFFIX_RESNET50"

CMD="\
${RUN_CMD_PREFIX} \
ck run cmdgen:benchmark.image-classification.qaic-loadgen --verbose \
--sut=$SUT --sdk=$SDK_VER --model=resnet50 \
${_RUN_TYPES} \
--offline_target_qps=$OFFLINE_TARGET_QPS \
--server_target_qps=$SERVER_TARGET_QPS \
--max_wait=$MAX_WAIT \
$SET_SERVER_QUERY_COUNT \
${RUN_CMD_SUFFIX}"

enabled resnet50 && RUN "$CMD"

# BERT-99% (mixed precision).
OFFLINE_OVERRIDE_BATCH_SIZE=${BERT99_OFFLINE_OVERRIDE_BATCH_SIZE:-4096}
SERVER_OVERRIDE_BATCH_SIZE=${BERT99_SERVER_OVERRIDE_BATCH_SIZE:-1024}
OFFLINE_TARGET_QPS=$(getQPS "${BERT99_OFFLINE_TARGET_QPS}")
SERVER_TARGET_QPS=$(getQPS "${BERT99_SERVER_TARGET_QPS}")
if [[ $SERVER_TARGET_QPS == '1' ]]; then
  SERVER_TARGET_QPS=1000
  SET_SERVER_QUERY_COUNT="--server_query_count=1000"
elif [[ ${QPS_DIV} != 1 ]]; then
  SET_SERVER_QUERY_COUNT="--server_query_count=$(getServerQueryCount ${SERVER_TARGET_QPS})"
else
  SET_SERVER_QUERY_COUNT=""
fi
RUN_CMD_PREFIX="$RUN_CMD_PREFIX_BERT $CMD_QUOTE"
RUN_CMD_SUFFIX="$RUN_CMD_COMMON_SUFFIX $RUN_CMD_SUFFIX_BERT"

CMD="\
${RUN_CMD_PREFIX} \
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=$SUT --sdk=$SDK_VER --model=bert-99 \
${_RUN_TYPES} \
--offline_override_batch_size=$OFFLINE_OVERRIDE_BATCH_SIZE \
--server_override_batch_size=$SERVER_OVERRIDE_BATCH_SIZE \
--offline_target_qps=$OFFLINE_TARGET_QPS \
--server_target_qps=$SERVER_TARGET_QPS \
$SET_SERVER_QUERY_COUNT \
${RUN_CMD_SUFFIX}"

enabled bert && RUN "$CMD"

# BERT-99.9% (FP16 precision).
OFFLINE_OVERRIDE_BATCH_SIZE=${BERT999_OFFLINE_OVERRIDE_BATCH_SIZE:-4096}
SERVER_OVERRIDE_BATCH_SIZE=${BERT999_SERVER_OVERRIDE_BATCH_SIZE:-1024}
OFFLINE_TARGET_QPS=$(getQPS "${BERT999_OFFLINE_TARGET_QPS}")
SERVER_TARGET_QPS=$(getQPS "${BERT999_SERVER_TARGET_QPS}")
if [[ $SERVER_TARGET_QPS == '1' ]]; then
  SERVER_TARGET_QPS=1000
  SET_SERVER_QUERY_COUNT="--server_query_count=1000"
elif [[ ${QPS_DIV} != 1 ]]; then
  SET_SERVER_QUERY_COUNT="--server_query_count=$(getServerQueryCount ${SERVER_TARGET_QPS})"
else
  SET_SERVER_QUERY_COUNT=""
fi
RUN_CMD_PREFIX="$RUN_CMD_PREFIX_BERT $CMD_QUOTE"
RUN_CMD_SUFFIX="$RUN_CMD_COMMON_SUFFIX $RUN_CMD_SUFFIX_BERT"

CMD="\
${RUN_CMD_PREFIX} \
ck run cmdgen:benchmark.packed-bert.qaic-loadgen --verbose \
--sut=$SUT --sdk=$SDK_VER --model=bert-99.9 \
${_RUN_TYPES} \
--offline_override_batch_size=$OFFLINE_OVERRIDE_BATCH_SIZE \
--server_override_batch_size=$SERVER_OVERRIDE_BATCH_SIZE \
--offline_target_qps=$OFFLINE_TARGET_QPS \
--server_target_qps=$SERVER_TARGET_QPS \
$SET_SERVER_QUERY_COUNT \
${RUN_CMD_SUFFIX}"

enabled bert && RUN "$CMD"


# SSD-ResNet34.
OFFLINE_TARGET_QPS=$(getQPS "${SSD_RESNET34_OFFLINE_TARGET_QPS}")
SERVER_TARGET_QPS=$(getQPS "${SSD_RESNET34_SERVER_TARGET_QPS}")
if [[ $SERVER_TARGET_QPS == '1' ]]; then
  SERVER_TARGET_QPS=1000
  SET_SERVER_QUERY_COUNT="--server_query_count=1000"
elif [[ ${QPS_DIV} != 1 ]]; then
  SET_SERVER_QUERY_COUNT="--server_query_count=$(getServerQueryCount ${SERVER_TARGET_QPS})"
else
  SET_SERVER_QUERY_COUNT=""
fi
RUN_CMD_PREFIX="$RUN_CMD_PREFIX_SSD_RESNET34 $CMD_QUOTE"
RUN_CMD_SUFFIX="$RUN_CMD_COMMON_SUFFIX $RUN_CMD_SUFFIX_SSD_RESNET34"

CMD="\
${RUN_CMD_PREFIX} \
ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --verbose \
--sut=$SUT --sdk=$SDK_VER --model=ssd_resnet34 \
${_RUN_TYPES} \
--offline_target_qps=$OFFLINE_TARGET_QPS \
--server_target_qps=$SERVER_TARGET_QPS \
$SET_SERVER_QUERY_COUNT \
${RUN_CMD_SUFFIX}"

enabled ssd_resnet34 && RUN "$CMD"

# Retinanet.
OFFLINE_TARGET_QPS=$(getQPS "${RETINANET_OFFLINE_TARGET_QPS}")
SERVER_TARGET_QPS=$(getQPS "${RETINANET_SERVER_TARGET_QPS}")
if [[ $SERVER_TARGET_QPS == '1' ]]; then
  SERVER_TARGET_QPS=1000
  SET_SERVER_QUERY_COUNT="--server_query_count=1000"
elif [[ ${QPS_DIV} != 1 ]]; then
  SET_SERVER_QUERY_COUNT="--server_query_count=$(getServerQueryCount ${SERVER_TARGET_QPS})"
else
  SET_SERVER_QUERY_COUNT=""
fi
RUN_CMD_PREFIX="$RUN_CMD_PREFIX_RETINANET $CMD_QUOTE"
RUN_CMD_SUFFIX="$RUN_CMD_COMMON_SUFFIX $RUN_CMD_SUFFIX_RETINENET"

CMD="\
${RUN_CMD_PREFIX} \
ck run cmdgen:benchmark.object-detection.qaic-loadgen --verbose \
--sut=$SUT --sdk=$SDK_VER --model=retinanet \
${_RUN_TYPES} \
--offline_target_qps=$OFFLINE_TARGET_QPS \
--server_target_qps=$SERVER_TARGET_QPS \

enabled retinanet && RUN "$CMD"

. run_end.sh

echo
echo "Done."

#!/bin/bash

if [[ $CK_EXPERIMENT_DIR == '' ]]; then
  echo 'CK_EXPERIMENT_DIR unset'
  exit -1
fi

if [[ $CK_EXPERIMENT_REPO == '' ]]; then
  echo 'CK_EXPERIMENT_REPO unset'
  exit -1
fi

requested_platform_base_sdk=${SDK_VER%.*}
base_platform_sdk=`cat /opt/qti-aic/versions/platform.xml |head -n 4 | tail -n 1|cut -d '>' -f2|cut -d '<' -f1`
if [[ $base_platform_sdk != $requested_platform_base_sdk ]]; then
  echo "Installed base Platform SDK ($base_platform_sdk) not matching with the requested ($requested_platform_base_sdk)";
  exit 1;
fi
requested_platform_sdk=${SDK_VER##*.}
platform_sdk=`cat /opt/qti-aic/versions/platform.xml |head -n 5 | tail -n 1|cut -d '>' -f2|cut -d '<' -f1`
if [[ $platform_sdk != $requested_platform_sdk ]]; then
  echo "Installed Platform SDK ($base_platform_sdk.$platform_sdk) not matching with the requested ($requested_platform_base_sdk.$requested_platform_sdk)";
  if [[ $DRY_RUN != 'yes' ]]; then 
    exit 1;
  fi
fi

CK_QAIC=$(ck find repo:ck-qaic)
if [[ $DRY_RUN != 'yes' ]] && [[ $UPDATE_CK_QAIC != 'no' ]]; then
  if [[ $CK_QAIC == '' ]]; then
    ck pull repo --url=https://github.com/krai/ck-qaic.git
    exit_if_error
  else
    ck pull repo:ck-qaic
  fi
fi

enabled bert && kill_existing_container "$CONTAINER_ID_BERT"
enabled resnet50 && kill_existing_container "$CONTAINER_ID_RESNET50"
enabled ssd_resnet34 && kill_existing_container "$CONTAINER_ID_SSD_RESNET34"
enabled ssd_mobilenet &&  kill_existing_container "$CONTAINER_ID_SSD_MOBILENET"
enabled retinanet && kill_existing_container "$CONTAINER_ID_RETINANET"

if enabled bert; then
  CONTAINER_ID_BERT=`ck run cmdgen:benchmark.packed-bert.qaic-loadgen --docker=container_only --out=none --sdk=$SDK_VER --model_name=bert --docker_os=$DOCKER_OS --experiment_dir`
  exit_if_invalid_container "$CONTAINER_ID_BERT"
  echo  "$CONTAINER_ID_BERT created"
fi

if enabled resnet50; then
  CONTAINER_ID_RESNET50=`ck run cmdgen:benchmark.image-classification.qaic-loadgen --docker=container_only --out=none --sdk=$SDK_VER --model_name=resnet50 --docker_os=$DOCKER_OS --experiment_dir`
  exit_if_invalid_container "$CONTAINER_ID_RESNET50"
  echo  "$CONTAINER_ID_RESNET50 created"
fi

if enabled ssd_resnet34; then
  CONTAINER_ID_SSD_RESNET34=`ck run cmdgen:benchmark.object-detection-large.qaic-loadgen --docker=container_only --out=none --sdk=$SDK_VER --model_name=ssd-resnet34 --docker_os=$DOCKER_OS --experiment_dir`
  exit_if_invalid_container "$CONTAINER_ID_SSD_RESNET34"
  echo  "$CONTAINER_ID_SSD_RESNET34 created"
fi

if enabled ssd_mobilenet; then
  CONTAINER_ID_SSD_MOBILENET=`ck run cmdgen:benchmark.object-detection-small.qaic-loadgen --docker=container_only --out=none --sdk=$SDK_VER --model_name=ssd-mobilenet --docker_os=$DOCKER_OS --experiment_dir`
  exit_if_invalid_container "$CONTAINER_ID_SSD_MOBILENET"
  echo  "$CONTAINER_ID_SSD_MOBILENET created"
fi

if enabled retinanet; then
  CONTAINER_ID_RETINANET=`ck run cmdgen:benchmark.object-detection.qaic-loadgen --docker=container_only --out=none --sdk=$SDK_VER --model_name=retinanet --docker_os=$DOCKER_OS --experiment_dir`
  exit_if_invalid_container "$CONTAINER_ID_RETINANET"
  echo  "$CONTAINER_ID_RETINANET created"
fi
if [[ "$UPDATE_CK_QAIC" == "yes" ]]; then
  enabled bert && RUN "docker exec $CONTAINER_ID_BERT bash -c \"ck pull repo:ck-qaic\""
  enabled resnet50 && RUN "docker exec $CONTAINER_ID_RESNET50 bash -c \"ck pull repo:ck-qaic\""
  enabled ssd_resnet34 && RUN "docker exec $CONTAINER_ID_SSD_RESNET34 bash -c \"ck pull repo:ck-qaic\""
  enabled ssd_mobilenet && RUN "docker exec $CONTAINER_ID_SSD_MOBILENET bash -c \"ck pull repo:ck-qaic\""
  enabled retinanet && RUN "docker exec $CONTAINER_ID_RETINANET bash -c \"ck pull repo:ck-qaic\""
fi


if [[ $POWER == 'yes' ]]; then
  CMD_QUOTE='"'
  RUN_CMD_PREFIX_BERT99="docker exec $CONTAINER_ID_BERT bash -c"
  RUN_CMD_PREFIX_BERT999="docker exec $CONTAINER_ID_BERT bash -c"
  RUN_CMD_PREFIX_RESNET50="docker exec $CONTAINER_ID_RESNET50 bash -c"
  RUN_CMD_PREFIX_SSD_RESNET34="docker exec $CONTAINER_ID_SSD_RESNET34 bash -c"
  RUN_CMD_PREFIX_SSD_MOBILENET="docker exec $CONTAINER_ID_SSD_MOBILENET bash -c"
  RUN_CMD_PREFIX_RETINANET="docker exec $CONTAINER_ID_RETINANET bash -c"
else
  RUN_CMD_SUFFIX_BERT99="$RUN_CMD_SUFFIX_BERT99 --container=$CONTAINER_ID_BERT"
  RUN_CMD_SUFFIX_BERT999="$RUN_CMD_SUFFIX_BERT999 --container=$CONTAINER_ID_BERT"
  RUN_CMD_SUFFIX_RESNET50="$RUN_CMD_SUFFIX_RESNET50 --container=$CONTAINER_ID_RESNET50"
  RUN_CMD_SUFFIX_SSD_RESNET34="$RUN_CMD_SUFFIX_SSD_RESNET34 --container=$CONTAINER_ID_SSD_RESNET34"
  RUN_CMD_SUFFIX_SSD_MOBILENET="$RUN_CMD_SUFFIX_SSD_MOBILENET --container=$CONTAINER_ID_SSD_MOBILENET"
  RUN_CMD_SUFFIX_RETINANET="$RUN_CMD_SUFFIX_RETINANET --container=$CONTAINER_ID_RETINANET"
fi

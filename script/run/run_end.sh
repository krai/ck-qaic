#!/bin/bash

if [[ ${_docker} == 'yes' ]]; then
  enabled bert && docker kill $CONTAINER_ID_BERT
  enabled resnet50 && docker kill $CONTAINER_ID_RESNET50
  enabled ssd_resnet34 && docker kill $CONTAINER_ID_SSD_RESNET34
  enabled ssd_mobilenet && docker kill $CONTAINER_ID_SSD_MOBILENET
fi

ZIP_EXPERIMENT=${ZIP_EXPERIMENT:-'no'}
if [[ $ZIP_EXPERIMENT == 'yes' ]]; then
  mkdir -p $HOME/krai_experiment_results/$SDK_VER
  cd $HOME/krai_experiment_results/$SDK_VER
  rm -f mlperf_v${MLPERF_VER}-closed-${SUT}-qaic-v${SDK_VER}.zip
  ck zip $CK_EXPERIMENT_REPO:experiment:*"closed-${SUT}-"*${SDK_VER}* --archive_name=mlperf_v${MLPERF_VER}-closed-${SUT}-qaic-v${SDK_VER}.zip
  if [[ $RCLONE_COPY == "yes" ]]; then
    rclone copy $CK_EXPERIMENT_REPO'_'${_reposuffix}$SDK_VER.zip rclone:experiments/$SDK_VER/
  fi
  cd -
fi

#!/bin/bash

if [ -z ${IPS} ]; then
  echo 'Please set IPS (device IP addresses) e.g. IPS="aedk1 aedk2"!';
  exit -1
fi

if [ -z ${PORTS} ]; then
  echo 'Please set PORTS (device ports) e.g. PORTS="3231 3232"!';
  exit -1
fi

if [ -z ${EXTRA_MODEL} ]; then
  echo 'Please set EXTRA_MODEL (tags) specific to SUT e.g. EXTRA_MODEL="aedk_20w"!';
  exit -1
fi

models=(resnet50 ssd_mobilenet ssd_resnet34 bert-99)
for model in ${models[@]} 
do
  echo "Installing $model ..."
  if [[ $model == "bert-99" ]];
  then
    EXTRA_SUFFIX=",quantization.calibration"
  else
    EXTRA_SUFFIX=""
  fi
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${EXTRA_MODEL}.offline${EXTRA_SUFFIX} --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=krai --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${EXTRA_MODEL}.singlestream${EXTRA_SUFFIX} --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=krai --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${EXTRA_MODEL}.multistream${EXTRA_SUFFIX} --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=krai --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
done

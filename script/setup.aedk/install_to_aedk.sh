#!/bin/bash

if [ -z ${IPS} ]; then
  echo 'Please set IPS (device IP addresses) e.g. IPS="aedk1 aedk2"!';
  exit -1
fi

if [ -z ${PORTS} ]; then
  echo 'Please set PORTS (device ports) e.g. PORTS="3231 3232"!';
  exit -1
fi

if [ -z ${SUT} ]; then
  echo 'Please set SUT e.g. SUT="aedk_20w"!';
  exit -1
fi

$_USER=${USER:-krai}

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
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${SUT}.offline${EXTRA_SUFFIX} --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=${_USER} --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${SUT}.singlestream${EXTRA_SUFFIX} --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=${_USER} --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${SUT}.multistream${EXTRA_SUFFIX} --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=${_USER} --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
done

#!/bin/bash

if [ -z ${IPS} ]; then
  echo 'Please set IPS like IPS="host1 host2"';
fi

if [ -z ${PORTS} ]; then
  echo 'Please set PORTS like PORTS="3231 3232';
fi

if [ -z ${MODEL_EXTRA} ]; then
 echo 'Please set MODEL_EXTRA specific to SUT like MODEL_EXTRA="aedk_20w"';
fi

models=(resnet50 ssd_mobilenet ssd_resnet34 bert-99)
for model in ${models[@]} 
do
  echo "Installing $model"
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${MODEL_EXTRA}.offline --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=krai --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
  CMD="ck install package --tags=install-to-aedk --dep_add_tags.model-qaic=$model,$model.${MODEL_EXTRA}.singlestream --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USER=krai --env.CK_DEST_PATH=/home/krai/CK-TOOLS"
  echo $CMD
  eval $CMD
done


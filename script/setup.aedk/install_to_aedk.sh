#!/bin/bash

# Usage: PASSWORD=111111 IPS=aedk1 PORTS=3231 SUT=aedk_15w bash install_to_aedk.sh


_DOCKER=${DOCKER:-yes}
_DOCKER_OS=${DOCKER_OS:-ubuntu}
_SDK_VER=${SDK_VER:-1.7.1.7}
#_WORKLOADS="resnet50 bert-99" # ssd_mobilenet ssd_resnet34

# FIXME: Only works for a single workload at at time.
_WORKLOADS="resnet50" # ssd_mobilenet ssd_resnet34

_BASE_DIR=${BASE_DIR:-/data}
_USERNAME=${USERNAME:-krai}

if [ -z ${SUT} ]; then
  echo 'Please set SUT e.g. SUT="aedk_15w"!';
  exit -1
fi

if [ -z ${PASSWORD} ]; then
  echo 'Please set PASSWORD (device password) e.g. PASSWORD="111111"!';
  exit -1
fi

# Use lists if setting up several identical devices.
if [ -z ${IPS} ]; then
  echo 'Please set IPS (device IP addresses) e.g. IPS="aedk1 aedk2"!';
  exit -1
fi
if [ -z ${PORTS} ]; then
  echo 'Please set PORTS (device ports) e.g. PORTS="3231 3232"!';
  exit -1
fi

function install () {
  workloads="$@"
  for workload in ${workloads[@]}; do
    echo "- Workload: '$workload'"
    if [[ "$workload" == "bert-99" ]]; then
      scenarios=(offline singlestream)
      EXTRA_SUFFIX=",quantization.calibration"
    else
      scenarios=(offline singlestream multistream)
      EXTRA_SUFFIX=""
    fi
    for scenario in ${scenarios[@]}; do
      echo "  - Scenario: '$scenario'"
      CMD="\
ck install package --tags=install-to-aedk \
-dep_add_tags.model-qaic=$workload,$workload.${SUT}.${scenario}${EXTRA_SUFFIX} \
--env.CK_AEDK_USERNAME=${_USERNAME} --env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' \
--env.CK_DEST_PATH=${_BASE_DIR}/${_USERNAME}/CK-TOOLS"
      echo "    CMD: $CMD"
      #eval $CMD
    done
    echo
  done
}

if [[ ${_DOCKER} == "yes" ]]; then
  workload="resnet50"
  if [[ "$workload" == "resnet50" ]]; then
    image="krai/mlperf.${workload}.full:${_DOCKER_OS}_${_SDK_VER}"
  else
    image="krai/mlperf.${workload}:${_DOCKER_OS}_${_SDK_VER}"
  fi
  echo "Installing workloads from Docker image '$image' ..."
  container=$(docker run -dt --rm $image bash)
  docker exec $container ssh-keygen -q -N '' > /dev/zero
  docker exec $container sshpass -p ${PASSWORD} ssh-copy-id ${USERNAME}@${IPS} -p ${PORTS} -o StrictHostKeyChecking=no
  install ${_WORKLOADS}
  docker container stop $container
else
  echo "Installing workloads ..."
  install ${_WORKLOADS}
fi

echo "Done (installing workloads)."

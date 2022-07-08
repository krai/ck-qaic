#!/bin/bash

# Usage: PASSWORD=111111 IPS=aedk1 PORTS=3231 SUT=aedk_15w bash install_to_aedk.sh


_DOCKER=${DOCKER:-yes}
_DOCKER_OS=${DOCKER_OS:-ubuntu}
_SDK_VER=${SDK_VER:-1.7.1.12}
#_WORKLOADS="resnet50 bert-99" # ssd_mobilenet ssd_resnet34

# FIXME: Only works for a single workload at at time.
_WORKLOADS="resnet50" # ssd_mobilenet ssd_resnet34

_BASE_DIR=${BASE_DIR:-/data}
_USERNAME=${USERNAME:-krai}

if [ -z ${PASSWORD} ]; then
  echo 'Please set PASSWORD (device password) e.g. PASSWORD="111111"!';
  exit -1
fi

if [ -z ${IPS} ]; then
  echo 'Please set IPS (device IP addresses) e.g. IPS="aedk1 aedk2"!';
  exit -1
fi

if [ -z ${PORTS} ]; then
  echo 'Please set PORTS (device ports) e.g. PORTS="3231 3232"!';
  exit -1
fi

if [ -z ${SUT} ]; then
  echo 'Please set SUT e.g. SUT="aedk_15w"!';
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
--env.CK_AEDK_IPS='${IPS}' --env.CK_AEDK_PORTS='${PORTS}' --env.CK_AEDK_USERNAME=${_USERNAME} \
--env.CK_DEST_PATH=${_BASE_DIR}/${_USERNAME}/CK-TOOLS"
      echo "    CMD: $CMD"
      #eval $CMD
    done
    echo
  done
}

if [[ ${_DOCKER} == "yes" ]]; then
  echo "Installing workloads from Docker ..."
  install ${_WORKLOADS}
else
  echo "Installing workloads ..."
  install ${_WORKLOADS}
fi

echo "Done (installing workloads)."

#!/bin/bash

IFS=',' read -r -a _WORKLOADS <<< "$WORKLOADS"

function exit_if_error() {
  if [ "${?}" != "0" ]; then exit 1; fi
}
function exit_if_invalid_container() {
  if [[ "$1" = *"error"* ]]; then
    echo "Container creation failed $1";
    exit 1;
  fi
}
function kill_existing_container() {
  if [[ "$1" != '' ]]; then
    echo "Killing existing container $1"
    docker kill "$1"
  fi
}

function RUN() {
  echo "Running:"
  echo "$1"
  echo ""
  if [[ $DRY_RUN != 'yes' ]]; then
    eval $1
  fi
}

function enabled()  {
  param=$1;
  shift;
  for elm in "${_WORKLOADS[@]}";
  do
    [[ "$param" == "$elm" ]] && return 0;
  done;
  return 1
}

function getQPS() {
if [[ $1 == "" ]]; then echo "1";
else
  echo $(echo "$1/${QPS_DIV}" | bc )
fi
}

function getLatency() {
if [[ $1 == "" ]]; then echo "1000";
else
  echo $(echo "$1*${LATENCY_MUL}" | bc )
fi
}

function getQueryCount() {
if [[ $1 == "" ]]; then echo "1000";
else
  echo $(echo  "660000/$1" | bc )
fi
}

function getServerQueryCount() {
if [[ $1 == "" ]]; then echo "1000";
else
  echo $(echo  "600*$1" | bc )
fi
}

if [[ ${SDK_VER} == '' ]]; then
  echo 'ERROR: SDK_VER must be set!'
  exit -1
fi

if [[ ${SUT} == '' ]]; then
  echo 'ERROR: SUT must be set!'
  exit -1
fi

_defs_dir=${DEFS_DIR:-'./defs'}

_reposuffix=${REPOSUFFIX:-''}

_division=${DIVISION:-open}

_docker=${DOCKER:-no}

_offline_only=${OFFLINE_ONLY:-no}
_server_only=${SERVER_ONLY:-no}
_singlestream_only=${SINGLESTREAM_ONLY:-no}
_multistream_only=${MULTISTREAM_ONLY:-no}

_power=${POWER:-no}

UPDATE_CK_QAIC=${UPDATE_CK_QAIC:-yes}

CK_EXPERIMENT_REPO=${CK_EXPERIMENT_REPO:-local}

if [[ ${CK_EXPERIMENT_REPO} == "local" ]]; then
  _reposuffix=${_reposuffix:-$SUT}
fi

if [[ ${_reposuffix} != '' ]]; then
  _reposuffix=${_reposuffix}"_";
fi

if [[ ${SHORT_RUN} == 'yes' ]]; then
  QPS_DIV=${QPS_DIV:-5}
  LATENCY_MUL=${LATENCY_MUL:-5}
else
  QPS_DIV=${QPS_DIV:-1}
  LATENCY_MUL=${LATENCY_MUL:-1}
fi

if [[ ${_power} == 'yes' ]]; then
  POWER_YES='--power=yes'
fi

if [[ ${_offline_only} == 'yes' ]]; then
  _RUN_TYPES="--group.${_division} --scenario=offline"
elif [[ ${_server_only} == 'yes' ]]; then
  _RUN_TYPES="--group.${_division} --scenario=server"
elif [[ ${_singlestream_only} == 'yes' ]]; then
  _RUN_TYPES="--group.${_division} --scenario=singlestream"
elif [[ ${_multistream_only} == 'yes' ]]; then
  _RUN_TYPES="--group.${_division} --scenario=multistream"
else
  _RUN_TYPES="--group.${_category} --group.${_division}"
fi

if [[ "${UPDATE_CK_QAIC}" == "yes" ]]; then
  echo "Updating repo:ck-qaic ..."
  ck pull repo:ck-qaic
fi

echo
if [[ "${QUICK_RUN}" == "yes" ]]; then
  echo "Running a quick test with default parameters ..."
elif [[ "${SHORT_RUN}" == "yes" ]]; then
  echo "Running a short test with '$SUT' parameters ..."
  . ${_defs_dir}/def_${SUT}.sh
else
  echo "Running a full test with '$SUT' parameters ..."
  . ${_defs_dir}/def_${SUT}.sh
fi
echo

CMD_QUOTE=''
RUN_CMD_PREFIX_BERT=''
RUN_CMD_PREFIX_RESNET50=''
RUN_CMD_PREFIX_SSD_RESNET34=''
RUN_CMD_PREFIX_SSD_MOBILENET=''
RUN_CMD_PREFIX_RETINANET=''
RUN_CMD_SUFFIX_BERT=''
RUN_CMD_SUFFIX_RESNET50=''
RUN_CMD_SUFFIX_SSD_MOBILENET=''

if [[ ${_docker} == 'yes' ]]; then
  . run_common_docker.sh
fi

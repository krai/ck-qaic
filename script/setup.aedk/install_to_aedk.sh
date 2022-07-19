#!/bin/bash

# Usage: DEVICE_IP=192.168.0.11 DEVICE_PORT=3311 DEVICE_TYPE=aedk_15w DEVICE_PASSWORD=01234567 ./install_to_aedk.sh

_DRY_RUN=${DRY_RUN:-"no"}
_DRY_COMPILE=${DRY_COMPILE:-"no"}
_DRY_INSTALL=${DRY_INSTALL:-"no"}
_UPDATE_CK_QAIC=${UPDATE_CK_QAIC:-"yes"}

# No sensible defaults.
if [ -z ${DEVICE_IP} ]; then
  echo 'Please set device IP address e.g. DEVICE_IP="192.168.1.11"!'
  exit 1
fi
if [ -z ${DEVICE_TYPE} ]; then
  echo 'Please set device type e.g. DEVICE_TYPE="aedk_15w"!'
  exit 1
fi
if [ -z ${DEVICE_PASSWORD} ]; then
  echo 'Please set device password e.g. DEVICE_PASSWORD="01234567"!'
  exit 1
fi
# Sensible defaults.
_DEVICE_USER=${DEVICE_USER:-krai}
_DEVICE_BASE_DIR=${DEVICE_BASE_DIR:-/data}
_DEVICE_PORT=${DEVICE_PORT:-22}

_SDK_VER=${SDK_VER:-1.7.1.12}
_DOCKER=${DOCKER:-yes}
_DOCKER_OS=${DOCKER_OS:-ubuntu}
# If dry compile, use sample binaries in the container:
# 'pcie.16nsp' for Pro cards; 'pcie.14nsp' for Standard cards.
_DOCKER_DEVICE_TYPE=${DOCKER_DEVICE_TYPE:-"pcie.16nsp"}

# Convert comma-separated workload list into array.
_WORKLOADS=${WORKLOADS:-"resnet50,bert"} # "resnet50,bert,retinanet,ssd_mobilenet,ssd_resnet34"
IFS=',' read -ra _WORKLOADS_AS_ARRAY <<< "${_WORKLOADS}"
echo "Installing workloads: '${_WORKLOADS}'"
echo

for workload in ${_WORKLOADS_AS_ARRAY[@]}; do
  echo "- Workload: '${workload}'"
  #-----------------------------------------------------------------------------
  # Start Docker container.
  #-----------------------------------------------------------------------------
  if [[ ${_DOCKER} == "yes" ]]; then
    if [[ "${workload}" == "resnet50" ]]; then
      image="krai/mlperf.${workload}.full:${_DOCKER_OS}_${_SDK_VER}"
    else
      image="krai/mlperf.${workload}:${_DOCKER_OS}_${_SDK_VER}"
    fi
    echo "Installing '${workload}' from the '${image}' Docker image ..."
    if [[ "${_DRY_RUN}" != "yes" ]]; then
      container=$(docker run -dt --rm ${image} bash)
      echo "Starting '${workload}' container: '${container}' ..."
      docker exec ${container} /bin/sshpass -p ${DEVICE_PASSWORD} ssh-copy-id ${_DEVICE_USER}@${DEVICE_IP} -p ${_DEVICE_PORT} -o StrictHostKeyChecking=no
      docker_cmd_prefix="docker exec ${container}"
    fi
  else
    echo "Installing '${workload}' from the host system ..."
    docker_cmd_prefix=""
  fi
  ssh_cmd_prefix="ssh -n -f -p ${DEVICE_PORT} ${_DEVICE_USER}@${DEVICE_IP}"

  #-----------------------------------------------------------------------------
  # Update CK-QAIC and other CK repositories.
  #-----------------------------------------------------------------------------
  if [[ "${_UPDATE_CK_QAIC}" == "yes" ]]; then
    ${docker_cmd_prefix} ck pull repo:ck-qaic
    echo
  fi

  #-----------------------------------------------------------------------------
  # Compile and install workload binaries for all valid scenarios.
  #-----------------------------------------------------------------------------
  if [[ "${workload}" == "bert" || "${workload}" == "bert-99" ]]; then
    workload="bert-99"
    scenarios=(offline singlestream) # no multistream
    extra_suffix=",quantization.calibration"
  else
    scenarios=(offline singlestream multistream)
    extra_suffix=""
  fi
  for scenario in ${scenarios[@]}; do
    echo "  - Scenario: '${scenario}'"
    model_tags="model,qaic,${workload},${workload}.${DEVICE_TYPE}.${scenario}${extra_suffix}"
    # Compile workload.
    compile_cmd="${docker_cmd_prefix} ck install package --tags=${model_tags}"
    echo "    - Compile command:"
    echo "      ${compile_cmd}"
    if [[ "${_DRY_COMPILE}" != "yes" ]]; then
      eval ${compile_cmd}
    else
      model_tags="model,qaic,${workload},${workload}.${_DOCKER_DEVICE_TYPE}.${scenario}${extra_suffix}"
      echo "      - dry compile => using sample model tags: '${model_tags}'"
    fi
    echo
    # Clean any preinstalled workload binaries.
    clean_cmd="${docker_cmd_prefix} ${ssh_cmd_prefix} \
\"/bin/bash -c 'PATH=${_DEVICE_BASE_DIR}/${_DEVICE_USER}/.local/bin:\$PATH; \
ck clean env --tags=\"${model_tags}\" -f'\" "
    echo "    - Clean command:"
    echo "      ${clean_cmd}"
    if [[ "${_DRY_INSTALL}" != "yes" ]]; then eval ${clean_cmd}; fi
    echo
    # Get the (local) source directory.
    python_cmd="\
import ck.kernel as ck
r=ck.access({'action':'show', 'module_uoa':'env', 'tags':'${model_tags}'})
print(r['lst'][0]['meta']['env']['CK_ENV_QAIC_MODEL_ROOT'])"
    src_dir=$(eval "${docker_cmd_prefix} python3 -c \"${python_cmd}\"")
    # Create the (remote) destination directory.
    tools_subdir=$(echo ${src_dir} | awk -F'/' ' { print $(NF-1) } ')
    dst_dir="${_DEVICE_BASE_DIR}/${_DEVICE_USER}/CK-TOOLS/${tools_subdir}"
    mkdir_cmd="${docker_cmd_prefix} ${ssh_cmd_prefix} \
mkdir -p ${dst_dir}"
    echo "    - Create dir command:"
    echo "      ${mkdir_cmd}"
    if [[ "${_DRY_INSTALL}" != "yes" ]]; then eval ${mkdir_cmd}; fi
    echo
    # Copy the workload binaries.
    rsync_cmd="${docker_cmd_prefix} \
rsync -avz -e \"ssh -p ${DEVICE_PORT}\" ${src_dir}/ ${_DEVICE_USER}@${DEVICE_IP}:${dst_dir}/"
    echo "    - Copy command:"
    echo "      ${rsync_cmd}"
    if [[ "${_DRY_INSTALL}" != "yes" ]]; then eval ${rsync_cmd}; fi
    echo
    # Get all environment variables.
    python_cmd="\
import ck.kernel as ck
r=ck.access({'action':'show', 'module_uoa':'env', 'tags':'${model_tags}'})
deps=r['lst'][0]['meta']['deps']
dict=deps['model-source']['dict']['env']
for key,val in dict.items():
  key=key.replace('CK_ENV_', '_'); print('--ienv.',key,'=\\\'',val,'\\\'',sep='',end=' ')
if(dict['ML_MODEL_MODEL_NAME'] == 'ssd-resnet34'):
  dict=deps['profile-resnet34']['dict']['env']
  for key,val in dict.items():
    key=key.replace('CK_ENV_', '_'); print('--ienv.',key,'=\\\'',val,'\\\'',sep='',end=' ')"
    env=$(eval "${docker_cmd_prefix} python3 -c \"${python_cmd}\"")
    # Get all model tags, not just the subset used for searching.
    python_cmd="\
import ck.kernel as ck
r=ck.access({'action':'show', 'module_uoa':'env', 'tags':'${model_tags}'})
print(r['view'][0]['tags'])"
    all_tags=$(eval "${docker_cmd_prefix} python3 -c \"${python_cmd}\"")
    # Detect the workload binaries.
    detect_cmd="${docker_cmd_prefix} ${ssh_cmd_prefix} \
\"/bin/bash -c \\\"PATH=${_DEVICE_BASE_DIR}/${_DEVICE_USER}/.local/bin:\$PATH;\
echo ${_SDK_VER} | ck detect soft:model.qaic --full_path='${dst_dir}/programqpc.bin' --extra_tags='${all_tags}' ${env}\\\" \
\""
    echo "    - Detect command:"
    echo "      ${detect_cmd}"
    if [[ "${_DRY_INSTALL}" != "yes" ]]; then eval ${detect_cmd}; fi
    echo
  done
  #-----------------------------------------------------------------------------
  # Stop Docker container.
  #-----------------------------------------------------------------------------
  if [[ ${_DOCKER} == "yes" ]]; then
    echo "Stopping '${workload}' container: '${container}' ..."
    if [[ "${_DRY_RUN}" != "yes" ]]; then
      docker container stop ${container}
    fi
  fi
  echo
done

echo "DONE (installing workloads)."

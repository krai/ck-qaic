#!/bin/bash

#
# Copyright (c) 2021 Krai Ltd.
#
# SPDX-License-Identifier: BSD-3-Clause.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#

hub_ip=localhost
ips=( ${CK_AEDK_IPS:-} ) # use parentheses to interpret the string as an array
ids=( ${CK_AEDK_IDS:-} ) # use parentheses to interpret the string as an array
if [[ -z "${ips}" ]] && [[ -z ${ids} ]]
then
  # If neither is defined, send to itself.
  ips=( "${hub_ip}" )
fi
if [[ "${ips}" ]] # (1)
then
  num_ips=${#ips[@]}
  ids=( $(seq 1 ${num_ips}) )
  num_ids=${#ids[@]}
else # (2)
  ids=( ${CK_AEDK_IDS:-1} )
  num_ids=${#ids[@]}
  ips=( )
  for id in ${ids[@]}; do
    id_plus_1=$((id+1))
    ips+=( "192.168.1.10${id_plus_1}" )
  done
  num_ips=${#ips[@]}
fi
echo "- ${num_ips} worker IP(s): ${ips[@]}"
echo "- ${num_ids} worker ID(s): ${ids[@]}"
if [[ ${num_ips} != ${num_ids} ]]; then
  echo "ERROR: ${num_ips} not equal to ${num_ids}!"
  exit 1
fi

# Worker ssh ports (22 by default).
ports=( ${CK_AEDK_PORTS:-} ) # use parentheses to interpret the string as an array
if [[ -z "${ports}" ]]; then
  for id in ${ips[@]}; do
    ports+=( "22" )
  done
fi
num_ports=${#ports[@]}
echo "- ${num_ports} worker port(s): ${ports[@]}"
if [[ ${num_ports} != ${num_ips} ]]; then
  echo "ERROR: ${num_ports} not equal to ${num_ips}!"
  exit 1
fi

# User (the same by default).
user=${CK_AEDK_USER:-$USER}

echo

echo ${CK_ENV_QAIC_MODEL_ROOT}
model_install_file=${CK_ENV_QAIC_MODEL_ROOT}/../ck-install.json
basetag=`cat ${model_install_file} | python3 -c "import sys, json; print(json.load(sys.stdin)['tags'])"`
my_tags=`ck cat env --tags=${basetag} | grep Tags | tail -n 1 | cut -d':' -f2 | sed 's/^\s*//g'`
echo "Tags: ${my_tags}"

env=`cat ${model_install_file} | python3 -c "import sys, json;
deps=json.load(sys.stdin)['deps']
dict=deps['model-source']['dict']['env'];
for key,val in dict.items():
  key=key.replace('CK_ENV_', '_')
  print('--ienv.',key,'=\"', val,'\"', sep='', end= ' ')
if(dict['ML_MODEL_MODEL_NAME'] == 'ssd-resnet34'):
  dict=deps['profile-resnet34']['dict']['env'];
  for key,val in dict.items():
    key=key.replace('CK_ENV_', '_')
    print('--ienv.',key,'=\"', val,'\"', sep='', end= ' ')"`
source_path=`ck cat env --tags=${my_tags} | grep "MODEL_ROOT" | head -n 1 | cut -d"=" -f2`
echo ${source_path}


if [ -z ${source_path} ]; then
  echo "Invalid path";
  exit 1;
fi

if [ -z ${CK_DEST_PATH} ]; then
  dest_path=${source_path}
else
  install_dir=`echo ${source_path} | awk -F'/' ' { print $(NF-1) } '` 
  dest_path=${CK_DEST_PATH}/${install_dir}
fi
echo "Installing to ${dest_path}"

ck_detect="ck detect soft:model.qaic --full_path=\"${dest_path}/programqpc.bin\" --extra_tags=\"${my_tags}\" ${env}"
echo ${ck_detect}

for i in $(seq 1 ${#ips[@]}); do
  ip=${ips[${i}-1]}
  id=${ids[${i}-1]}
  port=${ports[${i}-1]}
  worker_id="worker-${id}"
  ssh -n -f ${user}@${ip} -p ${port} mkdir -p ${dest_path}
  rsync -avz -e "ssh -p ${port}" ${source_path}/ ${user}@${ip}:${dest_path}/
  ssh -n -f ${user}@${ip} -p ${port} \
  "bash -c ' PATH=\$PATH:\$HOME/.local/bin; \
  exists=\`ck search env --tags=\"${my_tags}\"\`;
  if [ ! -z \${exists} ]; then
    echo \"Already registered \${exists}\";
  else
    echo \"default\" | ${ck_detect}
  fi
  '"
  # Wait a bit.
  sleep 1s
done

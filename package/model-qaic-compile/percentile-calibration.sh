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
function exit_if_error() {
    if [ "${?}" != "0" ]; then exit 1; fi
}
function get_cmdgen_program_name() {
  bmodel=$1
  if [[ "$bmodel" == "bert-99" ]]; then echo "benchmark.packed-bert.qaic-loadgen"; 
    elif [[ "$bmodel" == "ssd_resnet34" ]]; then echo "benchmark.object-detection.qaic-loadgen"; 
    elif [[ "$bmodel" == "ssd_mobilenet" ]]; then echo "benchmark.object-detection.qaic-loadgen"; 
    elif [[ "$bmodel" == "resnet50" ]]; then echo "benchmark.image-classification.qaic-loadgen"; 
  fi
}
function get_accuracy_metric() {
  bmodel=$1
  if [[ "$bmodel" == "bert-99" ]]; then echo "f1"; 
    elif [[ "$bmodel" == "ssd_resnet34" ]]; then echo "mAP"; 
    elif [[ "$bmodel" == "ssd_mobilenet" ]]; then echo "mAP"; 
    elif [[ "$bmodel" == "resnet50" ]]; then echo "Accuracy"; 
  fi
}
if [[ $PC_START == "" ]]; then
  PC_START=70;
fi
if [[ $PC_END == "" ]]; then
  PC_END=97;
fi
if [[ $PC_INC == "" ]]; then
  PC_INC=1;
fi

if [[ $# < 2 ]]; then echo "Model base name (one among [bert-99, ssd_resnet34, ssd_mobilenet, resnet50]) and Model unique name for compilation (for e.g., bert-99.pcie.16nsp.offline) required!"; exit 1; fi
max=0
maxi=0
bmodel=$1
model=$2
scenario=$3

if [[ $scenario == "" ]]; then
  scenario="offline"
fi

if [ "$#" == 4 ]; then sdk=$4; else sdk=1.6.80; fi

cprogram=$(get_cmdgen_program_name $bmodel)

if [[ $cprogram == "" ]]; then
  echo "Program for $bmodel not found";
  exit -1;
fi

accuracy_metric=$(get_accuracy_metric $bmodel)
for (( i=${PC_START}; i<=${PC_END}; i+=${PC_INC} )) 
do
  pcv="99"$i
  install_cmd="ck install package --tags=compiled,$bmodel,$model,quantization.calibration --env._PERCENTILE_CALIBRATION_VALUE=99.$pcv --extra_tags=pcv.$pcv --quiet >/dev/null 2>&1"
  echo $install_cmd
  eval $install_cmd
  exit_if_error
  ck_run_cmd="ck run cmdgen:$cprogram --verbose --sut=r282_z93_q1 --sdk=$sdk --model=$bmodel --mode=accuracy --scenario=$scenario  --replace_existing --calibration_value=$pcv"
  echo $ck_run_cmd
  eval $ck_run_cmd
  exit_if_error
  ck_clean_package_cmd="ck clean env --tags=compiled,$model,quantization.calibration,pcv.$pcv --force >/dev/null 2>&1"
  echo $ck_clean_package_cmd
  eval $ck_clean_package_cmd
  accuracy=`grep -w $accuracy_metric $(ck find experiment:*$bmodel*$scenario*accuracy*$pcv*)/*0001.json | cut -d ':' -f2 | cut -d ' ' -f2 | cut -d ',' -f1`
  ck rm experiment:*$bmodel*$scenario*accuracy*$pcv* --force >/dev/null 2>&1
  #echo $pcv":"$f1
  #echo $pcv":"$f1 >>out
  if [[ $accuracy > $max ]]; then
    max=$accuracy
    maxi=99$i
  fi
done
echo $max
echo $maxi
install_cmd="ck install package --tags=compiled,$bmodel,$model,quantization.calibration --env._PERCENTILE_CALIBRATION_VALUE=99.$maxi --extra_tags=pcv.$maxi >/dev/null 2>&1"
echo $install_cmd
eval $install_cmd
#echo $max:$maxi>outm
exit_if_error

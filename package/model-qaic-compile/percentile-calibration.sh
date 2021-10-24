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
  if [[ "$bmodel" == "bert" ]]; then echo "benchmark.packed-bert.qaic-loadgen"; 
    elif [[ "$bmodel" == "ssd_resnet34" ]]; then echo "benchmark.object-detection.qaic-loadgen"; 
    elif [[ "$bmodel" == "ssd_mobilenet" ]]; then echo "benchmark.object-detection.qaic-loadgen"; 
    elif [[ "$bmodel" == "resnet50" ]]; then echo "benchmark.image-classification.qaic-loadgen"; 
  fi
}
function get_accuracy_metric() {
  bmodel=$1
  if [[ "$bmodel" == "bert" ]]; then echo "f1"; 
    elif [[ "$bmodel" == "ssd_resnet34" ]]; then echo "mAP"; 
    elif [[ "$bmodel" == "ssd_mobilenet" ]]; then echo "mAP"; 
    elif [[ "$bmodel" == "resnet50" ]]; then echo "Accuracy"; 
  fi
}
if [[ $# < 2 ]]; then echo "Model base name (for e.g., bert) and Model unique name for compilation (for e.g., ssd_resnet34.pcie.16nsp) required!"; exit 1; fi
max=0
maxi=0
bmodel=$1
model=$2
if [ "$#" == 3 ]; then sdk=$3; else sdk=1.5.9; fi
cprogram=$(get_cmdgen_program_name $bmodel)
accuracy_metric=$(get_accuracy_metric $bmodel)
if [ "$bmodel" == "bert" ]; then rmodel=$model; else rmodel=$bmodel; fi
for i in {70..99..1}
do
  pcv="99"$i
  install_cmd="ck install package --tags=compiled,$bmodel,$model,quantization.calibration --env._PERCENTILE_CALIBRATION_VALUE=99.$pcv --extra_tags=pcv.$pcv >/dev/null 2>&1"
  echo $install_cmd
  eval $install_cmd
  exit_if_error
  ck_run_cmd="ck run cmdgen:$cprogram --verbose --sut=r282_z93_q1 --sdk=$sdk --model=$rmodel --mode=accuracy --scenario=offline  --replace_existing --calibration_value=$pcv >/dev/null 2>&1"
  echo $ck_run_cmd
  eval $ck_run_cmd
  exit_if_error
  ck_clean_package_cmd="yes | ck clean env --tags=compiled,$model,quantization.calibration,pcv.$pcv >/dev/null 2>&1"
  echo $ck_clean_package_cmd
  eval $ck_clean_package_cmd
  accuracy=`grep -w $accuracy_metric $(ck find experiment:*$model*$pcv*offline*accuracy*)/*0001.json | cut -d ':' -f2 | cut -d ' ' -f2`
  #echo $accuracy_cmd
  #accuracy=`$accuracy_cmd`
  #yes | ck rm experiment:*$model*$pcv*offline*accuracy* >/dev/null 2>&1
  #echo $pcv":"$f1
  #echo $pcv":"$f1 >>out
  if [[ $accuracy > $max ]]; then
    max=$accuracy
    maxi=99$i
  fi
done
echo $maxi
install_cmd="ck install package --tags=compiled,$bmodel,$model,quantization.calibration --env._PERCENTILE_CALIBRATION_VALUE=99.$maxi --extra_tags=pcv.$maxi >/dev/null 2>&1"
echo $install_cmd
#eval $install_cmd
#echo $max:$maxi>outm
exit_if_error

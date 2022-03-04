#!/bin/bash

_SDK_VER=${SDK_VER:-1.6.80}
_SDK_DIR=${SDK_DIR:-/home/krai}
_PLATFORM_SDK=${PLATFORM_SDK:-"${_SDK_DIR}/qaic-platform-sdk-${_SDK_VER}.zip"}
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  _PLATFORM_SDK="${_SDK_DIR}/qaic-platform-sdk-aarch64-${_SDK_VER}.zip"
fi
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  echo "ERROR: File '${_PLATFORM_SDK}' does not exist!"
  exit 1
fi
echo "Using Platform SDK: ${_PLATFORM_SDK}"

unzip -o ${_PLATFORM_SDK} -d "$(dirname $_PLATFORM_SDK)"

if [[ $(cat /etc/os-release) == *Ubuntu* ]]
then
  cd ${_PLATFORM_SDK::-4}/aarch64/ubuntu
else
  cd ${_PLATFORM_SDK::-4}/aarch64/centos
fi

if [[ $(cat /proc/device-tree/model | tr -d '\0') == *HDK ]]; then
  echo "yes" | rm rpm/qaic-kmd-${_SDK_VER}-1.el7.aarch64.rpm
  cp rpm-perf/qaic-kmd-${_SDK_VER}-1.el7.aarch64.rpm rpm/
fi
echo "yes" | sudo ./uninstall.sh
sudo ./install.sh


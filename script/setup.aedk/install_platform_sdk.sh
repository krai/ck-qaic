#!/bin/bash

ARCH=$(uname -m)
_ARCH="aarch64"
if [[ "${ARCH}" != "${_ARCH}" ]]; then
  echo "ERROR: This script must be run on '${_ARCH}', not '${ARCH}'!"
  exit 1
fi	

if [[ $(cat /etc/os-release) == *Ubuntu* ]]; then
  _OS="ubuntu"
else
  _OS="centos"
fi

_SDK_VER=${SDK_VER:-1.7.1.7}
_SDK_DIR=${SDK_DIR:-/data/krai}

_PLATFORM_SDK=${PLATFORM_SDK:-"${_SDK_DIR}/qaic-platform-sdk-${_ARCH}-${_OS}-${_SDK_VER}.zip"}
echo ${_PLATFORM_SDK}
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  _PLATFORM_SDK="${_SDK_DIR}/qaic-platform-sdk-${_SDK_VER}.zip"
fi
if [[ ! -f "${_PLATFORM_SDK}" ]]; then
  echo "ERROR: File '${_PLATFORM_SDK}' does not exist!"
  exit 1
fi
echo "Using Platform SDK: ${_PLATFORM_SDK}"

unzip -o ${_PLATFORM_SDK} -d "$(dirname ${_PLATFORM_SDK})"
cd "$(dirname ${_PLATFORM_SDK})/qaic-platform-sdk-${_SDK_VER}/${_ARCH}/${_OS}"

if [[ $(cat /proc/device-tree/model | tr -d '\0') == *HDK ]]; then
  echo "yes" | rm rpm/qaic-kmd-${_SDK_VER}-1.el7.${_ARCH}.rpm
  cp rpm-perf/qaic-kmd-${_SDK_VER}-1.el7.${_ARCH}.rpm rpm/
fi
echo "yes" | sudo ./uninstall.sh
sudo ./install.sh

echo
echo "Done."
